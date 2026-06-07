---
name: subsystem-requirements-refinement
description: "Use when refining subsystem-level requirements from upper design, normalizing requirement statements, or assigning stable requirement IDs before subsystem specification drafting"
user-invocable: false
---

# Subsystem Requirements Refinement

## When to Use

- 上位設計の記述をサブシステム要件へ落とし直すとき
- 要件文が大きすぎる、混ざっている、曖昧なとき
- 要件 ID を採番または維持しながら仕様書へ移すとき

## Procedure

1. 上位設計、既存仕様、変更履歴を読む。
2. 要件を 1 行 1 意図の文へ正規化する。
3. 要件の意味が変わらない限り既存の要件 ID を維持する。
4. 新規要件だけに新しい要件 ID を採番する。
5. スコープ外と未決事項を分けて記録する。

## Checks

- 各要件が一意の要件 ID を持つ。
- 1 つの要件が複数の独立した振る舞いを抱えていない。
- 廃止要件は削除せず状態で表現する。
- 仕様本文より先にクラス設計へ踏み込まない。

## References

- [Subsystem spec template](../../../templates/subsystem-spec.md)
- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)