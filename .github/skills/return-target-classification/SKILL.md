---
name: return-target-classification
description: "Use when deciding the return target of a review finding between detailed design, implementation plan, test plan, or minor fix handling"
user-invocable: false
---

# Return Target Classification

## When to Use

- レビュー結果の差し戻し先を決めるとき
- 影響範囲に応じて Detailed Design へ戻すか、Plan で閉じるかを決めるとき

## Procedure

1. 指摘が要件充足や設計構造に影響するかを確認する。
2. 影響が設計構造に及ぶなら Detailed Design へ戻す。
3. 影響が実行順、準備、粒度、担当割りだけなら Plan で閉じる。
4. 影響が文面やレイアウトだけなら Minor Fix とする。

## Checks

- 要件 ID に影響する指摘は Design か Plan のいずれかに分類する。
- 影響する要件 ID を必ず記録する。
- 非軽微な設計変更後は影響範囲のプラン再レビューを前提にする。

## References

- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [Review record template](../../../templates/review-record.md)