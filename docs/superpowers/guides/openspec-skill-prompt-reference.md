# OpenSpec skill / prompt 説明一覧

## 1. 目的

本書は、OpenSpec 向け Waterfall ワークフローで使用する skill と prompt の役割を一覧で確認できるようにするための参照資料である。

## 2. prompt / custom agent 一覧

| Prompt / Agent | 役割 | 主な入力 | 主な出力 | 関連 skill |
| --- | --- | --- | --- | --- |
| project-onboarding-analyst | 未導入の既存プロジェクトを分析し、OpenSpec Waterfall へ適応する導入方針を作成する | 既存プロジェクトのパス、README、既存仕様、目的 | 導入分析レポート、Subsystem 候補、要件候補、未解決質問、次工程 handoff | subsystem-requirements-refinement, traceability-mapping |
| requirements-subsystem-spec-digger | 任意の事前作業として、未整理の要求を深掘りして Subsystem Spec ドラフトへ整える | 要求、上位設計メモ、背景、制約、未整理の仕様案 | Dig summary、Draft Subsystem Spec、要件 ID、受け入れ条件、スコープ境界、未解決事項 | dig, subsystem-requirements-refinement, acceptance-criteria-check |
| subsystem-spec-author | 上位設計からサブシステム仕様を作成または更新する | サブシステム要件、制約、非機能要件 | Subsystem Spec、要件 ID、受け入れ条件、未決事項 | subsystem-requirements-refinement, acceptance-criteria-check |
| detailed-design-author | 承認済み仕様から詳細設計書を作成または更新する | 承認済み Subsystem Spec、対象 csproj | Detailed Design、設計要素 ID、要件対応表、図、エラー設計、テスト設計 | detailed-design-authoring, traceability-mapping |
| design-reviewer | G1 設計レビューを実施する | Subsystem Spec、Detailed Design | G1 レビュー記録、指摘分類、承認可否 | design-gate-review, defect-classification |
| implementation-planner | 承認済み設計から実装プランを作成または更新する | 承認済み Detailed Design、対象 csproj | Implementation Plan、PLN ID、実装順、環境準備 | implementation-plan-authoring, csproj-slicing |
| test-planner | 承認済み設計からテストプランを作成または更新する | 承認済み Detailed Design、対象 csproj | Test Plan、TST ID、テスト順、テスト準備 | test-plan-authoring, traceability-mapping |
| plan-reviewer | G2 プランレビューを実施する | 承認済み Detailed Design、Implementation Plan、Test Plan | G2 レビュー記録、指摘分類、承認可否 | plan-gate-review, return-target-classification |
| implementation-executor | G2 Approved 後に承認済み実装プランを PLN 単位で実行する。PLN ごとに implementer → spec compliance reviewer → code quality reviewer の 3 段階サブエージェントをオーケストレーションする | 承認済み Detailed Design、Implementation Plan、Test Plan、G2 review record | 実装結果、PLN 実行状況、実装レビュー向けハンドオフ | using-git-worktrees, test-driven-development, requesting-code-review, receiving-code-review, systematic-debugging, verification-before-completion, finishing-a-development-branch |
| implementation-orchestrator | G2 Approved 後の実装フェーズ全体（executor → reviewer ループ）を調整する | 承認済み Detailed Design、Implementation Plan、Test Plan、G2 review record | ループ回数と指摘サマリ、最終 Implementation Review 結果、test-orchestrator への handoff | implementation-review, implementation-execution-feedback-handling |
| implementation-reviewer | 実装完了後に実装レビューを実施する | 承認済み Detailed Design、Implementation Plan、Test Plan、G2 review record、実装結果、変更ファイル | Implementation Review 記録、PLN coverage、戻し先判定、次 handoff | implementation-review, implementation-execution-feedback-handling |
| test-executor | Implementation Review Approved 後に承認済み Test Plan を TST 単位で実行する。TST ごとに test executor → spec compliance reviewer → code quality reviewer の 3 段階サブエージェントをオーケストレーションする | 承認済み Detailed Design、Implementation Plan、Test Plan、実装結果、実装レビュー記録 | テスト結果、TST 実行状況、失敗要因判定、テストレビュー向けハンドオフ | using-git-worktrees, test-driven-development, requesting-code-review, receiving-code-review, systematic-debugging, verification-before-completion, finishing-a-development-branch |
| test-orchestrator | 実装レビュー承認後のテストフェーズ全体（executor → reviewer ループ）を調整する | 承認済み Test Plan、実装実行結果、実装レビュー記録 | ループ回数と指摘サマリ、最終 Test Review 結果、review-improvement-analyst への handoff | test-review, test-execution-feedback-handling |
| test-reviewer | テスト実行後にテストレビューを実施する | 承認済み Detailed Design、Implementation Plan、Test Plan、実装レビュー記録、テスト実行結果、失敗分析 | Test Review 記録、TST coverage、戻し先判定、改善分析向け handoff | test-review, test-execution-feedback-handling |
| review-improvement-analyst | レビュー完了後に再発原因を分析し、workspace skill や custom instructions の改善要否を提案する | 実装レビュー記録、テストレビュー記録、関連成果物、改善候補ファイル | recurring cause summary、更新対象候補、再発防止効果、未解決事項 | review-driven-improvement, defect-classification, return-target-classification |

