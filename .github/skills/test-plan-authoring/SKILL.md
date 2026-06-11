---
name: test-plan-authoring
description: "Use when converting approved detailed design into a csproj-based test plan without changing design decisions"
user-invocable: false
---

# Test Plan Authoring

## When to Use

- 承認済み詳細設計書からテストプランを起こすとき
- 設計を変えずに実行可能なテスト計画へ落としたいとき

## Procedure

1. 承認済み詳細設計書を読む。
2. テスト観点ごとに test item を作り、TST ID を振る。
3. 前提条件に基づいてテスト実行順序を並べる。
4. テストデータ、環境準備、リスクを加える。
5. REQ、DSG、TST の対応を明示する。

## Checks

- 設計判断を上書きしない。
- 各 test item が requirement ID と design element ID を持つ。
- 実行単位として粗すぎず細かすぎない。

## References

- [Test plan template](../../../templates/test-plan.md)
- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)