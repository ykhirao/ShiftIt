## インストール

1. 下の `ShiftItNeo-*.zip` をダウンロードして展開し、`ShiftItNeo.app` を `/Applications` に移す。
2. Apple の公証を受けていないので、次のコマンドで隔離属性を外す：

   ```sh
   xattr -dr com.apple.quarantine /Applications/ShiftItNeo.app
   ```

3. ShiftItNeo を起動し、**システム設定 > プライバシーとセキュリティ > アクセシビリティ** で ShiftItNeo をオンにする。

動作環境：Apple Silicon（M1 以降）の Mac、macOS 13 以降。前の版から入れ替えた場合、アクセシビリティの許可はそのまま引き継がれます。
