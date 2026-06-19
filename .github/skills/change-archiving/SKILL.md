---
name: change-archiving
description: "Use when a change has passed all gates and you need to apply its spec delta to the baseline subsystem spec and move the change folder into the archive"
user-invocable: false
---

# Change Archiving

## When to Use

- ひとつの change の全ゲートが承認され、baseline へ反映するとき
- spec-delta.md を baseline 仕様へ畳み込み、change を退避するとき
- 変更履歴を不変記録として残すとき

## Procedure

1. proposal.md の Status が Approved で、必要なゲート記録が承認済みであることを確認する。
2. spec-delta.md と impact-map.md がトレーサビリティ検証をパスしていることを確認する。
3. scripts/openspec-archive.ps1 を change ID 指定で実行する。
4. spec-delta が baseline の openspec/specs/subsystem-spec.md へ反映されたことを確認する。
   - ADDED は要件行が追記される。
   - MODIFIED は要件行が更新される。
   - REMOVED は要件行の Status が Obsolete になる。
5. 影響 csproj 成果物へ change ID とバージョンが刻印されたことを確認する。
6. change フォルダが openspec/changes/archive/ へ移動したことを確認する。

## Checks

- 前提条件を満たさない change は archive しない。
- archive は明示実行のスクリプトで行い、hook では実行しない。
- baseline の要件 ID は archive 後も一意である。
- 退避後の change フォルダは編集しない。不変記録として扱う。

## References

- [Change proposal template](../../../templates/change-proposal.md)
- [Spec delta template](../../../templates/spec-delta.md)
- [Impact map template](../../../templates/impact-map.md)
- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
