---
name: review-driven-improvement
description: "Use when implementation review results need to be classified, recurring mistake causes identified, and workspace skills or custom instructions updated to prevent recurrence"
user-invocable: false
---

# Review Driven Improvement

## When to Use

- 実装レビュー完了後に、レビュー結果を再発防止へ結び付けたいとき
- 同種の指摘が複数回発生し、頻出するミスの原因を分類したいとき
- skill と custom instructions のどちらを更新すべきか切り分けたいとき

## Procedure

1. [Workflow and gate definition](../../../workflow-approval-gate-definition.md) と対象のレビュー記録を読む。
2. 各指摘を Review ID、Requirement ID、Design Element ID、Plan Item ID と結び付けたまま正規化する。
3. 指摘を要件読解不足、トレーサビリティ記載漏れ、戻し先判定誤り、工程逸脱、出力形式不整合、レビュー観点漏れなどの原因分類へまとめる。
4. 頻度と重大度を見て、表面的な症状ではなく根本原因を特定する。
5. 根本原因が工程固有なら skill、横断的な既定動作なら custom instructions、局所不具合なら成果物修正のみを選ぶ。
6. 更新案には、根拠となる Review ID、変更対象ファイル、期待する再発防止効果を明記する。

## Checks

- すべての改善案が 1 件以上の Review ID を根拠にしている。
- 表面的な記述揺れではなく、再発原因に対して変更対象を選んでいる。
- 同じ規則を skill と custom instructions の両方へ重複記載していない。
- custom instructions が未作成なら、新規作成の要否を明示している。

## References

- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [Review record template](../../../templates/review-record.md)
- [Defect classification](../defect-classification/SKILL.md)
- [Return target classification](../return-target-classification/SKILL.md)