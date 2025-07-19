# Claude Commands Style Guide

Guide for creating custom Claude commands that follow a structured workflow pattern with user confirmation points and state tracking.

## Command Structure

**CRITICAL**
- Commands MUST define clear workflow phases (e.g., INIT → ANALYZE → EXECUTE → VERIFY)
- Commands MUST include STOP points for user confirmation at key decision moments
- Commands MUST handle state persistence for resumable workflows
- Commands MUST use parallel operations where possible for performance
- Commands MUST validate prerequisites before proceeding

### Core Patterns

#### Workflow Phases

Define discrete phases that execute in strict order:

```markdown
### INIT
1. Check for existing state/resume capability
2. Validate prerequisites
3. Gather initial context
4. STOP → "Confirm initial setup? (y/n)"

### ANALYZE
1. Research relevant files/context
2. Present findings
3. STOP → "Proceed with this analysis? (y/n)"

### EXECUTE
1. Perform main task
2. Validate results
3. STOP → "Approve these changes? (y/n)"
```

#### State Management

For resumable workflows:
- Check for state file existence (e.g., `task.md`, `state.json`)
- Include PID tracking: `**Agent PID:** [Bash(echo $PPID)]`
- Define clear status values: `Initializing`, `InProgress`, `AwaitingConfirmation`, `Complete`
- Update state after each phase completion

#### User Interaction Points

STOP format: `STOP → "[Question/instruction]"`

Examples:
- `STOP → "Which option would you like? (1/2/3)"`
- `STOP → "Editor opened. Run 'claude /command' to continue"`
- `STOP → "Approve these changes? (y/n)"`

#### Parallel Operations

Use parallel Task agents for research/analysis:
```markdown
- Use parallel Task agents to analyze:
  - Component A analysis
  - Component B analysis
  - Dependency mapping
```

### Best Practices

1. **Error Handling**: Always include "MUST consult with user in case of unexpected errors"
2. **File Operations**: Read multiple files in parallel when gathering context
3. **Git Integration**: Include proper git commands with clear commit messages
4. **Validation**: Run tests/lints after implementation phases
5. **Documentation**: Update relevant docs if implementation changes project structure

### Template Structure

```markdown
---
allowed-tools: Bash(*), Task, Read, Write, Edit, Grep, Glob
description: [One-line description of command purpose]
argument-hint: [optional-argument-description]
---

# [Command Name] Implementation Program

[Brief description of what this command does and when to use it]

## Workflow

**CRITICAL**
- You MUST follow workflow phases in order: [list phases]
- You MUST get user confirmation at each STOP
- You MUST [other critical requirements]

### PHASE_1
[Steps for phase 1]

### PHASE_2
[Steps for phase 2]

### PHASE_N
[Steps for final phase]
```

### Common Elements

#### File Discovery
```markdown
1. Check for required files:
   - If exists: Read and validate
   - If missing: STOP → "Please provide [missing information]"
```

#### Progress Tracking
```markdown
- [ ] Task item with location reference (src/file.ts:45-93)
- [ ] Test creation: describe what test validates
- [ ] User verification: how user confirms success
```

#### Commit Patterns
```markdown
- Initial: `git commit -m "[feature]: Initialization"`
- Progress: `git commit -m "[description of change]"`
- Complete: `git commit -m "Complete [feature]"`
```

## Example Commands

### Project Setup Command
- Analyzes codebase structure
- Creates project description
- Sets up development environment

### Feature Implementation Command
- Takes vague requirements
- Refines into concrete plan
- Implements with checkpoints
- Validates and commits

### Refactoring Command
- Identifies code patterns
- Proposes improvements
- Executes changes systematically
- Ensures tests pass

## Testing Your Command

1. Create command file: `~/.claude/commands/mycommand.md`
2. Test resumability: Interrupt and restart
3. Verify all STOP points work correctly
4. Ensure state tracking functions properly
5. Validate error handling paths