---
name: implement
description: Executes implementation plan with quality checks and progress tracking. Follows AGENTS.md patterns strictly.
---

# Implement Skill

Executes the validated plan systematically with progress tracking.

---

## Purpose

The Implement skill executes the validated plan systematically:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      IMPLEMENTATION FRAMEWORK                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌────────────┐  │
│  │   PREPARE   │──▶│   EXECUTE   │──▶│   VERIFY    │──▶│   REVIEW   │  │
│  └─────────────┘   └─────────────┘   └─────────────┘   └────────────┘  │
│        │                 │                  │                │         │
│        ▼                 ▼                  ▼                ▼         │
│   • Read docs       • Task by task     • Run tests      • Code review │
│   • Load plan       • Track progress   • Check lint     • PR ready    │
│   • Setup todos     • Validate each    • Verify AC      • Summary     │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Agent Compatibility

- TodoWrite: use the tool in Claude Code; in Codex CLI, use `update_plan` or a simple checklist.
- Code-review subagents: use if available; otherwise run the code review manually with the code-review skill.

## Phase 1: Preparation

### 1.1 Load Context

Before writing any code, load essential context:

```
Required Reading:
├── AGENTS.md                    # Project patterns & conventions
├── docs/**/*.md                 # Project documentation
├── plan-{feature}.md            # Implementation plan
├── research-{feature}.md        # Research context
│
└── Reference Files (from plan)
    ├── Similar feature implementations
    └── Related existing code
```

### 1.2 Context Checklist

```
□ AGENTS.md patterns understood
  - State management: StateNotifier + copyWith
  - Models: Equatable + ReturnValue
  - Styling: ColorApp, TypographyTheme, Gap, SizeApp
  - Widgets: Separate classes, no _buildX methods
  - Localization: LocaleKeys.xxx.tr()

□ Plan fully loaded
  - All tasks identified
  - Dependencies mapped
  - File inventory ready

□ Codebase context
  - Similar implementations reviewed
  - Existing components identified
  - Naming conventions understood
```

### 1.3 Todo Initialization

Set up progress tracking using TodoWrite (Claude Code) or `update_plan` (Codex CLI):

```dart
// Initialize todos from plan tasks
TodoWrite([
  Task("T1: Create response model", pending),
  Task("T2: Create domain model", pending),
  Task("T3: Create service", pending),
  // ... all tasks from plan
]);
```

Codex CLI: mirror the same tasks using `update_plan`.

---

## Phase 2: Execution

### 2.1 Task Execution Order

Follow strict ordering from plan:

```
For each task in dependency order:
  1. Mark task as in_progress
  2. Read related existing code
  3. Implement the task
  4. Validate against acceptance criteria
  5. Run relevant tests/lint
  6. Mark task as completed
  7. Move to next task
```

### 2.2 Implementation Rules

**General Rules:**
```
1. ONE task at a time - never skip ahead
2. Validate BEFORE marking complete
3. Follow AGENTS.md patterns EXACTLY
4. Use existing components when available
5. No scope creep - stick to plan
```

**Code Quality Rules:**
```
1. No hallucination - only implement what's in plan
2. No overengineering - minimum code for requirements
3. No underengineering - all acceptance criteria met
4. Run lint after significant changes
5. Test as you go
```

### 2.3 Pattern Compliance

**Model Creation (Equatable + ReturnValue):**
```dart
// CORRECT - Following AGENTS.md
class FeatureResponse extends Equatable {
  final String id;
  final String name;

  const FeatureResponse({
    required this.id,
    required this.name,
  });

  factory FeatureResponse.fromJson(Map<String, dynamic> json) {
    return FeatureResponse(
      id: ReturnValue.string(json['id']),
      name: ReturnValue.string(json['name']),
    );
  }

  @override
  List<Object?> get props => [id, name];
}

// WRONG - Not following pattern
@freezed  // ❌ Don't use Freezed
class FeatureResponse with _$FeatureResponse {
  ...
}
```

**State Management:**
```dart
// CORRECT - StateNotifier pattern
class FeatureController extends StateNotifier<FeatureState> {
  FeatureController({required this.service})
      : super(const FeatureState());

  final FeatureService service;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final result = await service.getData();
    result.when(
      success: (data) => state = state.copyWith(
        data: data,
        isLoading: false,
      ),
      failure: (e) => state = state.copyWith(
        error: e.message,
        isLoading: false,
      ),
    );
  }
}

// State class with copyWith
class FeatureState {
  final Data? data;
  final bool isLoading;
  final String? error;

  const FeatureState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  FeatureState copyWith({...}) => FeatureState(...);
}
```

**Widget Structure:**
```dart
// CORRECT - Separate widget classes
class FeatureScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        FeatureHeader(),      // Separate widget
        FeatureContent(),     // Separate widget
        FeatureFooter(),      // Separate widget
      ],
    );
  }
}

// WRONG - Widget methods
class FeatureScreen extends ConsumerWidget {
  Widget _buildHeader() {...}  // ❌ Don't do this
  Widget _buildContent() {...} // ❌ Don't do this
}
```

