# OpenSpec ナレッジ管理方針設計書

## 1. 目的

本書は、WaterfallSdd の導入先プロジェクトにおいて、ドメイン知識、業務ルール、設計判断、レビューから得た知見を継続的に蓄積し、仕様駆動開発と AI エージェントの作業で再利用するための方針を定義する。

本方針は、一般的な仕様駆動開発で用いられる次の考え方を組み合わせる。

- DDD のユビキタス言語による用語統一
- 業務ルールの明文化
- Architecture Decision Record（ADR）による設計判断の保存
- Docs as Code による Git 管理とレビュー
- ID ベースのトレーサビリティ
- レビュー知見から実行可能なルールへの段階的な昇格

## 2. 適用範囲

本方針の主対象は、WaterfallSdd を導入した各プロジェクトで管理するプロジェクト固有の知識とする。

対象に含めるものは次のとおり。

- ドメイン用語、同義語、禁止表現
- 業務ルール、条件、結果、例外、具体例
- アーキテクチャおよび重要な設計判断
- 要件、設計、計画、テスト、レビューとの参照関係
- 実装レビューやテストレビューから得られた再利用可能な知見
- AI エージェントが知識を取得、評価、利用するための規則

次のものは対象外とする。

- 一時的な会話履歴を知識の正本として扱うこと
- 実装コードだけから業務ルールを推測して自動承認すること
- 容易に変更可能な局所的実装判断をすべて ADR として記録すること
- プロジェクト固有の業務知識を WaterfallSdd 共通の skill や custom instructions へ直接複製すること

## 3. 現状と課題

既存成果物には、ナレッジ管理の起点となる記録欄が存在する。

- Subsystem Spec の `Rationale`
- Change Proposal の `Why and Context`
- Detailed Design の `Design Decisions and Open Issues`
- Review Record の原因分類と根本原因
- review-driven-improvement による再発防止ルールへの反映

一方、次の情報を横断的に管理する正本とライフサイクルが不足している。

- 複数の仕様やサブシステムで共有する用語
- 要件の背景となる業務ルールと例外
- 設計時に比較した選択肢と却下理由
- 設計判断の廃止、置換、失効の履歴
- 知識と REQ / DSG / PLN / TST / REV の機械的な対応
- AI が対象作業で読むべき知識を再現可能に決定する手順

これらを既存成果物へ個別に埋め込むだけでは、重複、更新漏れ、検索漏れが発生する。外部 Wiki のみで管理すると、仕様変更と知識変更の承認や履歴が分離する。このため、本方針ではリポジトリ内に種類別の正本を置き、ID 参照で既存成果物と接続する。

## 4. 基本原則

1. 知識は種類ごとに正本を分け、同じ本文を複数成果物へ複製しない。
2. ドメイン知識と設計判断を、REQ / DSG / PLN / TST / REV と ID で接続する。
3. baseline と進行中の change を分離し、承認前の知識で baseline を直接更新しない。
4. 承認済み ADR は書き換えず、新しい ADR から置換関係を記録する。
5. AI は明示 ID を正規の取得経路とし、全文検索は知識候補の発見に限定する。
6. AI の会話履歴や memory は補助キャッシュとして扱い、知識の正本にしない。
7. skill と custom instructions には知識本文ではなく、取得手順、優先順位、停止条件を記録する。
8. 自動検証は段階的に導入し、文書作成そのものが目的になることを避ける。
9. 知識量ではなく、再利用性、整合性、レビュー再発率によって運用効果を評価する。

## 5. 情報アーキテクチャ

導入先プロジェクトでは、次の構成を標準とする。

```text
openspec/
  knowledge/
    index.md
    glossary.md
    business-rules.md
  decisions/
    ADR-0001-<slug>.md
  changes/<change-id>/
    proposal.md
    spec-delta.md
    impact-map.md
    knowledge-delta.md
    decisions/
      ADR-xxxx-<slug>.md
    reviews/
      context-manifest-<phase>.json
```

### 5.1 Knowledge Index

`openspec/knowledge/index.md` は、人間と AI が知識を発見するための入口とする。

- ID
- 種別
- 短い概要
- Status
- Owner
- 正本ファイルへのリンク
- 関連 subsystem

Index は知識本文を保持せず、正本への参照だけを保持する。

### 5.2 Glossary

`openspec/knowledge/glossary.md` は、ユビキタス言語の正本とする。

各用語は次の情報を持つ。

- Term ID
- 正式名称
- 定義
- 同義語
- 禁止表現または非推奨表現
- 適用範囲
- 根拠
- Owner
- Status
- 有効期間

### 5.3 Business Rules

`openspec/knowledge/business-rules.md` は、複数要件から参照される業務ルールの正本とする。

