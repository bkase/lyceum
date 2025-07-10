{ pkgs, ... }:

pkgs.writeShellScriptBin "cx" ''
  set -euo pipefail

  if [ $# -eq 0 ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "cx - Run any command without installing it"
    echo ""
    echo "Usage: cx <command> [args...]"
    echo ""
    echo "Examples:"
    echo "  cx cowsay 'Hello!'     # Run cowsay"
    echo "  cx python -c 'print(42)'  # Run Python"
    echo "  cx jq '.name' data.json   # Run jq"
    echo "  cx tree -L 2              # Run tree"
    echo ""
    echo "cx uses nix-index to find and run commands from nixpkgs"
    exit 0
  fi

  COMMAND="$1"
  shift

  # Find packages that provide this command
  PACKAGES=$(${pkgs.nix-index}/bin/nix-locate -w "bin/$COMMAND" 2>/dev/null | grep -E "\.(out|bin)\s+[0-9,]+ x" | awk '{print $1}' | sed 's/\.(out|bin)$//' || true)

  if [ -z "$PACKAGES" ]; then
    echo "Error: No package found that provides '$COMMAND'" >&2
    exit 1
  fi

  # Get the first package (most common/relevant)
  PACKAGE=$(echo "$PACKAGES" | head -n1)

  # Handle special cases to override the default nix-locate behavior.
  # This is used to resolve ambiguity, select full-featured packages over
  # minimal ones, and handle command/package name mismatches.
  case "$COMMAND" in
    ### 1. Command/Package Name Mismatches
    ag)                   PACKAGE="silver-searcher" ;;   # ag is the executable for the silver searcher
    fd)                   PACKAGE="fd" ;;                # fd-find in some distros, fd in nixpkgs
    rg)                   PACKAGE="ripgrep" ;;           # rg is the ripgrep executable
    bat)                  PACKAGE="bat" ;;               # cat clone with syntax highlighting
    ht)                   PACKAGE="httpie" ;;            # HTTPie uses 'ht' as its command
    yt-dlp)               PACKAGE="yt-dlp" ;;            # YouTube downloader fork
    gs)                   PACKAGE="ghostscript" ;;       # PostScript interpreter

    ### 2. Selecting Canonical GNU/Core Implementations
    make)                 PACKAGE="gnumake" ;;           # GNU make (not BSD make)
    tar)                  PACKAGE="gnutar" ;;            # GNU tar (not BSD tar)
    sed)                  PACKAGE="gnused" ;;            # GNU sed (not BSD sed)
    awk)                  PACKAGE="gawk" ;;              # GNU awk (not mawk/nawk)
    grep)                 PACKAGE="gnugrep" ;;           # GNU grep (not BSD grep)
    find)                 PACKAGE="findutils" ;;         # GNU find (not BSD find)
    xargs)                PACKAGE="findutils" ;;         # xargs is part of findutils
    patch)                PACKAGE="gnupatch" ;;          # GNU patch
    man)                  PACKAGE="man-db" ;;            # man-db implementation
    which)                PACKAGE="which" ;;             # GNU which

    ### 3. Preferring "Full" Versions Over Minimal Ones
    curl)                 PACKAGE="curlFull" ;;          # curl with all protocols enabled
    git)                  PACKAGE="gitFull" ;;           # git with all features (perl support, etc)
    unrar)                PACKAGE="unrar" ;;             # Full unrar (not p7zip's limited version)
    ffmpeg)               PACKAGE="ffmpeg-full" ;;       # ffmpeg with all codecs

    ### 4. Selecting a Specific Version or Variant
    python|python3)       PACKAGE="python3" ;;           # Default to Python 3.x
    pip|pip3)             PACKAGE="python3Packages.pip" ;; # pip for Python 3
    ruby)                 PACKAGE="ruby" ;;              # Latest stable Ruby
    gem)                  PACKAGE="ruby" ;;              # gem is bundled with Ruby
    node)                 PACKAGE="nodejs" ;;            # Node.js (not nodejs-slim)
    npm|npx)              PACKAGE="nodejs" ;;            # npm/npx come with Node.js
    aws)                  PACKAGE="awscli2" ;;           # AWS CLI v2 (not v1)
    yq)                   PACKAGE="yq-go" ;;             # Go version (not Python yq)
    htop)                 PACKAGE="htop" ;;              # Interactive process viewer
    tshark)               PACKAGE="wireshark-cli" ;;     # CLI version of Wireshark
    
    ### 5. Pulling in Tool Suites
    psql)                 PACKAGE="postgresql" ;;        # PostgreSQL client tools
    pg_dump)              PACKAGE="postgresql" ;;        # Part of PostgreSQL suite
    mysql)                PACKAGE="mariadb" ;;           # MariaDB client (MySQL-compatible)
    sqlite3)              PACKAGE="sqlite" ;;            # SQLite database
    redis-cli)            PACKAGE="redis" ;;             # Redis client from server package
    gcloud)               PACKAGE="google-cloud-sdk" ;;  # Full Google Cloud SDK
    az)                   PACKAGE="azure-cli" ;;         # Azure CLI tools
    dig)                  PACKAGE="dnsutils" ;;          # DNS lookup utility
    host)                 PACKAGE="dnsutils" ;;          # DNS lookup utility
    nslookup)             PACKAGE="dnsutils" ;;          # DNS lookup utility
    ab)                   PACKAGE="apacheHttpd" ;;       # Apache Benchmark tool
    composer)             PACKAGE="php.packages.composer" ;; # PHP dependency manager
  esac

  # Log which package we're using
  echo "[cx] Running '$COMMAND' from package '$PACKAGE'" >&2

  # Use nix shell to run the command within the package's environment
  exec nix shell "nixpkgs#$PACKAGE" -c "$COMMAND" "$@"
''