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

Set up progress tracking using TodoWrite:

```dart
// Initialize todos from plan tasks
TodoWrite([
  Task("T1: Create response model", pending),
  Task("T2: Create domain model", pending),
  Task("T3: Create service", pending),
  // ... all tasks from plan
]);
```

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

### 2.4 Progress Tracking

After each task completion:

```
1. Update TodoWrite
   - Mark current task completed
   - Mark next task in_progress

2. Log progress
   - Files created/modified
   - Acceptance criteria met
   - Any deviations from plan

3. Checkpoint
   - Run flutter analyze
   - Fix any issues before proceeding
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

After implementation complete, **automatically trigger code-reviewer subagent**:

```
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
    │   └── Initialize TodoWrite
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
   [TodoWrite initialized with all tasks]

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