**Styling:**
```dart
// CORRECT - Using project constants
Text(
  'Title',
  style: TypographyTheme.title2,
)
Container(
  color: ColorApp.primary,
  padding: EdgeInsets.all(SizeApp.w16),
)
Column(
  children: [
    Widget1(),
    Gap.h16,  // Use Gap for spacing
    Widget2(),
  ],
)

// WRONG - Hardcoded values
Text(
  'Title',
  style: TextStyle(fontSize: 24),  // ❌
)
Container(
  color: Color(0xFF009F4D),  // ❌
  padding: EdgeInsets.all(16),  // ❌
)
SizedBox(height: 16)  // ❌ Use Gap.h16
```

### 2.4 Progress Tracking (MANDATORY)

**CRITICAL: You MUST update the RPI session after EACH task completion.**

After each task completion:

```
1. Update TodoWrite or `update_plan`/checklist
   - Mark current task completed
   - Mark next task in_progress

2. Update RPI Session (MANDATORY)
   - Run the progress update script
   - This updates progress.percentage, tasks_done, continuation fields

3. Log progress
   - Files created/modified
   - Acceptance criteria met
   - Any deviations from plan

4. Checkpoint
   - Run flutter analyze
   - Fix any issues before proceeding
```

#### Session Update Commands

**Before starting first task:**
```bash
~/.claude/skills/scripts/rpi-progress.sh --phase implement --tasks-total {count}
~/.claude/skills/scripts/rpi-progress.sh --task-start T1 --next "Complete T1: {task_title}"
```

**After each task completion:**
```bash
~/.claude/skills/scripts/rpi-progress.sh --task-done T{n} --last "Completed T{n}: {task_title}" --next "Start T{n+1}: {next_task_title}"
~/.claude/skills/scripts/rpi-progress.sh --task-start T{n+1}
```

**After final task:**
```bash
~/.claude/skills/scripts/rpi-progress.sh --task-done T{final} --last "Completed all implementation tasks" --next "Code review"
```

#### Progress Formula During Implementation

Progress is calculated as: `35% + (55% / tasks_total) * tasks_done`

Example with 5 tasks:
- T1 complete: 35% + (55/5)*1 = 46%
- T2 complete: 35% + (55/5)*2 = 57%
- T3 complete: 35% + (55/5)*3 = 68%
- T4 complete: 35% + (55/5)*4 = 79%
- T5 complete: 35% + (55/5)*5 = 90%

---

## Phase 2.5: Background Audits

After completing each task group (e.g., T1-T3), spawn background security and performance audits.

### 2.5.1 Spawn Background Audits

```markdown
After task group completion:

1. Collect files created/modified in this group
2. Spawn background security audit:

   Task tool:
     subagent_type: "general-purpose"
     run_in_background: true
     prompt: |
       Run /audit-security on these files: {file_list}
       Write findings to .claude/output/audit-{session}-security.json
       If any P0 (critical) issues found, report immediately with:
       "🚨 SECURITY P0: {finding}. File: {file}:{line}. Fix: {fix}"

3. Spawn background performance audit:

   Task tool:
     subagent_type: "general-purpose"
     run_in_background: true
     prompt: |
       Run /audit-performance on these files: {file_list}
       Write findings to .claude/output/audit-{session}-performance.json
       If any P0 (critical) issues found, report immediately with:
       "⚡ PERFORMANCE P0: {finding}. File: {file}:{line}. Fix: {fix}"

4. Continue with next task group (don't wait for audits)
```

### 2.5.2 P0 Injection Handling

```markdown
If background audit injects P0 finding:

1. STOP current task immediately
2. Read the P0 finding message
3. Fix the issue in the identified file
4. Re-run the specific audit on fixed file
5. Only continue when P0 is resolved

P0 Categories (must fix immediately):
- Security: Hardcoded credentials, injection vulnerabilities
- Performance: Memory leaks, infinite loops, blocking main thread
```

### 2.5.3 End-of-Implementation Audit Sync

```markdown
Before Phase 3 (Verification):

1. Wait for all background audits to complete
2. Read audit results from:
   - .claude/output/audit-{session}-security.json
   - .claude/output/audit-{session}-performance.json
3. If any P0 still present: Fix before proceeding
4. Collect P1/P2 for final summary
5. Update session quality gates:
   - security_audit: { passed: true/false, score: X }
   - performance_audit: { passed: true/false, score: X }
```

### 2.5.4 Audit Summary in Output

Include in implementation summary:

```markdown
## Background Audit Results

### Security Audit
- P0: 0 (fixed during implementation)
- P1: 2 (noted for review)
- P2: 1 (optional improvements)
- Status: PASS

### Performance Audit
- P0: 0 (fixed during implementation)
- P1: 3 (noted for review)
- P2: 2 (optional improvements)
- Status: PASS
- Impact: Medium rebuild reduction

### P1 Issues (For Code Review)
1. [SECURITY] Missing input validation in form_screen.dart:45
2. [PERFORMANCE] Missing const in header_widget.dart:12
3. [PERFORMANCE] Consider virtualization for product list
```

---

