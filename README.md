# rxswift-research-reading-book

RxSwift研究読本I・IIの学習ノートとSwiftサンプルです。

## 検証環境と実行方法

検証用ツールチェーンはXcode 26.6 / Swift 6.3です。Swiftの言語モード・iOSの最低バージョンは各プロジェクトの設定を使用します。macOSでXcodeをインストールし、初回起動時の追加コンポーネントのインストールを完了してください。

リポジトリのルートで以下を実行します。

```sh
# 検証対象と番号の一覧
swift Scripts/verify.swift --list

# 全対象を順番に検証
swift Scripts/verify.swift

# 1件だけ検証（0始まり）
swift Scripts/verify.swift --index 0
```

アプリは署名不要のSimulator向けにビルドし、Swiftパッケージは `swift test` で検証します。作業用ディレクトリは実行ごとに作成・削除するため、初回と同様に時間がかかります。依存パッケージの取得にはネットワーク接続が必要です。

## 検証対象

| 番号 | 対象 | 種類 | 開く場所 |
| ---: | --- | --- | --- |
| 0 | `rxswift-research-reading-book1/chapter01/chapter01` | Swiftテスト | `rxswift-research-reading-book1/chapter01/chapter01` |
| 1 | `rxswift-research-reading-book1/chapter02` | Swiftテスト | `rxswift-research-reading-book1/chapter02` |
| 2 | `rxswift-research-reading-book1/chapter03/chapter03` | Swiftテスト | `rxswift-research-reading-book1/chapter03/chapter03` |
| 3 | `rxswift-research-reading-book1/chapter04/demo` | Swiftテスト | `rxswift-research-reading-book1/chapter04/demo` |
| 4 | `rxswift-research-reading-book1/chapter06` | Swiftテスト | `rxswift-research-reading-book1/chapter06` |
| 5 | `rxswift-research-reading-book2/chapter01` | Swiftテスト | `rxswift-research-reading-book2/chapter01` |

アプリを操作するには表のworkspace（ある場合）またはprojectをXcodeで開き、対象のschemeとiPhone Simulatorを選択して実行します。実機で動かす場合は、ご自身のSigning Teamを設定してください。

## CIと検証範囲

`Quality` ワークフローは上記と同じ一覧・スクリプトを使い、対象ごとにビルドまたはテストを実行します。ビルドの成功だけでは、画面表示、アクセシビリティ、通信先の動作、テスト網羅性は保証されません。UIサンプルはSimulator上での操作確認も必要です。

## 振る舞いの回帰テスト

第1巻Chapter06のflatMapLatest例は、遅延とSchedulerを注入したlatestValuesで実行します。実行例も仮想時刻を使い、購読の所有元をDisposeBagで明示します。

新しい入力による古い遅延結果の破棄、購読解除、入力ストリームのエラーによる終了を、実時間の待機なしで検証します。

```sh
swift test --package-path rxswift-research-reading-book1/chapter06
```

## Swiftコード品質

[設計・命名・所有関係の方針と、この教材への適用範囲](SWIFT-QUALITY.md)を参照してください。
