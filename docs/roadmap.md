# 今後の課題

2026-09-12 時点（ShiftItNeo 2.0.0）でわかっている課題です。片付けたら、この一覧から消してください。

## 1. アクセシビリティ許可まわり

### 1-1. Developer ID で署名して公証を受ける（Apple Developer Program が必要）

今は自己署名証明書で署名しているので、次の問題が残っています。

| 今の問題 | Developer ID で署名して公証を受けると |
|---|---|
| ダウンロードすると Gatekeeper に止められ、`xattr -dr com.apple.quarantine` が要る | ダブルクリックで普通に開ける |
| 署名用の証明書を作り直すと、利用者全員がアクセシビリティ許可を付け直すことになる | 許可が Team ID に紐づき、ずっと引き継がれる |
| 秘密鍵が GitHub Secrets にしかなく、失くすと取り戻せない | Apple のアカウントから発行し直せる |
| Homebrew で配りにくい | Homebrew の cask にしやすい |

必要な作業：

1. Apple Developer Program に加入し（年 99 ドル）、「Developer ID Application」証明書を発行する。公証用に App Store Connect の API キー（または App 用パスワード）を用意する。
2. 証明書と API キーを GitHub Secrets に登録する。
3. CI を変える：`codesign --options runtime --timestamp` で hardened runtime を有効にして署名し、`xcrun notarytool submit --wait` で公証を受け、`xcrun stapler staple` で公証の結果をアプリに添付する。
4. README とリリースノートから `xattr` の手順を消す。

### 1-2. アプリ内の許可の扱い（無料でできる）

- **システム設定の一覧に自動で出ない**：`ShiftItAppDelegate.m` の `checkAuthorization` で `AXIsProcessTrustedWithOptions` を `kAXTrustedCheckOptionPrompt : @NO` で呼んでいるため、アプリがアクセシビリティの一覧に追加されない。`@YES` にしてシステムの確認ダイアログを出せば、一覧に入った状態になり、利用者はスイッチを入れるだけで済む。
- **起動時にしか確認しない**：起動後に許可を外されると、ショートカットを押しても黙って何も起きない。アクションの実行前や、`com.apple.accessibility.api` の分散通知を受けたときに確認し直して、案内を出す。
- **確認のダイアログが操作を止める**：起動時の `NSAlert` は、閉じるまで他の操作ができないモーダルループになっている。モーダルでないウィンドウにして `AXIsProcessTrusted()` を数秒ごとに確かめ、許可されたら自動で先に進む形にすれば、「再確認」ボタンは要らなくなる。

## 2. 設定画面

### 2-1. 見た目が崩れている

2.0.0 の「一般」タブで見えている問題：

- タブが左側に縦書きで並んでいる（`NSTabView` の `leftTabsBezelBorder`）。今の macOS の設定画面は、上部のツールバーでタブを切り替えるのが普通。
- 余白が不自然。説明文と「問題を報告…」ボタンの間が大きく空いている（2.0.0 で「アップデートを確認」ボタンを消した跡）。
- 「ドロワーを含める」とその説明文が残っている。ドロワー（`NSDrawer`）は macOS 10.13 で廃止されていて、今のアプリには存在しない。
- ウィンドウ名が「環境設定」、メニューの項目名が「環境設定...」のまま。macOS 13 からは「設定」「設定…」と呼ぶ。

根本の原因は、`Base.lproj/PreferencesWindow.xib` が 2014 年の Xcode 5（OS X 10.9）で作られたままで、自動レイアウトを使わずに座標を固定していること（ウィンドウは 408×512 で固定）。日本語の文言は英語より長く、そのまま折り返したり、はみ出したりする。

直し方の候補：

- xib を作り直す：ツールバー形式のタブ（`NSTabViewController` の `tabStyle = .toolbar`）にし、自動レイアウトで組む。xib の編集には Xcode が要る。
- コードで組む：Xcode がなくても作れて、差分も読みやすい。
- Swift に移るなら、SwiftUI の `Settings` シーンにする。

「ショートカット」「拡大と縮小」「アンカー」「詳細設定」のタブも同じ作りなので、実機でひと通り見て直す必要がある。

### 2-2. 設定が効いていない（不具合）

画面の部品がつながっている設定の名前（`PreferencesWindow.xib` の binding）と、コードが読んでいる名前が食い違っている。

| 画面の部品 | 画面が保存する名前 | コードが読む名前 | 結果 |
|---|---|---|---|
| 一般 >「ドロワーを含める」 | `includeDrawers` | `axdriver_includeDrawers`（しかも起動時に 1 回だけ読む） | チェックを変えても何も変わらない |
| 拡大と縮小 > 固定サイズの増減ボタン（幅・高さ） | どちらも `fixedSizeDelta` | `fixedSizeWidthDelta` / `fixedSizeHeightDelta` | 増減ボタンを押しても効かない（入力欄は正しくつながっている） |

初期値のファイル（`ShiftIt-defaults.plist`）にも綴り間違いがある。

- `mutipleActionsCycleWindowSizes`（t が抜けている）に `YES` が入っているが、コードが読むのは `multipleActionsCycleWindowSizes`。そのため、同じ方向に続けて押したときに幅を 1/2 → 1/3 → 2/3 と切り替える機能は、初期状態でオフになっている。初期値をオンにするかどうか決めて、名前を直す。

## 3. メニューバーのアイコン

`ShiftItMenuIcon.png` は 27×27 ピクセルの 1 枚だけで、Retina 用の高解像度版がないため、ぼやけて見える。SF Symbols か、ベクター（PDF / SVG）のテンプレート画像に差し替える。

## 4. 動作確認

- 2.0.0（ARC への移行後）で、ショートカットでウィンドウが動くことを実機で確かめる。開発環境の都合で、キー入力を送る自動テストはできていない。
- 複数のディスプレイ、フルスクリーン、ステージマネージャ、macOS 26 のウィンドウ配置機能と組み合わせたときの動きを確かめる。

## 5. 配布

- 自動アップデート：Sparkle 2 を入れ直し、EdDSA の鍵で署名した appcast を GitHub Releases に置く。自己署名のままでも動く。
- Homebrew：公証を受けたあとなら、自分の tap（`ykhirao/homebrew-tap` など）で cask を配れる。

## 6. コードの近代化（急がない）

- ログ出力を GTMLogger から `os_log` に移す。「詳細設定」タブのデバッグログをファイルに書く機能は GTMLogger に依存しているので、合わせて作り直す。
- ホットキーの登録は Carbon の `RegisterEventHotKey` を使っている。今も動くので急がない。
- Swift への書き換え。2-1 の設定画面を SwiftUI にするなら、そこから始めるのがよい。