各ルールは次の情報を持つ。

- Rule ID
- 条件
- 結果
- 例外
- 境界値または具体例
- 根拠
- 関連 Requirement ID
- Owner
- Status
- 有効期間

### 5.4 Architecture Decision Record

`openspec/decisions/ADR-xxxx-<slug>.md` は、重要な設計判断の正本とする。

各 ADR は次の情報を持つ。

- ADR ID
- Status: Draft / Proposed / Accepted / Superseded / Rejected
- Context
- Decision Drivers
- Considered Options
- Decision
- Rejected Options and Reasons
- Positive and Negative Consequences
- Related Requirement IDs
- Related Rule IDs
- Related Design Element IDs
- Supersedes / Superseded By
- Owner、承認者、決定日

ADR の作成対象は、複数の選択肢が存在し、将来の変更コスト、品質特性、責務境界、外部制約へ影響する判断に限定する。

### 5.5 Knowledge Delta

`openspec/changes/<change-id>/knowledge-delta.md` は、baseline の用語と業務ルールに対する変更差分を記録する。

Operation は Spec Delta と同様に次の 3 種類とする。

- `ADDED`: baseline に存在しない新しい TERM / RULE を追加する
- `MODIFIED`: 意味を維持したまま既存 TERM / RULE の内容を変更する
- `REMOVED`: 既存 TERM / RULE を削除せず Obsolete とする

意味が別物になる変更では既存 ID を再利用せず、新しい ID を採番する。

## 6. ID とトレーサビリティ

追加する ID 体系は次のとおり。

| ID | 対象 | 例 |
| --- | --- | --- |
| TERM | ドメイン用語 | AUTH-TERM-001 |
| RULE | 業務ルール | AUTH-RULE-001 |
| ADR | 設計判断 | AUTH-ADR-001 |

最低限、次の関係を追跡可能にする。

- TERM -> REQ
- RULE -> REQ
- REQ -> DSG
- RULE -> DSG
- ADR -> REQ
- ADR -> RULE
- ADR -> DSG
- DSG -> PLN
- DSG -> TST
- REV -> TERM / RULE / ADR / REQ / DSG / PLN / TST

Subsystem Spec には `Related Knowledge IDs` を追加する。Detailed Design には `Decision Record IDs` を追加し、既存の `Design Decisions and Open Issues` は ADR と未決事項の索引として扱う。

## 7. 情報の権威と競合処理

AI とレビュー担当者は、次の順序で情報の権威を評価する。

1. 現在の change で承認済みの delta
2. baseline の Active な REQ / RULE / TERM
3. Accepted かつ未置換の ADR
4. 承認済み Detailed Design
5. 承認済み Implementation Plan / Test Plan
6. Review Record と実行結果
7. 実装コードから推測した挙動

上位の成果物と下位の成果物が矛盾する場合、下位成果物で上位成果物を上書きしない。ADR は REQ や RULE を上書きできない。矛盾を検出した AI は、競合する ID、Status、正本パスを示し、推測による解消をせず差し戻し先を提示する。

## 8. ライフサイクル

### 8.1 変更開始

1. Change Proposal で変更理由と対象 subsystem を定義する。
2. 用語または業務ルールが変わる場合は Knowledge Delta を作成する。
3. 重要な設計判断が必要な場合は change 配下に Draft ADR を作成する。
4. Spec Delta と Knowledge Delta の相互参照を記録する。

### 8.2 要件と設計

1. 要件確定時に、関連する TERM / RULE を Requirement ID へ関連付ける。
2. 詳細設計時に、関連する Accepted ADR を Design Element ID へ関連付ける。
3. 設計中に新しい重要判断が必要になった場合は ADR を追加する。
4. 未承認の判断を確定事項として Detailed Design へ埋め込まない。

### 8.3 計画、実装、テスト

1. Implementation Plan と Test Plan は、承認済み設計の知識参照を引き継ぐ。
2. G2 後に新しい設計判断が必要になった場合、Plan または Code 内で閉じず Design へ戻す。
3. 実装とテストは、対象 PLN / TST が参照する知識だけを正規の判断根拠として使用する。

### 8.4 Archive

1. Knowledge Delta を baseline の Glossary / Business Rules へ反映する。
2. Accepted ADR を baseline の decisions 配下へ移送する。
3. 置換された ADR に `Superseded By` を設定する。
4. Knowledge Index を更新する。
5. archive 済み change は不変記録として扱う。

## 9. AI の知識取得方式

中小規模のリポジトリ内完結運用を前提とし、ベクトルデータベースを必須としない。AI は、決定的な ID 参照走査を基本とし、全文検索をフォールバックとして使用する。

