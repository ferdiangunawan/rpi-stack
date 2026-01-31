---
name: audit
description: Validates research/plan/code against overengineering, underengineering, and hallucination
---

# Audit Skill

Validates artifacts against quality gates for hallucination, overengineering, and underengineering detection.

---

## Purpose

The Audit skill is a quality gate that catches common AI implementation pitfalls:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         AUDIT FRAMEWORK                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐         │
│  │  HALLUCINATION  │  │ OVERENGINEERING │  │ UNDERENGINEERING│         │
│  │     CHECK       │  │     CHECK       │  │     CHECK       │         │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘         │
│           │                    │                    │                   │
│           ▼                    ▼                    ▼                   │
│      Inventing?           Too much?            Too little?              │
│      Assuming?            Premature?           Missing?                 │
│      Fabricating?         Complex?             Incomplete?              │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────┐      │
│  │                    SCORING ENGINE                             │      │
│  │  Hallucination ≤ 20 | Balance ≥ 70 | Confidence ≥ 60         │      │
│  └──────────────────────────────────────────────────────────────┘      │
│                              │                                          │
│                              ▼                                          │
│                    ┌─────────────────┐                                  │
│                    │   PASS / FAIL   │                                  │
│                    └─────────────────┘                                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Agent Compatibility

- AskUserQuestion: use the tool in Claude Code; in Codex CLI, ask the user directly and record the answer.
- OUTPUT_DIR: `.claude/output` for Claude Code, `.codex/output` for Codex CLI.

## Audit Types

### Type 1: Research Audit
Validates research output before planning.

### Type 2: Plan Audit
Validates plan output before implementation.

### Type 3: Implementation Audit
Validates code changes before completion.

---

## Check 1: Hallucination Detection

### Definition
Hallucination occurs when AI:
- Invents requirements not in PRD
- Assumes behavior without evidence
- Fabricates technical details
- Misinterprets or distorts requirements

### Detection Criteria

| Signal | Description | Severity |
|--------|-------------|----------|
| **Phantom Requirements** | Requirements not traceable to PRD | Critical |
| **Assumed Behavior** | Behavior defined without specification | High |
| **Invented Edge Cases** | Edge cases not mentioned in PRD | Medium |
| **Fabricated Context** | Technical context without evidence | High |
| **Misquoted Requirements** | Altered wording from original | Medium |
| **Research Carryover** | Using default/research values instead of custom implementation | Critical |

### Hallucination Checklist

```
For each claim/requirement/decision, verify:

□ Is this explicitly stated in the PRD?
  - YES: ✓ Traceable
  - NO: Check if reasonable inference

□ If inferred, is the inference justified?
  - Is it based on project patterns?
  - Is it based on technical necessity?
  - Is it marked as an assumption?

□ Are all quotes accurate?
  - Compare against original PRD
  - No paraphrasing without marking

□ Are technical claims verifiable?
  - Can be confirmed from codebase?
  - Based on documentation?
  - Standard practice?

□ For custom configurations:
  - Is implementation using its OWN defined constants?
  - Or accidentally using defaults from research?
```

### Hallucination Scoring

```
Hallucination Score = (Phantom Items / Total Items) × 100

Thresholds:
- 0-10%: Excellent - Minimal hallucination
- 11-20%: Acceptable - Minor assumptions
- 21-40%: Warning - Needs clarification
- 41%+: Fail - Too much invention
```

### Hallucination Response Protocol

**CRITICAL: When assumptions are detected, MUST confirm with user before marking as hallucination.**

When audit detects:
- Assumed Behavior (not in PRD)
- Invented Edge Cases
- Unconfirmed Decisions

**MUST ask the user (AskUserQuestion tool in Claude Code, or direct question in Codex CLI) BEFORE marking as "hallucination":**

```
AskUserQuestion(
  questions: [
    {
      question: "The plan assumes [X behavior]. Is this correct?",
      header: "Confirm assumption",
      options: [
        { label: "Yes, correct", description: "Proceed with this behavior" },
        { label: "No, should be Y", description: "Change to different behavior" },
        { label: "Need to discuss", description: "Requires more context" }
      ],
      multiSelect: false
    }
  ]
)
```

**Audit Verdict Rules:**
- If user confirms assumption → NOT a hallucination, mark as "User Confirmed"
- If user rejects assumption → Flag as hallucination, require fix
- If user needs discussion → HALT audit, gather more context

**Rules:**
1. NEVER auto-fail assumptions - ASK user first
2. NEVER skip confirmation for edge case behaviors
3. Document all confirmations: "(User confirmed via AskUserQuestion or direct question)"

---

