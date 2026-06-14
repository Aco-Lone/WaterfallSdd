---
name: test-review
description: "Use when performing post-G2 test review against approved Test Plan, test execution results, failures, and OpenSpec traceability"
user-invocable: false
---

# Test Review

## When to Use

- テスト実行完了後に Test Review を実施するとき
- 承認済み Test Plan に対してテスト実行結果、失敗分析、テストコード変更を確認するとき
- TST / REQ / DSG / REV の対応を保ったまま、指摘を Design / Plan / Test / Code / Minor Fix に分類するとき
- テストレビュー後に review-improvement-analyst へ進めるか、設計・計画・テスト・コード修正へ戻すかを決めるとき

## Procedure

1. 承認済み Detailed Design、Implementation Plan、Test Plan、implementation review record、test execution result、失敗分析、変更ファイル、レビュー記録テンプレート、ワークフロー定義を読む。
2. すべての対象 TST が Passed / Failed / Blocked / Not Executed のいずれかで記録され、REQ / DSG と対応しているか確認する。
3. 実行したテスト、テストデータ、前提条件、期待結果が承認済み Test Plan を上書きしていないか確認する。
4. 失敗がある場合は、原因が Design、Plan、Test、Code、Minor Fix のどれに属するかを確認する。
5. 非軽微指摘には Review ID、Requirement IDs、Design Element IDs、Test IDs を付与し、必要に応じて Plan Item IDs も残す。
6. 指摘の戻し先は `test-execution-feedback-handling` で Design / Plan / Test / Code / Minor Fix に分類する。
7. Design に戻す指摘がある場合は、影響範囲の Implementation Plan と Test Plan の再レビュー要否を明記する。
8. Plan または Test に戻す指摘がある場合は、対象 TST、修正内容、再実行条件を記録する。
9. Code に戻す指摘がある場合は、対象 PLN または変更箇所、期待する再検証、再レビュー条件を記録する。
10. 指摘が 0 件または Minor Fix 完了のみなら Approved とし、review-improvement-analyst へ渡す入力を整理する。

## Checks

- すべての対象 TST に REQ / DSG が結び付いている。
- テスト実行結果が Test Plan の期待結果と対応している。
- テスト観点や期待結果の不足を Test 修正だけで閉じていない。
- 実装不備を Test Plan 修正として扱っていない。
- 失敗原因が未調査のまま戻し先を決めていない。
- 非軽微指摘に REV / REQ / DSG / TST の欠落がない。
- Review Result は Approved / Rework のどちらかで、根拠が findings table から追える。

## Output

- Gate Type: Test Review のレビュー記録
- Review Result: Approved / Rework
- TST execution coverage summary
- Failure and blocked-test summary
- Traceability Check Summary with untraced Requirement IDs and Design Element IDs
- Findings table aligned to `templates/review-record.md`
- Handoff recommendation: review-improvement-analyst / test-executor / test-planner / implementation-executor / implementation-planner / detailed-design-author / Minor Fix

## References

- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [Review record template](../../../templates/review-record.md)
- [Test feedback handling](../test-execution-feedback-handling/SKILL.md)
- [Return target classification](../return-target-classification/SKILL.md)