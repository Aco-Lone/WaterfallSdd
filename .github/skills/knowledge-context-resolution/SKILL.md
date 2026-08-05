---
name: knowledge-context-resolution
description: "Use when resolving which glossary terms, business rules, and ADRs an OpenSpec Waterfall task must read, using deterministic ID references before full-text search"
user-invocable: false
---

# Knowledge Context Resolution

## When to Use

- 対象工程で AI が読むべき TERM / RULE / ADR を決定的に決めるとき
- 成果物が参照すべき知識の正本パスを解決するとき
- 承認時と現在で判断根拠が変化していないか確認するとき

## Authority Order

矛盾時は上位を優先し、上位を下位で上書きしない。ADR は REQ / RULE を上書きしない。

1. 現在の change で承認済みの delta
2. baseline の Active な REQ / RULE / TERM
3. Accepted かつ未置換の ADR
4. 承認済み Detailed Design
5. 承認済み Implementation Plan / Test Plan
6. Review Record と実行結果
7. 実装コードから推測した挙動

## Procedure

1. 作業対象の change ID、subsystem、Requirement ID、Design Element ID を特定する。
2. openspec/knowledge/index.md（OKF `type: bundle`）から対象 ID の正本パスを解決する。
3. REQ の Related Knowledge から TERM / RULE を取得する。
4. DSG の Related Knowledge と Decision Record IDs から Accepted ADR を取得する。
5. 各正本ファイルの frontmatter から `status`、`effective_from` / `effective_until`、`supersedes` を評価する。Obsolete / Superseded / Rejected は現行判断に使わない。
6. 未解決参照がある場合だけ、関連用語・タグ・ID で全文検索する。
7. 全文検索で発見した未参照知識は候補として提示し、暗黙に正本として採用しない。
8. 成果物へ使用した Knowledge ID と ADR ID を記録する。
9. ゲートまたはレビュー時は scripts/knowledge-context-manifest.ps1 で Context Manifest を生成する。

## OKF and Agent Auto-Update

- 正本（TERM / RULE / ADR）と index / log は OKF 準拠とする。メタ情報は Markdown 表でなく YAML frontmatter（`type` 必須、`id` はファイル名と一致）に一本化する。
- 区分 A（承認不要）: `index.md` の再生成、`log.md` への追記、frontmatter の機械的整合、トレーサビリティと OKF 妥当性の検証。scripts/knowledge-index.ps1 が index.md（`type: bundle`）と log.md（`type: changelog`）を生成・追記する。
- 区分 B（Draft 起票・人間承認）: 新規 TERM / RULE / ADR を `status: Draft` で起票、change 配下 knowledge-delta.md への ADDED / MODIFIED / REMOVED 追記。
- 区分 C（禁止）: 承認前 Draft で baseline を直接更新、Accepted ADR 本文の書き換え、コードだけからの業務ルール自動承認、会話履歴を正本として書き込むこと。

## Per-Phase Scope

| 工程 | 必須コンテキスト | 制約 |
| --- | --- | --- |
| Subsystem Spec | TERM、RULE、根拠資料 | 不足する業務ルールを推測せず未決事項にする |
| Detailed Design | 承認 REQ、TERM、RULE、関連 ADR | 重大な新判断には Draft ADR を要求する |
| G1 Review | 設計時の参照閉包を独立に再解決 | 矛盾、未参照判断、廃止 ADR 利用を検出する |
| Implementation / Test Plan | 承認済み DSG の参照閉包 | 新しい設計判断をプランへ追加しない |
| Implementation / Test | 対象 PLN / TST の参照閉包 | 対象外知識を暗黙に一般化しない |
| Implementation / Test Review | 承認時の根拠集合と実変更 | 根拠のすり替わりと stale context を検出する |

## Checks

- 明示 ID を正規ルートとし、全文検索は候補発見に限定する。
- 会話履歴や memory を知識の正本にしない。
- 未解決参照や競合が残ったまま承認へ進まない。
- 使用した Knowledge ID / ADR ID を成果物または Manifest に記録する。

## References

- [Knowledge index template](../../../templates/knowledge-index.md)
- [Knowledge log template](../../../templates/knowledge-log.md)
- [Glossary term template](../../../templates/glossary-term.md)
- [Business rule template](../../../templates/business-rule.md)
- [ADR template](../../../templates/adr.md)
- [Knowledge delta template](../../../templates/knowledge-delta.md)
- [Workflow and gate definition](../../../workflow-approval-gate-definition.md)
