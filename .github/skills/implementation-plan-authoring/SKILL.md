---
name: implementation-plan-authoring
description: "Use when converting approved detailed design into a csproj-based implementation plan without changing design decisions"
user-invocable: false
---

# Implementation Plan Authoring

## When to Use

- 承認済み詳細設計書から実装プランを起こすとき
- 設計を変えずに実行可能な実装計画へ落としたいとき

## Procedure

1. 承認済み詳細設計書を読む。
2. 設計要素ごとに plan item を作り、PLN ID を振る。
3. 依存関係に基づいて実装順序を並べる。
4. 環境準備、並行可否、リスクを加える。
5. REQ、DSG、PLN の対応を明示する。

## Checks

- 設計判断を上書きしない。
- 各 plan item が requirement ID と design element ID を持つ。
- 実行単位として粗すぎず細かすぎない。

## References

- [Implementation plan template](../../../templates/implementation-plan.md)
- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)