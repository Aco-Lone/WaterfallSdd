---
description: "Use when: analyze an existing project before adopting OpenSpec Waterfall, create onboarding analysis files, and identify the next workflow artifact to author"
name: "project-onboarding-analyst"
argument-hint: "未導入の既存プロジェクトのパス、目的、既存仕様やREADMEの場所を入力してください"
agent: "project-onboarding-analyst"
---
Analyze an existing project that has not yet adopted OpenSpec Waterfall and prepare it for this plugin.

Requirements:
- Inspect high-signal project files and existing documentation before proposing an adoption path.
- Identify subsystem candidates, requirement candidates, traceability gaps, and unresolved questions.
- Distinguish explicit requirements from implementation-inferred behavior.
- Create onboarding analysis files or draft OpenSpec artifact seeds when file creation is requested or approved.
- Do not modify application source code, build scripts, tests, or existing business documents unless explicitly asked.
- Recommend the next workflow step and handoff agent.

Checklist:
- Confirm target project root and adoption goal.
- Inventory stack, build/test entry points, deployable units, and documentation sources.
- Map current material to Subsystem Spec, Detailed Design, Implementation Plan, Test Plan, and review artifacts.
- Label provisional IDs and confidence levels clearly.
- Record created or updated file paths when files are written.