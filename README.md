<h1><img src="artwork/ShiftIt.png" width="72" height="72" valign="middle"/> ShiftIt</h1>

キーボードショートカットで、ウィンドウの位置と大きさを変える macOS のメニューバーアプリです。

[fikovnik/ShiftIt](https://github.com/fikovnik/ShiftIt)（2023 年を最後に更新停止）のフォークで、**Apple Silicon の Mac で最新の macOS でもネイティブに動く**ように作り直しています。

![メニュー](docs/schreenshot-menu.png)

## 動作環境

- Apple Silicon（M1 以降）の Mac。Intel Mac には対応していません
- macOS 13 以降

## インストール

今のところ、GitHub Actions でビルドしたアプリを配っています。

1. アプリをダウンロードする（[GitHub CLI](https://cli.github.com/) を使う場合）：

   ```sh
   id=$(gh run list --repo ykhirao/ShiftIt --workflow Build --branch main --status success --limit 1 --json databaseId -q '.[0].databaseId')
   gh run download "$id" --repo ykhirao/ShiftIt --name ShiftIt
   ```

   開発中の版を試すときは `--branch develop` にします。ブラウザからなら、[Actions](https://github.com/ykhirao/ShiftIt/actions/workflows/build.yml) の実行結果の Artifacts から `ShiftIt` をダウンロードできます（GitHub へのログインが必要です）。

2. `ShiftIt.zip` を展開し、`ShiftIt.app` を `/Applications` に移す。

3. Apple の公証を受けていないので、ブラウザでダウンロードした場合は起動が止められます。次のコマンドで隔離属性を外してください：

   ```sh
   xattr -dr com.apple.quarantine /Applications/ShiftIt.app
   ```

4. ShiftIt を起動し、**システム設定 > プライバシーとセキュリティ > アクセシビリティ** で ShiftIt をオンにする。

アプリは自己署名証明書で署名しているので、新しい版に入れ替えてもアクセシビリティの許可はそのまま引き継がれます。うまく動かないときは、一度オフにしてからオンにし直してください。

## 使い方

ShiftIt はメニューバーに常駐します。メニューに並んでいるアクション（左半分、右半分、最大化など）をショートカットで呼び出せます。ショートカットは設定画面で変えられます。

### 同じ方向に続けて押したとき、幅を 1/2 → 1/3 → 2/3 と切り替える

```sh
defaults write org.shiftitapp.ShiftIt multipleActionsCycleWindowSizes YES   # オン
defaults write org.shiftitapp.ShiftIt multipleActionsCycleWindowSizes NO    # オフ
```

### メニューバーのアイコンを消してしまった

ShiftIt をもう一度起動すると、設定画面が開きます。

### ショートカットを押しても何も起きない

アクセシビリティの許可を確認してください。一部のアプリ（GTK+ のアプリなど）のウィンドウは、Accessibility API で動かせないことがあります。

## 開発

作業のルールと、これからの作業は [AGENTS.md](AGENTS.md) にまとめています。

- Xcode プロジェクトは [XcodeGen](https://github.com/yonaskolb/XcodeGen) で `project.yml` から生成します：

  ```sh
  brew install xcodegen
  xcodegen generate
  xcodebuild -project ShiftIt.xcodeproj -scheme ShiftIt -configuration Release build
  ```

- `develop` ブランチで開発し、`main` にマージします。push すると GitHub Actions でビルドされます。

## ライセンス

[GNU General Public License v3](http://www.gnu.org/licenses/gpl.html)。本家は Filip Krikava による [ShiftIt](https://github.com/fikovnik/ShiftIt) で、さらにその元は Aravindkumar Rajendiran による [ShiftIt](http://code.google.com/p/shiftit/) です。