### 9.1 取得手順

1. 作業対象の change ID、subsystem、Requirement ID、Design Element ID を特定する。
2. Knowledge Index から対象 ID の正本パスを解決する。
3. REQ の `Related Knowledge IDs` から TERM / RULE を取得する。
4. DSG の `Decision Record IDs` から Accepted ADR を取得する。
5. Status、有効期間、Supersedes を評価する。
6. 未解決参照がある場合だけ、関連用語、タグ、ID で全文検索する。
7. 全文検索で発見した未参照知識は候補として提示し、暗黙に正本として採用しない。
8. 成果物へ使用した Knowledge ID と ADR ID を記録する。

### 9.2 コンテキスト優先順位

コンテキスト量に制約がある場合は、次の順で優先する。

1. 対象 REQ と RULE
2. Accepted ADR
3. TERM
4. 対象 DSG / PLN / TST
5. 関連 Review Record
6. Superseded ADR と履歴

### 9.3 工程別の取得範囲

| 工程 | 必須コンテキスト | AI の制約 |
| --- | --- | --- |
| Subsystem Spec | TERM、RULE、根拠資料 | 不足する業務ルールを推測せず未決事項にする |
| Detailed Design | 承認 REQ、TERM、RULE、関連 ADR | 重大な新判断には Draft ADR を要求する |
| G1 Review | 設計時の参照閉包を独立に再解決 | 矛盾、未参照判断、廃止 ADR 利用を検出する |
| Implementation Plan / Test Plan | 承認済み DSG の参照閉包 | 新しい設計判断をプランへ追加しない |
| Implementation / Test | 対象 PLN / TST の参照閉包 | 対象外知識を暗黙に一般化しない |
| Implementation / Test Review | 承認時の根拠集合と実変更 | 根拠のすり替わりと stale context を検出する |

## 10. Context Manifest

AI が参照した知識集合の再現性を確保するため、ゲートまたはレビュー時に Context Manifest を生成する。

Manifest は本文を複製せず、次の情報だけを保持する。

- Change ID
- Phase
- 起点となる REQ / DSG / PLN / TST
- 解決した Knowledge ID / ADR ID
- 正本パス
- Status
- 内容ハッシュ
- 未解決参照
- 競合
- 生成日時

G1、G2、Implementation Review、Test Review では Manifest を再生成し、承認時から判断根拠が変化していないか確認する。導入初期は Manifest を任意とし、自動検証を導入する段階で必須化する。

## 11. 承認ゲートへの組み込み

### 11.1 G1 Design Review

次の確認を追加する。

- REQ が必要な TERM / RULE を参照している
- DSG が関連する ADR を参照している
- 使用する ADR が Accepted であり Superseded ではない
- ADR が REQ / RULE を上書きしていない
- Detailed Design と Knowledge Delta に矛盾がない
- 重大な設計判断が根拠なしで本文へ埋め込まれていない

### 11.2 G2 Plan Review

次の確認を追加する。

- Plan が承認済み知識参照を維持している
- Plan 内に未承認の新しい業務ルールや設計判断がない
- Knowledge / ADR の問題を Plan 内だけで閉じていない

### 11.3 Implementation Review / Test Review

次の確認を追加する。

- 実装とテストが承認時の知識集合に基づいている
- 廃止済み TERM / RULE / ADR を使用していない
- 発見された新しい業務知識をコードだけに残していない
- 再利用可能なレビュー知見が改善候補として分類されている

### 11.4 G3 Archive

次の確認を追加する。

- Knowledge Delta の Operation と対象 ID が妥当である
- MODIFIED / REMOVED の ID が baseline に存在する
- ADDED の ID が baseline に存在しない
- Accepted ADR の関連 ID が解決できる
- Knowledge Index が更新されている

## 12. レビュー知見の昇格

Review Record に記録された指摘は、ただちに skill または custom instructions へ反映しない。次の順で成熟させる。

1. REV として事実、影響 ID、根本原因を記録する。
2. 局所的な問題は対象成果物の修正だけで閉じる。
3. 複数回発生する問題、または一度でも重大な工程逸脱を引き起こした問題を改善候補とする。
4. 工程固有の手順は workspace skill へ反映する。
5. 横断的な既定動作は custom instructions へ反映する。
6. 機械判定可能な規則は validator へ反映する。
7. 改善内容に根拠 Review ID と期待効果を記録する。

skill と custom instructions にはプロジェクト固有の TERM / RULE 本文を複製せず、正本を参照する手順だけを保持する。

## 13. 段階導入

### Phase 1: 記録形式の導入