## Check 2: Overengineering Detection

### Definition
Overengineering occurs when AI:
- Adds unnecessary complexity
- Builds for hypothetical futures
- Creates premature abstractions
- Implements beyond requirements

### Detection Criteria

| Signal | Description | Severity |
|--------|-------------|----------|
| **Scope Creep** | Features beyond requirements | High |
| **Premature Abstraction** | Generalization without need | Medium |
| **Future-Proofing** | Building for speculative needs | Medium |
| **Unnecessary Layers** | Extra architecture without benefit | High |
| **Gold Plating** | Nice-to-haves treated as must-haves | Medium |
| **Over-Configuration** | Excessive configurability | Low |

### Overengineering Checklist

```
For each proposed element, verify:

□ Is this required by PRD?
  - YES: ✓ Required
  - NO: Is it technically necessary?

□ If not in PRD, is it technically necessary?
  - Error handling for the feature? ✓
  - Generic utility for future? ✗
  - Abstraction for single use? ✗

□ Complexity check:
  - Could this be simpler?
  - Is abstraction premature?
  - Are we building for hypotheticals?

□ Pattern check:
  - Does this follow existing patterns?
  - Are we inventing new patterns?
  - Is deviation justified?
```

### Overengineering Signals in Code

```dart
// OVERENGINEERED - Generic for single use
abstract class BaseFeatureController<T extends BaseState> {
  // Only one implementation exists
}

// CORRECT - Simple and direct
class FeatureController extends StateNotifier<FeatureState> {
  // Specific implementation
}
```

```dart
// OVERENGINEERED - Configuration not requested
class Feature {
  final bool enableAdvancedMode;
  final int maxRetries;
  final Duration timeout;
  final String customEndpoint;
  // None of these in requirements
}

// CORRECT - Only what's needed
class Feature {
  final String name;
  final bool isActive;
  // Matches requirements
}
```

### Overengineering Scoring

```
Overengineering Score = (Unnecessary Items / Total Items) × 100

Thresholds:
- 0-10%: Excellent - Minimal extras
- 11-25%: Acceptable - Some reasonable additions
- 26-40%: Warning - Scope creep detected
- 41%+: Fail - Significant overengineering
```

---

## Check 3: Underengineering Detection

### Definition
Underengineering occurs when AI:
- Misses requirements
- Ignores edge cases
- Skips error handling
- Forgets security/validation
- Incomplete implementation

### Detection Criteria

| Signal | Description | Severity |
|--------|-------------|----------|
| **Missing Requirements** | PRD items not addressed | Critical |
| **No Error Handling** | Happy path only | High |
| **Missing Validation** | Input not validated | High |
| **Ignored Edge Cases** | Obvious cases not handled | Medium |
| **No Loading States** | Missing UI feedback | Medium |
| **Missing Tests** | No test strategy | Medium |
| **Security Gaps** | Auth/permission not considered | High |

### Underengineering Checklist

```
For each requirement, verify:

□ Is this requirement fully addressed?
  - All acceptance criteria covered?
  - Edge cases handled?
  - Error states defined?

□ Error handling:
  - Network failures?
  - Invalid data?
  - Empty states?
  - Timeout handling?

□ Validation:
  - User input validated?
  - Data type validation?
  - Business rule validation?

□ UI completeness:
  - Loading states?
  - Error states?
  - Empty states?
  - Success feedback?

□ Security considerations:
  - Authentication checked?
  - Authorization handled?
  - Data sanitization?
```

### Underengineering Scoring

```
Underengineering Score = (Missing Items / Required Items) × 100

Thresholds:
- 0-10%: Excellent - Comprehensive
- 11-20%: Acceptable - Minor gaps
- 21-35%: Warning - Needs additions
- 36%+: Fail - Too incomplete
```

---

## Balance Score

The Balance Score measures the sweet spot between over and under engineering:

```
Balance Score = 100 - |Overengineering - Underengineering|/2 - max(Over, Under)/2

Interpretation:
- High Balance (70+): Good equilibrium
- Medium Balance (50-69): Leaning one direction
- Low Balance (<50): Significantly imbalanced

Ideal State:
- Low overengineering (≤15%)
- Low underengineering (≤15%)
- High balance (≥70%)
```

---

## Audit Execution

### Input Analysis

```
1. Load artifact to audit (research.md, plan.md, or code diff)
2. Load original PRD/requirements
3. Load project context (AGENTS.md, patterns)
```

### Systematic Check

```
For each item in artifact:
  1. Trace to PRD → Hallucination Check
  2. Assess necessity → Overengineering Check
  3. Check completeness → Underengineering Check
  4. Score and categorize
```

