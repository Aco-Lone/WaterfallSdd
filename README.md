# WaterfallSdd

OpenSpec と Superpowers の考え方を土台にした、仕様駆動開発向けのエージェント運用プラグインです。

## 概要

このプラグインは、AI に自由に実装させるのではなく、工程ごとの責務を分けて、承認を通した成果物だけを次工程へ進めることを目的にしています。設計思想は次のとおりです。

- 仕様、設計、計画、テストを分離し、各成果物の責務を明確にする
- 要件 ID を起点にして、設計・計画・テスト・レビューの対応関係を機械的に追えるようにする
- 設計完了前に実装へ進ませない Waterfall 寄りのゲート制御を行う
- レビュー指摘を「設計へ戻すべきもの」と「プラン内で閉じるもの」に分類し、差し戻し先を明確にする

想定しているのは、Copilot や同等のエージェントに対して、場当たり的な対話ではなく、手順と成果物を守らせる運用です。

## インストール方法

このリポジトリは実行ライブラリではなく、現在のワークスペースへ OpenSpec Waterfall 用の資産を配置する bootstrap package として npm で導入できます。

```powershell
npm install @aco-lone/waterfall-sdd-bootstrap
```

install 時の postinstall で、実行したワークスペース直下へ次の資産を追加します。

- `.github/agents`
- `.github/hooks`
- `.github/prompts`
- `.github/skills`
- `docs/superpowers/guides`
- `scripts/openspec-bootstrap-hook.ps1`
- `scripts/traceability-hook.ps1`
- `scripts/traceability-validator.ps1`
- `templates/detailed-design.md`
- `templates/implementation-plan.md`
- `templates/review-record.md`
- `templates/skill.md`
- `templates/subsystem-spec.md`
- `templates/test-plan.md`
- `README.md`
- `spec-driven-development-options.md`
- `workflow-approval-gate-definition.md`

既に同名ファイルが存在する場合は上書きせず、追加できたものだけを配置します。既存の `.github/` カスタマイズや README を壊さないことを優先するためです。

このパッケージは PowerShell ベースの hook を含むため、Windows 環境を前提にしています。トレーサビリティ検証を実行する場合は、必要に応じて Pester を利用してください。

```powershell
Install-Module Pester -Scope CurrentUser
```

開発や資産更新そのものを行いたい場合は、従来どおりこのリポジトリを Git で取得して作業してください。npm 版は利用先ワークスペースへ資産を展開するための配布形態です。

## 始め方

1. まず [workflow-approval-gate-definition.md](workflow-approval-gate-definition.md) と [spec-driven-development-options.md](spec-driven-development-options.md) を読み、運用ルールを確認します。
2. [templates/](templates/) から必要な雛形を選び、対象の仕様に合わせて複製します。
3. 仕様文書は [docs/superpowers/specs/](docs/superpowers/specs/) に、補助ガイドは [docs/superpowers/guides/](docs/superpowers/guides/) に配置します。
4. 詳細設計書、実装プラン、テストプランを作成するときは、要件 ID と設計要素 ID の対応を明記します。
5. 仕上げに [scripts/traceability-validator.ps1](scripts/traceability-validator.ps1) で Markdown のトレーサビリティを確認し、必要に応じて [tests/TraceabilityValidator.Tests.ps1](tests/TraceabilityValidator.Tests.ps1) で検証ロジックを確認します。

## 主な構成

- [docs/](docs/) 仕様運用のガイドとワークフロー資料
- [templates/](templates/) 詳細設計書、実装プラン、テストプランなどの雛形
- [scripts/](scripts/) トレーサビリティ検証スクリプト
- [tests/](tests/) スクリプトの動作確認テスト
- ルートの Markdown ファイル 承認ゲートや運用方針の定義

## 補足

このプラグインでは、実装そのものよりも「何を、どの順序で、どの成果物に残すか」を揃えることを重視しています。まずは承認ゲートの流れとトレーサビリティの考え方を把握してから、各成果物を作成してください。