- Knowledge Index、Glossary、Business Rules、ADR、Knowledge Delta のテンプレートを追加する
- ナレッジ記録基準をガイドへ追加する
- G1 / G2 / Review の checklist へ確認項目を追加する
- 自動検証は行わない

### Phase 2: ID 参照の導入

- TERM / RULE / ADR の ID を導入する
- Subsystem Spec と Detailed Design に参照列を追加する
- agent、prompt、skill に工程別の取得規則を追加する
- 未参照 ID と廃止項目利用を warning として報告する

### Phase 3: 自動検証と Archive

- validator へ重複 ID、未解決参照、不正 Status の検証を追加する
- archive 処理へ Knowledge Delta と ADR の反映を追加する
- Context Manifest を生成する
- 定着した warning を段階的に error へ昇格する

### Phase 4: 継続改善

- Review ID を根拠に skill / custom instructions / validator を改善する
- メトリクスから利用されない知識や重複ルールを整理する
- リポジトリ規模が増大した場合だけ、ID 参照を維持したまま検索基盤や RAG の追加を検討する

## 14. 検証規則候補

自動検証では、段階的に次を確認する。

- TERM / RULE / ADR ID の重複がない
- 成果物が参照する ID が存在する
- Active REQ が Obsolete TERM / RULE を参照していない
- DSG が Superseded / Rejected ADR を現行判断として参照していない
- ADR の Related Requirement IDs / Rule IDs / Design Element IDs が解決できる
- Knowledge Delta の Operation と baseline の存在条件が一致する
- Index の ID、Status、正本パスが実体と一致する
- Manifest に未解決参照や競合が残ったまま承認されていない

## 15. 運用上のアンチパターン

次の運用を避ける。

- すべての知識を 1 つの巨大な `knowledge.md` に集約する
- 同じ業務ルール本文を Spec、Design、ADR、skill へ複製する
- Accepted ADR を現在の判断に合わせて直接書き換える
- すべての小さな実装判断を ADR 化する
- AI の会話履歴や memory だけに判断理由を残す
- 全文検索で見つけた文書を Status 確認なしに採用する
- プロジェクト固有知識を共通 custom instructions へ埋め込む
- 利用目的を定めず、文書件数だけを増やす
- 中小規模の段階から RAG や外部ベクトルデータベースを必須化する

## 16. 評価指標

運用効果は次の指標で評価する。

- 未参照 Knowledge ID 数
- 解決できない参照 ID 数
- 同義語または用語定義の衝突数
- 期限切れまたは Obsolete 知識の利用数
- Superseded ADR の誤利用数
- 判断理由が見つからず再検討になった件数
- 同一根本原因によるレビュー指摘の再発率
- Knowledge Delta と Spec Delta の不整合数
- AI が使用した根拠集合を再現できなかった件数

作成文書数や ADR 数そのものは成功指標としない。

## 17. WaterfallSdd 側の変更候補

本方針を実装する場合、WaterfallSdd では次の変更を行う。

- `templates/` に Knowledge Index、Glossary、Business Rules、ADR、Knowledge Delta を追加する
- Subsystem Spec と Detailed Design のテンプレートへ知識参照列を追加する
- Review Record と各 gate checklist へ知識確認項目を追加する
- workflow 定義へナレッジライフサイクルと gate 規則を追加する
- author / reviewer agent と prompt へ工程別の知識取得規則を追加する
- knowledge context resolution 用の workspace skill を追加する
- traceability validator へ Knowledge ID 検証を追加する
- archive script へ Knowledge Delta と ADR の反映を追加する
- validator と archive のテストケースを追加する
- README と導入ガイドへ標準配置と運用手順を追加する

## 18. 未決事項

実装計画を作成する前に、次を確定する。

- Glossary と Business Rules を単一 Markdown テーブルで管理するか、項目単位のファイルに分割するか
- Knowledge Index を手動管理するか、正本から生成するか
- Context Manifest の JSON schema と保存期間
- warning から error へ昇格する条件
- ADR の採番単位を全体、subsystem、または csproj のどれにするか
- Knowledge Delta の archive 失敗時に既存 archive 処理を全面 rollback する方法

## 19. 採用方針

本方針では、次を採用する。

- 種類別の正本を ID 参照で結ぶ
- baseline と change を分離する
- Accepted ADR を不変記録として扱う
- AI は明示 ID を正規ルート、全文検索を候補発見に使用する
- 工程別に AI の取得範囲を制限する
- Context Manifest で利用根拠を再現可能にする
- テンプレート、warning、error の順で段階導入する
- 成熟したレビュー知見だけを実行可能な規則へ昇格する

本書は方針設計であり、テンプレート、validator、archive、agent、skill の具体的な実装は、未決事項を解消した後に別の Implementation Plan で定義する。