### Finding Categories

```
Findings:
├── CRITICAL: Must fix before proceeding
├── HIGH: Should fix, significant impact
├── MEDIUM: Recommended fix
├── LOW: Nice to fix
└── INFO: Observation only
```

---

## Output Template

Generate `OUTPUT_DIR/audit-{feature}.md`:

```markdown
# Audit Report: {Feature Name}

## Metadata
- **Date**: {YYYY-MM-DD}
- **Audit Type**: {Research / Plan / Implementation}
- **Artifact Audited**: {file path}
- **PRD Reference**: {source}

---

## Executive Summary

| Metric | Score | Status |
|--------|-------|--------|
| Hallucination | {X}% | {PASS/FAIL} |
| Overengineering | {X}% | {PASS/FAIL} |
| Underengineering | {X}% | {PASS/FAIL} |
| Balance Score | {X}% | {PASS/FAIL} |
| **Overall** | **{PASS/FAIL}** | |

---

## Hallucination Analysis

### Score: {X}%

### Findings

| ID | Item | Type | Evidence | Severity |
|----|------|------|----------|----------|
| H1 | {item} | Phantom Requirement | No PRD trace | Critical |
| H2 | {item} | Assumed Behavior | Not specified | High |

### Verified Items
- ✓ {item} - Traced to PRD section X
- ✓ {item} - Traced to PRD section Y

### Recommendations
1. Remove {item} - not in requirements
2. Mark {item} as assumption and verify with stakeholder

---

## Overengineering Analysis

### Score: {X}%

### Findings

| ID | Item | Type | Impact | Severity |
|----|------|------|--------|----------|
| O1 | {item} | Scope Creep | Adds complexity | High |
| O2 | {item} | Premature Abstraction | Unnecessary | Medium |

### Justified Additions
- ✓ {item} - Required for {reason}

### Recommendations
1. Simplify {item} - use existing pattern
2. Remove {item} - not needed

---

## Underengineering Analysis

### Score: {X}%

### Missing Items

| ID | Missing Item | PRD Reference | Severity |
|----|--------------|---------------|----------|
| U1 | {item} | Section X | Critical |
| U2 | {item} | AC-3 | High |

### Gaps Identified

**Error Handling Gaps:**
- [ ] {scenario} not handled

**Validation Gaps:**
- [ ] {input} not validated

**UI State Gaps:**
- [ ] Loading state missing for {action}
- [ ] Empty state missing for {scenario}

### Recommendations
1. Add {item} - required by PRD
2. Implement error handling for {scenario}

---

## Requirement Traceability

| Requirement | Status | Coverage | Notes |
|-------------|--------|----------|-------|
| R1: {desc} | ✓ Covered | Full | |
| R2: {desc} | ⚠ Partial | 60% | Missing {item} |
| R3: {desc} | ✗ Missing | 0% | Not addressed |

---

## Pattern Compliance

### AGENTS.md Compliance

| Pattern | Status | Notes |
|---------|--------|-------|
| State Management | ✓ | Using StateNotifier |
| Model Pattern | ✓ | Equatable + ReturnValue |
| Styling | ⚠ | Missing Gap usage |
| Widget Structure | ✓ | Separate widget classes |

### Violations
1. {violation description}

---

## Final Verdict

### Status: {PASS / CONDITIONAL PASS / FAIL}

### Blocking Issues
{List of issues that must be resolved}

### Non-Blocking Issues
{List of issues that should be resolved}

### Next Steps
1. {action item}
2. {action item}
```

---

## Prompt

When user invokes `/audit`, execute:

```
I will now audit the {artifact type} against quality gates.

## Loading Context

1. Loading artifact: {file}
2. Loading PRD reference: {source}
3. Loading project patterns: AGENTS.md

## Hallucination Check

Tracing each item to requirements...

Findings:
- {item}: {traceable/phantom/assumed}

Hallucination Score: {X}%

## Overengineering Check

Assessing necessity of each element...

Findings:
- {item}: {required/unnecessary/premature}

Overengineering Score: {X}%

## Underengineering Check

Checking completeness against requirements...

Missing:
- {item}: {reason}

Underengineering Score: {X}%

## Balance Assessment

Balance Score: {X}%

## Requirement Traceability Matrix

[Matrix showing each requirement and coverage]

## Final Verdict

**{PASS / CONDITIONAL PASS / FAIL}**

{Reasoning and required actions}
```

---

## Quick Audit Commands

```
/audit research  - Audit the research output
/audit plan      - Audit the plan output
/audit code      - Audit implementation against plan
/audit full      - Run all audits in sequence
```