Step 7 以降に該当する post-G2 実行とレビューの詳細は [OpenSpec G2 後実行ガイド](openspec-post-g2-execution-guide.md) を参照する。

### 2.0 project-onboarding-analyst

- 用途: 未導入の既存プロジェクトを読み取り、OpenSpec Waterfall に載せるための初期分析を行う
- 強制すること:
  - 既存コードや業務文書を勝手に変更しない
  - コードから推測した要件を正式要件として扱わない
  - 導入分析ファイルやドラフト仕様を作成する場合は証拠と未解決事項を明示する
- 向いている場面:
  - 既存プロジェクトへこのプラグインを初めて導入する前
  - README、既存仕様、実装済み機能から Subsystem Spec 作成の材料を整理する時
  - 次に requirements-subsystem-spec-digger または subsystem-spec-author へ渡す材料を作る時

### 2.0.1 requirements-subsystem-spec-digger

- 用途: 未整理の要求や上位設計メモを、任意の事前作業として Subsystem Spec ドラフトへ整える
- 強制すること:
  - mandatory Waterfall workflow の正式 step や approval gate として扱わない
  - 調べれば分かることは質問せず、関連ファイルを確認してから 1 問ずつ深掘りする
  - 不明な業務ルールは補完せず、未解決事項として残す
  - 要求意図、スコープ境界、actor、trigger、観測可能な結果、受け入れ条件を明確にする
- 向いている場面:
  - 要求が粗く、subsystem-spec-author に渡す前に論点を掘り下げたい時
  - 複数サブシステムが混ざっている可能性を切り分けたい時
  - Draft Subsystem Spec と未解決事項を作って、正式な仕様作成へ渡したい時

### 2.1 subsystem-spec-author

- 用途: 上位設計のサブシステム要件を OpenSpec 用仕様へ整える
- 強制すること:
  - 要件 ID の維持または採番
  - スコープと境界の明示
  - 受け入れ条件の付与
- 向いている場面:
  - 新規サブシステム仕様の起案
  - 既存仕様の要件追加や改版

### 2.2 detailed-design-author

- 用途: 承認済み仕様を csproj 単位の詳細設計へ落とす
- 強制すること:
  - クラス構成の定義
  - アクター分割済みアクティビティ図の整備
  - エラー設計とテスト設計の明示
  - 要件 ID と設計要素 ID の対応付け
- 向いている場面:
  - G1 に出す設計書作成

### 2.3 design-reviewer

- 用途: G1 設計レビューゲートを実施する
- 強制すること:
  - 要件反映の確認
  - 役割分担と依存方向の確認
  - 未トレース要件 ID の検出
  - Design / Minor Fix 判定
- 向いている場面:
  - 設計承認前

### 2.4 implementation-planner

- 用途: 承認済み設計を実行可能な実装プランに変換する
- 強制すること:
  - 設計判断の保持
  - csproj 単位の分割
  - 実装順、環境準備の明示
  - REQ / DSG / PLN の対応付け
- 向いている場面:
  - G2 に出す前の実装計画作成

### 2.5 test-planner

- 用途: 承認済み設計を実行可能なテストプランに変換する
- 強制すること:
  - 設計判断の保持
  - テスト実行順、前提条件、環境準備の明示
  - REQ / DSG / TST の対応付け
- 向いている場面:
  - G2 に出す前のテスト計画作成

### 2.6 plan-reviewer

- 用途: G2 プランレビューゲートを実施する
- 強制すること:
  - 設計責務を壊していないかの確認
  - 未トレース要件 ID / 設計要素 ID の検出
  - Design / Plan / Minor Fix 判定
- 向いている場面:
  - 実装開始前の最終レビュー

### 2.7 implementation-executor

