---
name: design-gate-review
description: "Use when performing the G1 design review gate for a detailed design against approved subsystem requirements and traceability rules"
user-invocable: false
---

# Design Gate Review

## When to Use

- G1 設計書レビューを実施するとき
- 設計へ戻す指摘か軽微修正かを判定したいとき
- 未トレース要件 ID を検出したいとき

## Procedure

1. 仕様、詳細設計書、ゲート定義を読む。
2. 要件反映、責務分割、依存方向、アクティビティ整合を確認する。
3. エラー設計、テスト設計、テスタビリティを確認する。
4. 未トレース要件 ID を集計する。
5. 各指摘を Design または Minor Fix に分類する。

## Checks

- 要件漏れ・要件解釈の誤りがない。
- クラス構成と責務分割が妥当である。
- アクティビティ図と本文が整合している。
- 未トレース要件 ID が 0 件である。

## References

- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [Review record template](../../../templates/review-record.md)