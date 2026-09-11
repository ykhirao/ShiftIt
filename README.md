<h1><img src="artwork/ShiftIt.png" width="72" height="72" valign="middle"/> ShiftItNeo</h1>

キーボードショートカットで、ウィンドウの位置と大きさを変える macOS のメニューバーアプリです。

[fikovnik/ShiftIt](https://github.com/fikovnik/ShiftIt)（2023 年を最後に更新停止）のフォークで、**Apple Silicon の Mac で最新の macOS でもネイティブに動く**ように作り直しています。本家の ShiftIt とは別のアプリ（バンドル ID は `io.github.ykhirao.ShiftItNeo`）なので、両方を入れても混ざりません。

![メニュー](docs/schreenshot-menu.png)

## 動作環境

- Apple Silicon（M1 以降）の Mac。Intel Mac には対応していません
- macOS 13 以降

## インストール

1. [Releases](https://github.com/ykhirao/ShiftIt/releases/latest) から `ShiftItNeo-*.zip` をダウンロードして展開し、`ShiftItNeo.app` を `/Applications` に移す。

2. Apple の公証を受けていないので、そのままでは起動が止められます。次のコマンドで隔離属性を外してください：

   ```sh
   xattr -dr com.apple.quarantine /Applications/ShiftItNeo.app
   ```

3. ShiftItNeo を起動し、**システム設定 > プライバシーとセキュリティ > アクセシビリティ** で ShiftItNeo をオンにする。

アプリは自己署名証明書で署名しているので、新しい版に入れ替えてもアクセシビリティの許可はそのまま引き継がれます。うまく動かないときは、一度オフにしてからオンにし直してください。

### 開発中の版を試す

`develop` ブランチのビルドは、GitHub Actions の成果物として取れます（[GitHub CLI](https://cli.github.com/) を使う場合）：

```sh
id=$(gh run list --repo ykhirao/ShiftIt --workflow Build --branch develop --status success --limit 1 --json databaseId -q '.[0].databaseId')
gh run download "$id" --repo ykhirao/ShiftIt --name ShiftItNeo
```

## 使い方

ShiftItNeo はメニューバーに常駐します。メニューに並んでいるアクション（左半分、右半分、最大化など）をショートカットで呼び出せます。ショートカットは設定画面で変えられます。

### 同じ方向に続けて押したとき、幅を 1/2 → 1/3 → 2/3 と切り替える

```sh
defaults write io.github.ykhirao.ShiftItNeo multipleActionsCycleWindowSizes YES   # オン
defaults write io.github.ykhirao.ShiftItNeo multipleActionsCycleWindowSizes NO    # オフ
```

### メニューバーのアイコンを消してしまった

ShiftItNeo をもう一度起動すると、設定画面が開きます。

### ショートカットを押しても何も起きない

アクセシビリティの許可を確認してください。一部のアプリ（GTK+ のアプリなど）のウィンドウは、Accessibility API で動かせないことがあります。

## 開発

作業のルールと、これからの作業は [AGENTS.md](AGENTS.md) にまとめています。

- Xcode プロジェクトは [XcodeGen](https://github.com/yonaskolb/XcodeGen) で `project.yml` から生成します：

  ```sh
  brew install xcodegen
  xcodegen generate
  xcodebuild -project ShiftItNeo.xcodeproj -scheme ShiftItNeo -configuration Release build
  ```

- `develop` ブランチで開発し、`main` にマージします。push すると GitHub Actions でビルドと単体テストが動きます。
- リリースするときは、`project.yml` の `MARKETING_VERSION` を上げてから、同じ番号のタグ（例：`v2.0.0`）を `main` に push します。GitHub Actions がビルドして Releases に公開します。
- 不具合の報告は [Issues](https://github.com/ykhirao/ShiftIt/issues) へ。

## ライセンス

[GNU General Public License v3](http://www.gnu.org/licenses/gpl.html)。本家は Filip Krikava による [ShiftIt](https://github.com/fikovnik/ShiftIt) で、さらにその元は Aravindkumar Rajendiran による [ShiftIt](http://code.google.com/p/shiftit/) です。
