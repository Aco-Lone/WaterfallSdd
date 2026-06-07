---
name: acceptance-criteria-check
description: "Use when validating whether subsystem requirements have observable, testable acceptance criteria tied to requirement IDs"
user-invocable: false
---

# Acceptance Criteria Check

## When to Use

- 要件はあるが受け入れ条件が弱いとき
- 要件 ID ごとに判定可能な完了条件を揃えたいとき
- G1 前に仕様の曖昧さを減らしたいとき

## Procedure

1. 要件 ID ごとに受け入れ条件を確認する。
2. 条件が観測可能か、成功/失敗を判定できるかを見る。
3. 正常系、異常系、境界条件の抜けを洗い出す。
4. 判定不能な条件は未決事項として戻す。

## Checks

- 各要件 ID に少なくとも 1 つの受け入れ条件がある。
- 「適切」「十分」などの曖昧語だけで終わっていない。
- 将来のテスト設計に落とせる粒度で書かれている。

## References

- [Subsystem spec template](../../../templates/subsystem-spec.md)
- [Review record template](../../../templates/review-record.md)