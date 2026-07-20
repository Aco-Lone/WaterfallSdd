---
name: defect-classification
description: "Use when classifying review findings as design return, plan-only closure, or minor fix based on impact to requirement fulfillment, structure, or execution detail"
user-invocable: false
---

# Defect Classification

## When to Use

- レビュー指摘の戻し先で迷うとき
- 設計へ戻すか、プランで閉じるか、軽微修正かを決めたいとき

## Decision Rules

- 要件の満たし方が変わるなら Design
- クラス責務、アクター分割、処理手順、異常系、テスト観点が変わるなら Design
- 実装順序、環境準備、粒度、担当割り、参照補足だけで解決できるなら Plan
- 誤字脱字、図表レイアウト、参照リンク、章番号だけなら Minor Fix

## Checks

- クラス名やメソッド名の変更は Minor Fix にしない。
- テスト観点の追加削除は Minor Fix にしない。
- エラー条件や分岐条件の変更は Minor Fix にしない。

## References

- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [OpenSpec modification design](../../../docs/designs/2026-06-07-openspec-modification-design.md)