---
name: change-impact-mapping
description: "Use when building the impact map for a change, identifying which csproj design, plan, and test artifacts a spec delta affects, and deciding which need re-review"
user-invocable: false
---

# Change Impact Mapping

## When to Use

- spec-delta.md から影響範囲を impact-map.md へ展開するとき
- 変更が触る csproj と設計要素 ID、プラン項目 ID、テスト ID を特定するとき
- 再レビューが必要な成果物を決めるとき

## Procedure

1. spec-delta.md の各要件 ID と Operation を読む。
2. その要件を実現している csproj の baseline 設計・プラン・テストを特定する。
3. 影響する DSG / PLN / TST の ID を impact-map.md へ参照として記録する。内容は複製しない。
4. ADDED と MODIFIED は影響 csproj を必ず1件以上記す。
5. REMOVED は Re-review Required を Yes にし、下流参照の掃除を再レビュー対象にする。
6. 再レビューが必要な行に Gate Record の参照を残す。

## Checks

- spec-delta.md の全要件 ID が impact-map.md に現れる。
- ADDED と MODIFIED の行に影響 csproj がある。
- REMOVED の行は Re-review Required が Yes である。
- 再レビューが必要な行に Gate Record の参照がある。
- impact-map.md は ID の参照だけを持ち、設計・プラン・テスト本文を複製しない。

## References

- [Impact map template](../../../templates/impact-map.md)
- [Spec delta template](../../../templates/spec-delta.md)
- [Traceability mapping skill](../traceability-mapping/SKILL.md)
- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