## Phase 3: Verification

### 3.1 Per-Task Verification

After each task:
```
□ Code compiles (no errors)
□ Lint passes (flutter analyze)
□ Follows AGENTS.md patterns
□ Acceptance criteria met
□ No unnecessary code added
```

### 3.2 Feature Verification

After all tasks:
```
□ All tasks completed
□ Full flutter analyze passes
□ Tests pass (if added)
□ Feature works as specified
□ No regressions introduced
```

### 3.3 Verification Commands

```bash
# Lint check
flutter analyze

# Run tests
flutter test

# Format check
dart format --set-exit-if-changed .
```

---

## Phase 4: Code Review (Auto-Triggered)

### 4.1 Trigger Code Review

After implementation complete, trigger code review. If subagents are available, use a code-reviewer subagent; otherwise run the code-review skill yourself.

```
Claude Code:
Use Task tool with subagent_type: "code-reviewer"

Prompt: "Review the following files that were just implemented:
- New files: {list of created files}
- Modified files: {list of modified files}

Focus areas:
- P0: Security vulnerabilities, crashes, data loss
- P1: Logic errors, performance, pattern violations
- P2: Style, documentation, minor improvements

Report findings with severity ratings."
```

The code review runs automatically - no user action needed.
Results are displayed in the main conversation.

Codex CLI: run the code-review skill on the modified files.

### 4.2 Review Checklist

```
□ Security - No vulnerabilities introduced
□ Performance - No obvious performance issues
□ Patterns - Follows AGENTS.md conventions
□ Quality - Clean, readable code
□ Tests - Adequate test coverage
□ Completeness - All requirements addressed
```

---

## Execution Flow

```
/implement {feature}
    │
    ├── Phase 1: Prepare
    │   ├── Read AGENTS.md
    │   ├── Read docs/*.md
    │   ├── Load plan-{feature}.md
    │   ├── Load research-{feature}.md
    │   └── Initialize TodoWrite or `update_plan`
    │
    ├── Phase 2: Execute
    │   ├── For each task:
    │   │   ├── Mark in_progress
    │   │   ├── Implement
    │   │   ├── Verify
    │   │   └── Mark completed
    │   └── Run flutter analyze
    │
    ├── Phase 3: Verify
    │   ├── All tasks done
    │   ├── Lint passes
    │   └── Feature works
    │
    └── Phase 4: Review
        ├── Trigger /code-review
        └── Generate summary
```

---

## Error Handling

### If Implementation Fails

```
1. Stop immediately
2. Document the issue
3. Assess if plan needs revision
4. Options:
   a. Fix and continue (minor issue)
   b. Revise plan (design issue)
   c. Return to research (fundamental issue)
```

### If Pattern Unclear

```
1. Search codebase for similar patterns
2. Reference AGENTS.md
3. Check docs/*.md
4. If still unclear, ask user
```

### If Scope Creep Detected

```
1. Stop adding unplanned code
2. Note the potential addition
3. Continue with planned scope
4. Mention in summary for future consideration
```

---

## Output Summary

After implementation complete, generate summary:

```markdown
# Implementation Summary: {Feature Name}

## Completion Status
- **Status**: {Complete / Partial / Failed}
- **Tasks Completed**: {X}/{Total}
- **Duration**: {time}

## Files Changed

### Created
| File | Purpose |
|------|---------|
| `path/to/file.dart` | {purpose} |

### Modified
| File | Changes |
|------|---------|
| `path/to/file.dart` | {changes} |

## Verification Results
- flutter analyze: {PASS/FAIL}
- Tests: {PASS/FAIL/SKIPPED}
- Pattern compliance: {PASS/FAIL}

## Deviations from Plan
{Any deviations and reasons}

## Known Issues
{Any issues discovered}

## Next Steps
1. Code review (triggered)
2. {other next steps}
```

---

## Prompt

When user invokes `/implement`, execute:

```
I will now implement the feature following the validated plan.

## Phase 1: Preparation

Loading context...

1. Reading AGENTS.md...
   - State management: StateNotifier
   - Models: Equatable + ReturnValue
   - Styling: TypographyTheme, ColorApp, Gap, SizeApp

2. Reading plan-{feature}.md...
   - Tasks identified: {count}
   - Dependencies mapped

3. Initializing progress tracking...
   [Todos initialized with all tasks]

## Phase 2: Execution

### Task 1: {Task Title}
Status: in_progress

[Implementing...]

Files created/modified:
- {file}

Verification:
- [ ] Compiles
- [ ] Lint passes
- [ ] Acceptance criteria met

Status: completed ✓

### Task 2: {Task Title}
...

## Phase 3: Verification

Running final checks...

- flutter analyze: {result}
- Pattern compliance: {result}
- All tasks: {X}/{Total} completed

## Phase 4: Code Review

Triggering /code-review for implemented code...

[Code review results]

## Summary

Implementation complete!

{Summary of changes}
```

---

## Quick Commands

```
/implement           - Start implementation from plan
/implement continue  - Continue from last checkpoint
/implement task T5   - Start from specific task
/implement verify    - Run verification only
```
