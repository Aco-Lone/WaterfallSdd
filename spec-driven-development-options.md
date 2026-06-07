# 仕様駆動ライブラリ比較メモ

Waterfall から段階的に仕様駆動へ移行する前提で、候補を整理したメモ。

## 結論

最初の土台としては **Superpowers** が有力。理由は、仕様そのものを管理する専用品というより、`brainstorming`、`writing-plans`、`executing-plans`、`verification-before-completion` のように、工程を標準化する運用基盤として使いやすいから。

仕様成果物をより厳密に管理したい場合は **SpecKit Assistant** を追加候補にするのがよい。Waterfall 的な「工程固定」「承認ゲート」「成果物の明確化」に強い。

## 候補一覧

| 候補 | 位置づけ | 特徴 | カスタマイズのメリット | カスタマイズのデメリット |
| --- | --- | --- | --- | --- |
| Superpowers | ワークフロー基盤 | AI の進め方を標準化する。工程ごとのルールを作りやすい。 | Waterfall の工程をそのまま分解しやすい。レビューや検証を必須化しやすい。 | spec / plan / task の成果物管理は自前設計が必要。 |
| SpecKit Assistant | 仕様駆動オーケストレーター | constitution → spec → plan → tasks → implementation を段階的に扱える。 | 仕様文書と工程管理を一体化しやすい。可視化や承認フローに向く。 | 仕組みが強めなので、独自工程を足すと重くなりやすい。 |
| SpecKit Companion | SpecKit の伴走役 | GitHub SpecKit のワークフローに寄せやすい。比較的軽量。 | 既存の Waterfall 文書体系に合わせて調整しやすい。 | ガイド力は弱めで、工程統制は別途補う必要がある。 |
| Kiro for Claude Code | Claude Code 向け spec-driven | 実装補助と仕様作成を近い距離で回しやすい。 | AI 主導の試行錯誤に向く。 | Waterfall 的な厳格管理には追加のテンプレートや承認ルールが必要。 |
| Kiro for Copilot | Copilot 向け spec-driven | requirements、design、task tracking をコードとつなげやすい。 | Copilot 中心の開発に寄せやすい。 | 仕様工程を厳密に固定するには周辺ルールが要る。 |
| OpenSpec for Copilot | オープン寄りの仕様管理 | 仕様の書式や流れを自分たちの運用に合わせやすい。 | ベンダー色を薄めて運用しやすい。 | 初期設計コストが高め。 |
| Copilot Specs | Copilot 向け仕様管理 | requirements / design / task management を扱う。 | 要求とタスクの紐付けを作りやすい。 | SpecKit 系ほど工程統制は強くない。 |

## Superpowers を選ぶ理由

- 工程を分けて進める思想が Waterfall に合う
- 仕様駆動の前段として、質問、計画、実行、検証の順を固定しやすい
- 既存の開発フローに後付けしやすい

## Superpowers の弱点

- 仕様書そのものを厳密に管理する機能は弱い
- テンプレートや承認ゲートは自分たちで設計する必要がある
- 成果物の粒度を揃えないと運用がぶれやすい

## 実務的なおすすめ

1. まずは Superpowers を土台にして、工程の固定化とレビュー規律を作る
2. 必要に応じて SpecKit Assistant を追加し、spec / plan / tasks を厳密化する
3. Copilot 中心なら Copilot Specs や Kiro 系を比較対象に入れる

## Waterfall 向けの運用イメージ

- 構想整理: brainstorming
- 仕様化: spec
- 計画化: plan
- 分解: tasks
- 実行: implementation
- 検証: verification

この順序を崩さないようにすると、Waterfall らしい制御がしやすい。
