
## 使い方

### 動作環境

公式テックガイドの"Windows - SteamCMDの場合"の通り導入している前提です。

https://tech.palworldgame.com/ja/getting-started/deploy-dedicated-server

また、RESTAPIが動くようにパスワード等を設定してください。

### 環境変数の設定

以下の名前のWindows環境変数を作成してください

| 変数 | 値(例) | 設定内容 |
| --- | --- | --- |
| PALADMINPASSWORD | password | RESTAPI認証用のパスワード |
| PALPATH | C:\steamcmd_palworld | steamcmd等の格納先 |
| PALPORT | 8211 | パルワールドのポート番号 |

### 定期実行

このスクリプトは自力で定期実行する機能を備えていません。  
タスクスケジューラで定期実行する想定をしています。  
以下のような指定をすれば動くでしょう。

|     |     |
| --- | --- |
| プログラム | powershell |
| 引数 | -NoProfile -NoLogo -NonInteractive -ExecutionPolicy Bypass -File C:\pal_auto_update.ps1 |
| 開始 | C:\ |

毎日 9時-21時の間 15分間隔  
のような指定をします。  
日本人の勤務時間の間に動いていればいいと思います。

### 余談

Windows11環境だとzstd圧縮に対応しているので、スクリプト内の.zipを.tar.zstに変えると少しだけ幸せになります。(tar.exeはファイル名を見て圧縮形式を変えられます)
