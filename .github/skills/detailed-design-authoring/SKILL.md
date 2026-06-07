---
name: detailed-design-authoring
description: "Use when turning an approved subsystem specification into a detailed design with class structure, actor-partitioned activity flow, error design, test design, and requirement traceability"
user-invocable: false
---

# Detailed Design Authoring

## When to Use

- 承認済み仕様から詳細設計書を起こすとき
- クラス構成、アクティビティ図、エラー設計、テスト設計を揃えるとき
- 要件 ID から設計要素 ID への対応を作るとき

## Procedure

1. 承認済み仕様と要件 ID を読む。
2. 要件ごとに設計要素 ID を割り当てる。
3. クラス構成と責務境界を定義する。
4. アクターまたはクラス単位に分割したアクティビティを定義する。
5. エラー設計とテスト設計を追加する。
6. 未解決論点は open issue として残す。

## Checks

- すべての要件 ID が少なくとも 1 つの設計要素 ID と結び付く。
- 実装順序や担当割りを設計書に混ぜない。
- 本文、図、エラー設計、テスト設計が矛盾しない。

## References

- [Detailed design template](../../../templates/detailed-design.md)
- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)