---
name: test-execution-feedback-handling
description: "Use when test review findings or test failures need OpenSpec Waterfall-specific return-target classification across REQ / DSG / TST / REV"
user-invocable: false
---

# Test Execution Feedback Handling

## When to Use

- テストレビュー指摘やテスト失敗の戻し先を決めるとき
- OpenSpec Waterfall のトレーサビリティに合わせて、指摘を REQ / DSG / TST / REV と結びたいとき
- 詳細設計へ戻すか、Test Plan 修正で閉じるか、テストコード修正か、実装コード修正か、Minor Fix かを判定したいとき

## Procedure

1. 指摘がどの成果物に属するかを確認する。
2. 要件充足、テスト観点、期待結果、異常系、クラス責務、処理手順の変更が必要なら Design に戻す。
3. テスト順序、前提条件、テストデータ、環境準備、TST 分割だけで閉じるなら Plan に分類する。
4. 承認済み Test Plan に沿うためのテストコード・テストデータ修正だけなら Test に分類する。
5. 承認済み設計に沿うための production code 修正だけなら Code に分類する。
6. 誤字脱字、レビュー記録リンク、章番号、表記だけなら Minor Fix に分類する。
7. 非軽微指摘は必ず Review ID、Requirement IDs、Design Element IDs、Test IDs をそろえて記録する。
8. Design に戻す場合は、影響範囲の Implementation Plan と Test Plan の再レビューを前提にする。
9. Test または Code 修正に進む場合は、原因調査は systematic-debugging、修正実装は test-driven-development、完了判定は verification-before-completion に委ねる。

## Checks

- Design 判定は、要件充足、テスト観点、期待結果、異常系、クラス責務、処理手順のいずれかに変更が必要なときだけにする。
- Plan 判定は、テスト順序、前提条件、テストデータ、環境準備、TST 分割だけで閉じる指摘に限定する。
- Test 判定は、承認済み Test Plan に沿うためのテストコード・テストデータ修正だけに限定する。
- Code 判定は、承認済み設計に沿うための production code 修正だけに限定する。
- Minor Fix 判定は、表記や参照の修正だけに限定する。
- 非軽微指摘に Review ID、Requirement IDs、Design Element IDs、Test IDs の欠落がないか確認する。
- Design 返却後は、影響範囲の Implementation Plan と Test Plan の再レビューを必須扱いにする。
- Test / Code 修正では、systematic-debugging または test-driven-development と verification-before-completion の適用を省略しない。

## References

- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
- [Review record template](../../../templates/review-record.md)
- [Defect classification](../defect-classification/SKILL.md)
- [Return target classification](../return-target-classification/SKILL.md)
