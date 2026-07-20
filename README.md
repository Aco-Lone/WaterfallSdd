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
- `docs/guides`
- `scripts/openspec-bootstrap-hook.ps1`
- `scripts/traceability-hook.ps1`
- `scripts/traceability-validator.ps1`
- `scripts/openspec-archive.ps1`
- `scripts/knowledge-index.ps1`
- `scripts/knowledge-context-manifest.ps1`
- `templates/detailed-design.md`
- `templates/implementation-plan.md`
- `templates/review-record.md`
- `templates/skill.md`
- `templates/subsystem-spec.md`
- `templates/test-plan.md`
- `templates/change-proposal.md`
- `templates/spec-delta.md`
- `templates/impact-map.md`
- `templates/glossary-term.md`
- `templates/business-rule.md`
- `templates/adr.md`
- `templates/knowledge-delta.md`
- `templates/knowledge-index.md`
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
3. 仕様文書は [docs/designs/](docs/designs/) に、補助ガイドは [docs/guides/](docs/guides/) に配置します。
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

## 変更管理（OpenSpec change と archive）

継続的な仕様変更は baseline と change を分離して扱います。

- `openspec/specs/subsystem-spec.md` は承認済み要件の baseline（正本）です。
- 進行中の変更は `openspec/changes/<change-id>/` で扱い、`proposal.md` / `spec-delta.md` / `impact-map.md` / `reviews/` を置きます。
- `spec-delta.md` は baseline への差分を ADDED / MODIFIED / REMOVED で記録します。baseline は変更中に直接編集しません。
- `impact-map.md` は影響する csproj と DSG / PLN / TST の ID を参照として持ち、設計・プラン・テスト本文は複製しません。
- 全ゲート通過後に archive を明示実行し、spec delta を baseline へ反映して change を退避します。

```powershell
pwsh -File scripts/openspec-archive.ps1 <change-id>
```

archive は前提条件（proposal が Approved、spec-delta と impact-map が検証パス）を満たさない限り拒否します。詳細は [workflow-approval-gate-definition.md](workflow-approval-gate-definition.md) の G3 アーカイブゲートを参照してください。

## ナレッジ管理（用語・業務ルール・設計判断）

ドメイン知識と設計判断は種類別の正本を ID 参照で成果物へ接続します。詳細は [workflow-approval-gate-definition.md](workflow-approval-gate-definition.md) の第16章と [.github/skills/knowledge-context-resolution/SKILL.md](.github/skills/knowledge-context-resolution/SKILL.md) を参照してください。

- 用語は `openspec/knowledge/glossary/<TERM>.md`、業務ルールは `openspec/knowledge/business-rules/<RULE>.md` に項目単位で正本を置きます。
- 重要な設計判断は `openspec/decisions/ADR-####-<slug>.md`（リポジトリ全体で連番）に置きます。Accepted ADR は不変記録として扱い、新しい ADR から `Superseded By` で置換します。
- `openspec/knowledge/index.md` は正本から生成します。手書きせず、変更後に再生成します。
- 進行中の用語・ルール変更は `openspec/changes/<change-id>/knowledge-delta.md` に ADDED / MODIFIED / REMOVED で記録します。baseline は G3 アーカイブでのみ更新します。
- Subsystem Spec の Related Knowledge と Detailed Design の Related Knowledge / Decision Record IDs で知識を ID 参照します。本文は複製しません。

雛形は [templates/glossary-term.md](templates/glossary-term.md)、[templates/business-rule.md](templates/business-rule.md)、[templates/adr.md](templates/adr.md)、[templates/knowledge-delta.md](templates/knowledge-delta.md)、[templates/knowledge-index.md](templates/knowledge-index.md) を使用します。

```powershell
pwsh -File scripts/knowledge-index.ps1
pwsh -File scripts/knowledge-context-manifest.ps1 <change-id> <phase> <KnowledgeId> [<KnowledgeId> ...]
```

AI は明示 ID 参照を正規の取得経路とし、全文検索は候補発見に限定します。ゲートやレビュー時には Context Manifest を生成し、承認時から判断根拠が変化していないか確認します。archive は spec delta に加えて knowledge delta を baseline へ反映し、Accepted ADR を移送し、Knowledge Index を再生成します。