- 用途: G2 Approved 後に承認済み実装プランを PLN 単位で実行する。PLN ごとに implementer → spec compliance reviewer → code quality reviewer の 3 段階サブエージェントをオーケストレーションし、最後に final code reviewer サブエージェントを派遣する
- 強制すること:
  - REQ / DSG / PLN / REV の対応維持
  - PLN ごとに実装 → spec compliance review → code quality review の順で進める
  - 実装完了後の implementation-reviewer への handoff
- 向いている場面:
  - 実装フェーズを細粒度に制御したい時
  - implementation-orchestrator を使わずに executor のみを実行したい時

### 2.7.1 implementation-orchestrator

- 用途: G2 Approved 後の実装フェーズ全体（Step 7–8）を自動調整する
- 強制すること:
  - implementation-executor と implementation-reviewer を内部でサブエージェントとして順次呼び出す
  - コードレベルの差戻しはループで再実行し（最大 3 回）、Design / Plan 差戻しはハンドオフで停止する
  - PLN / REQ / DSG / REV のトレーサビリティを全サブエージェント間で保持する
  - 実装・レビューの判断は自ら行わず executor / reviewer サブエージェントに委ねる
- 向いている場面:
  - G2 承認後に実装フェーズ全体を自動化したい時
  - 手動で executor と reviewer を切り替えずに済む単一エントリーポイントが欲しい時

### 2.8 implementation-reviewer

- 用途: 実装完了後に Implementation Review を実施する
- 強制すること:
  - 実装結果と承認済み設計・実装プランの照合
  - REQ / DSG / PLN / REV の対応維持
  - Design / Plan / Code / Minor Fix の戻し先判定
- 向いている場面:
  - テスト実行へ進む前の実装レビュー

### 2.9 test-executor

- 用途: Implementation Review Approved 後に承認済み Test Plan を TST 単位で実行する。TST ごとに test executor → spec compliance reviewer → code quality reviewer の 3 段階サブエージェントをオーケストレーションし、最後に final test reviewer サブエージェントを派遣する
- 強制すること:
  - REQ / DSG / TST / REV の対応維持
  - TST ごとに実行 → spec compliance review → code quality review の順で進める
  - 失敗時は systematic-debugging サブエージェントを先に派遣する
  - test-reviewer への handoff
- 向いている場面:
  - テストフェーズを細粒度に制御したい時
  - test-orchestrator を使わずに executor のみを実行したい時

### 2.9.1 test-orchestrator

- 用途: 実装レビュー承認後のテストフェーズ全体（Step 9–10）を自動調整する
- 強制すること:
  - test-executor と test-reviewer を内部でサブエージェントとして順次呼び出す
  - テスト / コードレベルの差戻しはループで再実行し（最大 3 回）、Test Plan / Impl Plan / Design 差戻しはハンドオフで停止する
  - TST / REQ / DSG / REV のトレーサビリティを全サブエージェント間で保持する
  - テスト・レビューの判断は自ら行わず executor / reviewer サブエージェントに委ねる
- 向いている場面:
  - Implementation Review 承認後にテストフェーズ全体を自動化したい時
  - 手動で test-executor と test-reviewer を切り替えずに済む単一エントリーポイントが欲しい時

### 2.10 test-reviewer

- 用途: テスト実行後に Test Review を実施する
- 強制すること:
  - REQ / DSG / TST / REV の対応維持
  - 失敗要因と未実行 TST の戻し先判定
  - review-improvement-analyst への handoff
- 向いている場面:
  - 改善分析へ進む前のテストレビュー

### 2.11 review-improvement-analyst

- 用途: 実装レビューやテストレビューの結果から、再発防止として workspace 側の skill / prompt / custom instructions を更新すべきか分析する
- 強制すること:
  - 一回限りの局所不具合を reusable guidance 更新として扱わない
  - Review ID、要件 ID、設計要素 ID、Plan / Test ID を維持して指摘を正規化する
  - 頻度と重大度に基づいて、症状ではなく根本原因を分類する
  - 更新対象ファイル、変更種別、根拠、期待する再発防止効果を明示する
- 向いている場面:
  - Implementation Review または Test Review の承認後に改善分析を行う時
  - 同種の指摘が複数回出て、工程ルールや agent guidance の改善余地を判断したい時

## 3. skill 一覧

