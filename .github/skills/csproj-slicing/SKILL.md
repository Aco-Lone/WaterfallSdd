---
name: csproj-slicing
description: "Use when decomposing approved design into csproj-based work units, sequencing dependencies, and identifying what can run in parallel"
user-invocable: false
---

# Csproj Slicing

## When to Use

- csproj 単位で作業を分けるとき
- 実装順と並行可能範囲を整理したいとき
- 1 つの設計書から複数の作業単位を切り出したいとき

## Procedure

1. 対象 csproj とそこに属する設計要素を列挙する。
2. 依存関係が強い要素を同じ作業単位へ寄せる。
3. 依存のない単位だけを並行候補にする。
4. 各単位へ plan item ID を割り当てる。
5. 単位ごとに関連する REQ、DSG、TST を付ける。

## Checks

- 並行可能とした単位に依存関係の隠れ漏れがない。
- 作業単位が csproj の責務境界を壊さない。
- トレーサビリティが単位ごとに残る。

## References

- [Implementation and test plan template](../../../templates/implementation-test-plan.md)
- [OpenSpec modification design](../../../docs/superpowers/specs/2026-06-07-openspec-modification-design.md)