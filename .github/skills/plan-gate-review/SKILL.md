---
name: plan-gate-review
description: "Use when performing the G2 plan review gate for an implementation and test plan against approved design and traceability rules"
user-invocable: false
---

# Plan Gate Review

## When to Use

- G2 プランレビューを実施するとき
- プラン内で閉じる指摘か設計差戻しかを判定したいとき
- 未トレース要件 ID や未トレース設計要素 ID を検出したいとき

## Procedure

1. 承認済み詳細設計書、プラン、ゲート定義を読む。
2. 設計責務をプランが保持しているか確認する。
3. 実装順、テスト順、環境準備、粒度、並行計画を確認する。
4. 未トレース要件 ID と未トレース設計要素 ID を集計する。
5. 各指摘を Design、Plan、Minor Fix に分類する。

## Checks

- 設計判断をプランが上書きしていない。
- 未トレース要件 ID が 0 件である。
- 未トレース設計要素 ID が 0 件である。

## References

- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [Review record template](../../../templates/review-record.md)