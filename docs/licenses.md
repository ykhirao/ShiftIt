# ライセンス

2026-09-12 時点の整理です。法的な助言ではないので、判断に迷うときは専門家に確認してください。

## ShiftItNeo 本体：GPL v3（またはそれ以降）

- 本家 ShiftIt のソースのヘッダには、GNU General Public License v3（「or (at your option) any later version」付き）と書かれている。README にも GPL v3 とある。
- 著作権は Filip Krikava（2010〜2011 年）と、本家に貢献した約 20 人のコントリビュータにある。一部のファイルには、さらにその元の ShiftIt を作った Aravindkumar Rajendiran（2010 年）の表記が残っている。
- ShiftItNeo は ShiftIt を改変したもの（派生物）なので、GPL v3 で配らなければならない。こちらの変更分だけを別のライセンスにすることはできない。
- ライセンス本文はリポジトリ直下の `LICENSE`。アプリにも同じものを入れている。

## 含まれている他のコードとライブラリ

どれも GPL v3 と組み合わせて配ってよいライセンス。表記は `THIRD_PARTY_NOTICES.md` にまとめ、アプリにも入れている。

| 部品 | ライセンス | 守ること |
|---|---|---|
| `ShiftIt/FMT/`（Filip Krikava） | MIT | 著作権表示とライセンス文を残す |
| `ShiftIt/GTM/`（Google Toolbox for Mac の一部） | Apache License 2.0 | ライセンス文を添える。改変したら明記する |
| [ShortcutRecorder](https://github.com/Kentzo/ShortcutRecorder) 3.4.0 | CC BY 4.0 | 作者の表示。Swift Package Manager で入れると、ライセンス文と表示（`LICENSE.txt`、`ATTRIBUTION.md`）がアプリの中の `ShortcutRecorder_ShortcutRecorder.bundle` に自動で入る |

## GPL v3 で配るときに守ること

- **ソースを公開する**：GitHub の公開リポジトリで満たしている。Releases の zip はリポジトリの特定のタグからビルドしている。
- **ライセンス本文を添える**：`LICENSE` をリポジトリとアプリに入れている。
- **改変したことを明記する**：README と `THIRD_PARTY_NOTICES.md` に、ShiftIt を 2026 年に改変したものだと書いている。
- **ライセンスを変えない、追加の制限をかけない**：受け取った人が再配布や改変をすることを妨げない。

## App Store に出せるか

**今のままでは出さないほうがよい。** 理由はライセンスで、技術的な問題ではない。

- FSF（GPL を作った団体）の見解では、App Store の利用規約（配布先での使い方に制限をかける条件）は GPL と両立しない。2011 年には、GPL で配られていた VLC が、著作権者の一人の申し立てで App Store から削除された。
- ShiftIt のコードの著作権は、Filip Krikava と約 20 人のコントリビュータにある。フォークした側には、ライセンスを変える権利がない。

技術的には、Magnet のように、アクセシビリティ許可を使うウィンドウ整理アプリも Mac App Store で配られている。サンドボックス化の作業と審査への対応は要るが、不可能ではない。

App Store に出したい場合の道：

1. **著作権者全員から許諾をもらう**：Filip Krikava と約 20 人のコントリビュータ全員に、別のライセンスで配ることを認めてもらう。現実的ではない。
2. **ゼロから書き直す**：ShiftIt のコードを見ながら写すのではなく、仕様（機能と振る舞い）だけをもとに書き直す。書き直したコードは自分の著作物になるので、ライセンスを自分で選べる。Swift で作り直すなら、そのときが機会になる。アイコンなどの画像も本家のものなので、描き直す必要がある。

GPL のまま配るなら、Developer ID で署名して公証を受け、直接配るのが正攻法（[roadmap.md](roadmap.md) の 1-1）。
