---
name: delta-operation-classification
description: "Use when recording a requirement change as a spec delta and deciding whether each requirement is ADDED, MODIFIED, or REMOVED against the baseline subsystem spec"
user-invocable: false
---

# Delta Operation Classification

## When to Use

- 仕様変更を spec-delta.md の Operation 列へ落とすとき
- ある要件 ID を ADDED / MODIFIED / REMOVED のどれにするか迷うとき
- baseline を直接編集せず差分として変更を表現するとき

## Procedure

1. baseline の openspec/specs/subsystem-spec.md で対象要件 ID の有無を確認する。
2. baseline に同じ要件 ID が無いなら ADDED とし、新しい要件 ID を採番する。
3. baseline に要件 ID があり内容を変えるなら MODIFIED とし、要件 ID は維持する。
4. baseline の要件を廃止するなら REMOVED とし、要件 ID は削除せず差分で表す。
5. 各行に Delta ID と Rationale を付け、影響は impact-map.md へ引き継ぐ。

## Checks

- Operation は ADDED / MODIFIED / REMOVED のいずれかである。
- ADDED の要件 ID は baseline に存在しない。
- MODIFIED と REMOVED の要件 ID は baseline に存在する。
- 意味が変わらない要件の ID は採番し直さない。
- baseline 仕様はこの工程では編集しない。更新は archive 操作だけが行う。

## References

- [Spec delta template](../../../templates/spec-delta.md)
- [Subsystem spec template](../../../templates/subsystem-spec.md)
- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
