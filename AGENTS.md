# AGENTS.md

このリポジトリで作業する AI エージェント（と人）向けの作業ルールです。

## このリポジトリについて

- ShiftIt は、キーボードショートカットでウィンドウの位置と大きさを変える macOS のメニューバーアプリです。ライセンスは GPLv3。
- [fikovnik/ShiftIt](https://github.com/fikovnik/ShiftIt) のフォーク（[ykhirao/ShiftIt](https://github.com/ykhirao/ShiftIt)）です。本家は 2023 年を最後に更新がありません。
- **このフォークの目標は、最新の Mac（Apple Silicon・最新の macOS）でネイティブに動かすことです。** 対象は Apple Silicon（M1 以降）の Mac だけで、Intel Mac には対応しない。
- **本家の古い流儀には従わなくてよい。** コードの書き方、ビルドの仕組み、ドキュメントは今のやり方に合わせて作り直してよい。本家へ変更を戻すことは考えない。

## ブランチ運用

- `main`：安定版。直接コミット・push しない。`develop` からの PR マージでのみ更新する。
- `develop`：開発用。作業はここで行う。
- 本家（fikovnik/ShiftIt）には PR を出さない。
- このリポジトリはフォークなので、`gh pr create` が本家を向くことがある。PR を作るときは必ず `--repo ykhirao/ShiftIt` を付け、`--base` を明示する。

## 方針

- **最低対応 OS は macOS 13。** ログイン項目の API（`SMAppService`）が 13 からなので、それ未満は切り捨てる。
- **CPU は arm64 だけ**を作る（Apple Silicon 専用。x86_64 は作らない）。
- **メモリ管理は ARC に移す。** 今のコードは手動参照カウント（MRC）で、`retain` / `release` / `autorelease` を書いている。
- **依存ライブラリは Swift Package Manager で入れる。** ビルド済みの `.framework` をリポジトリに置くのはやめる。
- **X11（XQuartz）対応はやめる。** X11 まわりのコードは削除してよい。
- **Xcode プロジェクトは XcodeGen の `project.yml` で管理する。** 設定を変えるときは `project.yml` を直し、生成された `ShiftIt.xcodeproj` を直接いじらない。
- 使われていない仕組みは削除してよい：本家のリリース用ファイル（`release/`、`fabfile.py`、`Pipfile*`）、旧 CI（`.travis.yml`）、`GTM/`（Google Toolbox for Mac の一部）など。
- Swift への書き換えは、Apple Silicon で動くようになってから検討する。まずは Objective-C のまま動かす。
- Xcode の警告は放置しない。今の Xcode が勧めるプロジェクト設定に更新する。

## ディレクトリ構成（現状）

| パス | 中身 |
|---|---|
| `project.yml` | Xcode プロジェクトの定義（XcodeGen）。`ShiftIt.xcodeproj` はここから生成し、リポジトリには入れない |
| `ShiftIt/*.m`, `*.h` | アプリ本体 |
| `ShiftIt/FMT/` | 汎用ユーティリティ（ホットキー登録、ログイン項目など） |
| `ShiftIt/GTM/` | Google Toolbox for Mac の一部（ログ出力とガベージコレクション） |
| `ShiftIt/Base.lproj/`, `ShiftIt/ja.lproj/` | 画面（xib）と文言。英語と日本語 |
| `ShiftIt/ShiftIt Tests/`, `ShiftIt/FMT Tests/` | テスト（OCUnit。今の Xcode では動かない） |

依存ライブラリは [ShortcutRecorder](https://github.com/Kentzo/ShortcutRecorder) 3.4.0（ショートカットの記録欄）だけ。Swift Package Manager で入れていて、バージョンは `project.yml` の `packages` で指定している。

主なクラス：

- `ShiftItAppDelegate`：起動、メニュー、ホットキーの登録
- `SIWindowManager`：ウィンドウ操作の中心
- `AXWindowDriver`：Accessibility API でウィンドウを動かす
- `DefaultShiftItActions`、`WindowGeometryShiftItAction`：各アクション（左半分、最大化など）の座標計算
- `PreferencesWindowController`：設定画面

## コードの書き方

- Objective-C。新しく書くコードは今の書き方（ARC、プロパティ、nullability 注釈、モダンな構文）で書く。
- クラス名の接頭辞は `SI`（ShiftIt 本体）と `FMT`（ユーティリティ）。
- 新しいファイルには GPLv3 のライセンス表記を付ける（フォーク元のライセンスを引き継ぐため）。
- 画面の文言を変えたら、`Base.lproj` と `ja.lproj` の両方を直す。

## ビルドと動作確認

- 開発機に Xcode はない（Command Line Tools のみ）。**ビルドは GitHub Actions の macOS ランナーで行う。** 公開リポジトリなので無料。
  - 設定は `.github/workflows/build.yml`。`main` / `develop` への push と PR で動く。できたアプリ（`ShiftIt.zip`）とビルドログは、実行結果の Artifacts からダウンロードできる。
  - 結果の確認：`gh run list --branch develop`、`gh run view <ID> --log-failed`
- Xcode プロジェクトの生成は Xcode がなくてもできる（`project.yml` を直したら、生成して中身を確かめられる）：

  ```sh
  brew install xcodegen
  xcodegen generate
  ```

- Xcode がある環境なら、`xcode-select` を切り替えなくても次のように指定してビルドできる：

  ```sh
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
    xcodebuild -project ShiftIt.xcodeproj -scheme ShiftIt -configuration Release build
  ```

- ウィンドウを動かすには「アクセシビリティ」の許可が要るので、動作確認は CI ではできない。CI でできたアプリを実機に入れて確かめる。
- アクセシビリティの許可はコード署名に紐づく。仮の署名（ad-hoc）だと、ビルドするたびに許可を付け直すことになる。

## 作業リスト

2026-09-12 時点。作業が進んだら更新してください。

- [x] **CI を作る**：GitHub Actions でビルドし、できたアプリを成果物として残す。
- [x] **Xcode プロジェクトを XcodeGen に移す**：最低対応 OS は macOS 13、CPU は arm64 だけ。
- [x] **Sparkle を削除する**：同梱の 1.5 Beta 6 は PowerPC・32bit Intel・64bit Intel 向けのみ。更新の確認先（`SUFeedURL`）は本家の appcast で、署名鍵も本家しか持っていないので、このフォークでは元々機能しない。自動アップデートが要るなら、あとで Sparkle 2 を入れ直す。
- [x] **ShortcutRecorder を 3.x に置き換える**（Swift Package Manager で入れる）：同梱版は Intel 向けのみだった。
- [ ] **X11 対応のコードを削除する**：`X11WindowDriver.*`、`#ifdef X11` の部分。
- [ ] **廃止された API を置き換える**：
  - ガベージコレクション：`GTM/GTMGarbageCollection.h`（`NSGarbageCollector`）、`NSMakeCollectable`
  - ログイン項目：`FMT/FMTLoginItems.*`（`LSSharedFileList`）→ `SMAppService`
  - 警告ダイアログ：`NSRunAlertPanel` → `NSAlert`
- [ ] **ARC に移す**。
- [ ] **テストを XCTest に移す**：OCUnit（SenTestingKit）は今の Xcode から削除されている。`project.yml` にテストのターゲットを足す。
- [ ] **署名**：arm64 のバイナリは署名がないと動かない。ビルドのたびにアクセシビリティ許可が外れないよう、自己署名証明書を GitHub Secrets に登録して CI で署名する。
- [ ] **古いファイルを掃除する**：`release/`、`fabfile.py`、`Pipfile*`、`.travis.yml`。README もこのフォーク向けに書き直す。

## コミットと PR

- コミットメッセージは日本語で書く。
- 1 つのコミットには 1 つの目的だけを入れる（例：Sparkle の削除とビルド設定の変更は分ける）。
- PR の説明も日本語で書く。
