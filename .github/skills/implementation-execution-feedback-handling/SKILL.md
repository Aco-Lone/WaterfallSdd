---
name: implementation-execution-feedback-handling
description: "Use when classifying OpenSpec Waterfall implementation review findings, linking them to REQ/DSG/PLN/REV, and deciding whether they return to Design, Plan, Code, or Minor Fix."
user-invocable: false
---

# Implementation Execution Feedback Handling

## When to Use

- G2 承認後の実装レビュー指摘を整理するとき
- 実装完了後のフィードバックを REQ / DSG / PLN / REV に結び付けるとき
- 指摘を Design / Plan / Code / Minor Fix のどこで閉じるかを決めるとき
- 実装の修正作業そのものは、Superpowers の `receiving-code-review`、`systematic-debugging`、`test-driven-development`、`verification-before-completion` に委ねる前提で、OpenSpec Waterfall 固有の戻し先判定だけを行うとき

## Procedure

1. 対象指摘を Review ID 単位で正規化し、関連する Requirement IDs、Design Element IDs、Plan Item IDs を収集する。
2. 指摘が要件充足、クラス責務、アクター分割、処理手順、異常系、テスト観点を変えるなら Design に分類する。
3. 指摘が実装順序、作業粒度、環境準備、Plan item の分割だけで閉じるなら Plan に分類する。
4. 承認済み設計・計画に沿うための実装コード修正だけで閉じるなら Code に分類する。
5. 誤字脱字、レビュー記録のリンク、章番号、表記だけなら Minor Fix に分類する。
6. Design に戻す場合は、影響範囲の Implementation Plan と Test Plan の再レビューを前提にする。
7. Code に分類した場合は、TDD と verification-before-completion を必須にして修正担当へ渡す。
8. 分類結果と根拠を記録し、非軽微指摘は REQ / DSG / PLN / REV の対応が追える状態に保つ。

## Checks

- すべての非軽微指摘に Review ID、Requirement IDs、Design Element IDs、Plan Item IDs が付いている。
- Requirement 充足の変化や責務・アクター・処理手順・異常系・テスト観点の変更を Plan や Minor Fix に落としていない。
- 実装順序や粒度調整だけの指摘を Design に上げていない。
- Code 修正は approved design / plan の範囲に収まり、TDD と verification-before-completion を伴っている。
- Design 差戻し後は、影響範囲の Implementation Plan / Test Plan を再レビューする。
- Minor Fix は文面・リンク・章番号・表記の修正に限定する。
- レビュー記録の戻し先判定が、workflow-approval-gate-definition の G1 / G2 ルールと矛盾していない。

## References

- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [Review record template](../../../templates/review-record.md)
- [Defect classification](../defect-classification/SKILL.md)
- [Return target classification](../return-target-classification/SKILL.md)