| Skill | 役割 | 主な使いどころ | 主な確認点 |
| --- | --- | --- | --- |
| dig | プラン、設計、技術判断を 1 問ずつ深掘りして共通理解を作る | 要求や設計の曖昧さを詰める任意の事前対話 | 調査済み前提、1 問 1 論点、推奨回答、未解決事項 |
| subsystem-requirements-refinement | 要件文の正規化と要件 ID の安定化 | サブシステム仕様作成前 | 一意な要件 ID、1 要件 1 意図 |
| acceptance-criteria-check | 受け入れ条件の観測可能性を点検 | サブシステム仕様作成中 / G1 前 | 各要件 ID に判定可能な条件がある |
| detailed-design-authoring | 仕様から詳細設計を構成 | 詳細設計書作成時 | 設計要素、図、エラー、テストの整合 |
| traceability-mapping | REQ / DSG / PLN / TST / REV の対応を作る | 設計書作成時、プラン作成時、レビュー前 | 未トレース ID、重複 ID、孤立 ID |
| design-gate-review | G1 設計レビュー観点を適用 | G1 実施時 | 要件反映、責務分割、図整合、未トレース要件 |
| defect-classification | 指摘を Design / Plan / Minor Fix に分ける | レビュー指摘の判断補助 | 要件影響、設計構造影響、軽微修正条件 |
| implementation-plan-authoring | 設計を実行計画へ落とす | プラン作成時 | 設計非上書き、実行可能粒度、ID 対応 |
| test-plan-authoring | 設計をテスト計画へ落とす | プラン作成時 | 設計非上書き、実行可能粒度、ID 対応 |
| csproj-slicing | csproj 単位に作業を切る | プラン作成時 | 作業単位の依存、並行可否、責務境界 |
| plan-gate-review | G2 プランレビュー観点を適用 | G2 実施時 | 未トレース要件 / 設計要素、実行順、粒度 |
| return-target-classification | 指摘の差戻し先を決める | G2 や再レビュー時 | Detailed Design に戻すか、Plan で閉じるか |
| implementation-review | 実装レビュー観点を適用 | G2 後の実装レビュー時 | PLN coverage、設計・計画整合、検証証跡、REQ / DSG / PLN / REV |
| implementation-execution-feedback-handling | 実装レビュー指摘の戻し先を判定 | G2 後の実装実行・再レビュー時 | REQ / DSG / PLN / REV の対応、Design / Plan / Code / Minor Fix |
| test-review | テストレビュー観点を適用 | G2 後のテストレビュー時 | TST coverage、期待結果整合、失敗分析、REQ / DSG / TST / REV |
| test-execution-feedback-handling | テストレビュー指摘の戻し先を判定 | G2 後のテスト実行・再レビュー時 | REQ / DSG / TST / REV の対応、Design / Plan / Test / Code / Minor Fix |
| review-driven-improvement | レビュー結果から再発防止の改善対象を判断 | 実装レビューやテストレビュー完了後の改善分析 | Review ID 根拠、原因分類、更新対象、再発防止効果 |
| delta-operation-classification | 要件変更を spec delta として ADDED / MODIFIED / REMOVED に分類 | 変更起案時の spec-delta.md 作成 | baseline との要件 ID 照合、操作種別の妥当性、ID 安定化規約との 1:1 対応 |
| change-impact-mapping | spec delta が影響する csproj 成果物を特定し再レビュー要否を決める | 変更起案時の impact-map.md 作成 | 全 delta 要件の対応付け、影響 DSG / PLN / TST 参照、再レビュー判定 |
| change-archiving | 全ゲート承認後に spec delta を baseline へ畳み込み change を退避 | 変更ライフサイクルの G3 アーカイブ時 | proposal 承認状態、検証通過、baseline 反映、archive 退避 |

### 3.0 dig

- 役割: 要求、設計、計画、技術判断の曖昧さを、調査済み前提に基づく 1 問ずつの質問で掘り下げる
- 主な効果:
  - 要求意図や判断依存関係の明確化
  - 推奨回答付きの選択肢提示
  - 決定事項、未解決事項、前提の整理

### 3.1 subsystem-requirements-refinement

- 役割: 上位設計の記述をサブシステム要件へ正規化する
- 主な効果:
  - 要件文の分割
  - 要件 ID の維持 / 採番
  - スコープ外と未決事項の分離

### 3.2 acceptance-criteria-check

- 役割: 要件 ID ごとの受け入れ条件を観測可能・判定可能にする
- 主な効果:
  - 曖昧語の除去
  - 正常系 / 異常系 / 境界条件の点検

### 3.3 detailed-design-authoring

- 役割: 仕様を構造化された詳細設計書へ変換する
- 主な効果:
  - クラス構成の明確化
  - アクター分割アクティビティ図の整備
  - エラー設計、テスト設計の追加

