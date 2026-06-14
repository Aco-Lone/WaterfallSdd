---
name: implementation-review
description: "Use when performing post-G2 implementation review against approved Detailed Design, Implementation Plan, execution results, and OpenSpec traceability"
user-invocable: false
---

# Implementation Review

## When to Use

- G2 承認後の実装完了結果をレビューするとき
- 実装が承認済み Detailed Design と Implementation Plan に沿っているか確認するとき
- PLN / REQ / DSG / REV の対応を保ったまま、指摘を Design / Plan / Code / Minor Fix に分類するとき
- 実装レビュー後に test-executor へ進めるか、設計・計画・コード修正へ戻すかを決めるとき

## Procedure

1. 承認済み Detailed Design、Implementation Plan、Test Plan、G2 review record、implementation execution result、変更ファイル、レビュー記録テンプレート、ワークフロー定義を読む。
2. すべての対象 PLN が Complete / Blocked / Not Executed のいずれかで記録され、REQ / DSG と対応しているか確認する。
3. 変更内容が承認済み設計のクラス責務、依存方向、処理手順、異常系、テスト設計を上書きしていないか確認する。
4. 実装結果が Implementation Plan の作業粒度、順序、完了条件、環境前提から逸脱していないか確認する。
5. 検証結果が PLN ごとに記録され、失敗または未実行の理由が traceability とともに残っているか確認する。
6. 非軽微指摘には Review ID、Requirement IDs、Design Element IDs、Plan Item IDs を付与する。
7. 指摘の戻し先は `implementation-execution-feedback-handling` で Design / Plan / Code / Minor Fix に分類する。
8. Design または Plan に戻す指摘がある場合は、影響範囲の Implementation Plan と Test Plan の再レビュー要否を明記する。
9. Code に戻す指摘がある場合は、修正対象 PLN、期待する検証、再レビュー条件を記録する。
10. 指摘が 0 件または Minor Fix 完了のみなら Approved とし、test-executor へ渡す入力を整理する。

## Checks

- すべての対象 PLN に REQ / DSG が結び付いている。
- 実装で未承認の設計判断を追加していない。
- 設計上の問題を Code 修正だけで閉じていない。
- 実装順序や作業分割の問題を Code 指摘として扱っていない。
- 検証未実行や失敗を Approved に含めていない。
- 非軽微指摘に REV / REQ / DSG / PLN の欠落がない。
- Review Result は Approved / Rework のどちらかで、根拠が findings table から追える。

## Output

- Gate Type: Implementation Review のレビュー記録
- Review Result: Approved / Rework
- PLN coverage summary
- Traceability Check Summary with untraced Requirement IDs and Design Element IDs
- Findings table aligned to `templates/review-record.md`
- Handoff recommendation: test-executor / implementation-executor / implementation-planner / detailed-design-author / Minor Fix

## References

- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [Review record template](../../../templates/review-record.md)
- [Implementation feedback handling](../implementation-execution-feedback-handling/SKILL.md)
- [Return target classification](../return-target-classification/SKILL.md)