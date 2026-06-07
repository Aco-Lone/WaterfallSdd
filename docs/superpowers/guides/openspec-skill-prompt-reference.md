# OpenSpec skill / prompt 説明一覧

## 1. 目的

本書は、OpenSpec 向け Waterfall ワークフローで使用する skill と prompt の役割を一覧で確認できるようにするための参照資料である。

## 2. prompt 一覧

| Prompt | 役割 | 主な入力 | 主な出力 | 関連 skill |
| --- | --- | --- | --- | --- |
| subsystem-spec-author | 上位設計からサブシステム仕様を作成または更新する | サブシステム要件、制約、非機能要件 | Subsystem Spec、要件 ID、受け入れ条件、未決事項 | subsystem-requirements-refinement, acceptance-criteria-check |
| detailed-design-author | 承認済み仕様から詳細設計書を作成または更新する | 承認済み Subsystem Spec、対象 csproj | Detailed Design、設計要素 ID、要件対応表、図、エラー設計、テスト設計 | detailed-design-authoring, traceability-mapping |
| design-reviewer | G1 設計レビューを実施する | Subsystem Spec、Detailed Design | G1 レビュー記録、指摘分類、承認可否 | design-gate-review, defect-classification |
| implementation-planner | 承認済み設計から実装・テストプランを作成または更新する | 承認済み Detailed Design、対象 csproj | Implementation and Test Plan、PLN ID、実装順、テスト順、環境準備 | implementation-plan-authoring, csproj-slicing |
| plan-reviewer | G2 プランレビューを実施する | 承認済み Detailed Design、Implementation and Test Plan | G2 レビュー記録、指摘分類、承認可否 | plan-gate-review, return-target-classification |

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

- 用途: 承認済み設計を実行可能な実装・テストプランに変換する
- 強制すること:
  - 設計判断の保持
  - csproj 単位の分割
  - 実装順、テスト順、環境準備の明示
  - REQ / DSG / PLN / TST の対応付け
- 向いている場面:
  - G2 に出す前の計画作成

### 2.5 plan-reviewer

- 用途: G2 プランレビューゲートを実施する
- 強制すること:
  - 設計責務を壊していないかの確認
  - 未トレース要件 ID / 設計要素 ID の検出
  - Design / Plan / Minor Fix 判定
- 向いている場面:
  - 実装開始前の最終レビュー

## 3. skill 一覧

| Skill | 役割 | 主な使いどころ | 主な確認点 |
| --- | --- | --- | --- |
| subsystem-requirements-refinement | 要件文の正規化と要件 ID の安定化 | サブシステム仕様作成前 | 一意な要件 ID、1 要件 1 意図 |
| acceptance-criteria-check | 受け入れ条件の観測可能性を点検 | サブシステム仕様作成中 / G1 前 | 各要件 ID に判定可能な条件がある |
| detailed-design-authoring | 仕様から詳細設計を構成 | 詳細設計書作成時 | 設計要素、図、エラー、テストの整合 |
| traceability-mapping | REQ / DSG / PLN / TST / REV の対応を作る | 設計書作成時、プラン作成時、レビュー前 | 未トレース ID、重複 ID、孤立 ID |
| design-gate-review | G1 設計レビュー観点を適用 | G1 実施時 | 要件反映、責務分割、図整合、未トレース要件 |
| defect-classification | 指摘を Design / Plan / Minor Fix に分ける | レビュー指摘の判断補助 | 要件影響、設計構造影響、軽微修正条件 |
| implementation-plan-authoring | 設計を実行計画へ落とす | プラン作成時 | 設計非上書き、実行可能粒度、ID 対応 |
| csproj-slicing | csproj 単位に作業を切る | プラン作成時 | 作業単位の依存、並行可否、責務境界 |
| plan-gate-review | G2 プランレビュー観点を適用 | G2 実施時 | 未トレース要件 / 設計要素、実行順、粒度 |
| return-target-classification | 指摘の差戻し先を決める | G2 や再レビュー時 | Detailed Design に戻すか、Plan で閉じるか |

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

### 3.8 csproj-slicing

- 役割: 作業を csproj 単位で切り出す
- 主な効果:
  - 依存関係に応じた作業単位整理
  - 並行可能範囲の明示

### 3.9 plan-gate-review

- 役割: G2 レビュー観点を固定する
- 主な効果:
  - 設計非上書きの確認
  - 未トレース要件 ID / 設計要素 ID の検出
  - 実行性と粒度の点検

### 3.10 return-target-classification

- 役割: G2 指摘の戻し先を決める
- 主な効果:
  - Detailed Design へ戻すべき指摘の抽出
  - Plan 内で閉じる指摘の分離

## 4. 推奨する見方

- 日常運用では prompt 一覧を主に使う
- レビューや差戻し判断で迷ったときは skill 一覧を引く
- トレーサビリティ不備が出たときは traceability-mapping を先に確認する