### 3.4 traceability-mapping

- 役割: 機械的トレーサビリティを維持する
- 主な効果:
  - REQ -> DSG -> PLN -> TST の対応表整備
  - REV と要件 / 設計 / 計画の紐付け
  - 未トレース件数の可視化

### 3.5 design-gate-review

- 役割: G1 レビュー観点を固定する
- 主な効果:
  - 要件反映漏れの検出
  - 責務分割、図整合、テスタビリティの確認

### 3.6 defect-classification

- 役割: 指摘を設計差戻し、プラン内解決、軽微修正に分ける
- 主な効果:
  - レビュー差戻し先の一貫化
  - 誤分類の抑制

### 3.7 implementation-plan-authoring

- 役割: 設計を実行可能な計画へ変換する
- 主な効果:
  - plan item ID の付与
  - 実装順とテスト順の構成
  - リスクと準備の明示

### 3.8 test-plan-authoring

- 役割: 承認済み詳細設計を、設計判断を変えずに実行可能なテストプランへ変換する
- 主な効果:
  - test item と TST ID の付与
  - テスト実行順序、テストデータ、環境準備、リスクの整理
  - REQ / DSG / TST の対応付け

### 3.9 csproj-slicing

- 役割: 作業を csproj 単位で切り出す
- 主な効果:
  - 依存関係に応じた作業単位整理
  - 並行可能範囲の明示

### 3.10 plan-gate-review

- 役割: G2 レビュー観点を固定する
- 主な効果:
  - 設計非上書きの確認
  - 未トレース要件 ID / 設計要素 ID の検出
  - 実行性と粒度の点検

### 3.11 return-target-classification

- 役割: G2 指摘の戻し先を決める
- 主な効果:
  - Detailed Design へ戻すべき指摘の抽出
  - Plan 内で閉じる指摘の分離

### 3.12 implementation-review

- 役割: 実装レビュー観点を固定する
- 主な効果:
  - 実装結果と承認済み設計・実装プランの照合
  - PLN coverage と検証証跡の確認

### 3.13 implementation-execution-feedback-handling

- 役割: 実装レビュー指摘の戻し先を判定する
- 主な効果:
  - REQ / DSG / PLN / REV の対応維持
  - Design / Plan / Code / Minor Fix の判定基準を固定する

### 3.14 test-review

- 役割: テストレビュー観点を固定する
- 主な効果:
  - テスト実行結果と承認済み Test Plan の照合
  - TST coverage と失敗分析の確認

### 3.15 test-execution-feedback-handling

- 役割: テストレビュー指摘の戻し先を判定する
- 主な効果:
  - REQ / DSG / TST / REV の対応維持
  - Design / Plan / Test / Code / Minor Fix の判定基準を固定する

### 3.16 review-driven-improvement

- 役割: 実装レビューやテストレビューの指摘から、再発防止として reusable guidance を更新すべきか判断する
- 主な効果:
  - Review ID と関連 ID を保った指摘の正規化
  - 頻度と重大度に基づく根本原因の分類
  - skill、custom instructions、成果物修正のみのどれで扱うべきかの切り分け

### 3.17 delta-operation-classification

- 役割: 既存 baseline に対する要件変更を spec delta として ADDED / MODIFIED / REMOVED に分類する
- 主な効果:
  - 要件 ID 安定化規約への 1:1 写像（ADDED=新規採番 / MODIFIED=ID 維持で内容変更 / REMOVED=Status 廃止）
  - baseline 仕様を直接編集せず差分のみで変更を表現
  - spec-delta.md の Operation 列の妥当性確認

### 3.18 change-impact-mapping

- 役割: spec delta が影響する csproj 単位の設計・プラン・テスト成果物を特定し、再レビュー要否を決める
- 主な効果:
  - 全 delta 要件の影響先 ID への対応付け
  - 設計内容を複製せず ID 参照のみで影響範囲を表現
  - 影響成果物の再レビュー判定（impact-map.md）

### 3.19 change-archiving

- 役割: 全ゲート承認後に spec delta を baseline 仕様へ畳み込み、change フォルダを archive へ退避する
- 主な効果:
  - baseline（openspec/specs/subsystem-spec.md）はアーカイブ操作でのみ更新
  - 変更履歴の不変記録化
  - scripts/openspec-archive.ps1 による明示実行（hook では実行しない）

## 4. 推奨する見方

- 日常運用では prompt 一覧を主に使う
- レビューや差戻し判断で迷ったときは skill 一覧を引く
- トレーサビリティ不備が出たときは traceability-mapping を先に確認する