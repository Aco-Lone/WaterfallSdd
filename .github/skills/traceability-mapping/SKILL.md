---
name: traceability-mapping
description: "Use when building or repairing mechanical traceability across requirement IDs, design element IDs, plan item IDs, test IDs, and review IDs"
user-invocable: false
---

# Traceability Mapping

## When to Use

- REQ、DSG、PLN、TST、REV の対応表を作るとき
- 未トレース要件や孤立 ID を検出したいとき
- 承認ゲート前に機械的な追跡性を確認したいとき

## Procedure

1. 対象文書から各 ID を列挙する。
2. REQ -> DSG -> PLN -> TST の対応を埋める。
3. REV には影響する REQ と DSG または PLN を紐付ける。
4. 変更を扱う場合は spec delta の各 REQ を impact map の Affected csproj と DSG / PLN / TST へ対応づける。
5. 重複 ID、孤立 ID、未参照 ID を洗い出す。
6. 未トレース件数を明示してレビューへ渡す。

## Checks

- 要件 ID が一意である。
- 未トレース要件 ID が 0 件である。
- G2 前は未トレース設計要素 ID が 0 件である。
- spec delta の各 REQ が impact map に対応づけられている。

## References

- [Detailed design template](../../../templates/detailed-design.md)
- [Implementation plan template](../../../templates/implementation-plan.md)
- [Test plan template](../../../templates/test-plan.md)
- [Review record template](../../../templates/review-record.md)
- [Impact map template](../../../templates/impact-map.md)