Craftopiaを外部プロセスから止める事を実現するスクリプトです。  
直接Craftopiaにコマンドを打つ以外に止める方法が分からなかったので作りました。

## 使い方

### 動作環境

公式テックガイドの"Windows - SteamCMDの場合"の通り導入している前提です。

https://tech.palworldgame.com/ja/getting-started/deploy-dedicated-server

この通りに実行するとパルワールドがインストールされてしまうので、IDは

* 1670340

に変えてください

### 環境変数の設定

以下の名前のWindows環境変数を作成してください

| 変数 | 値(例) | 設定内容 |
| --- | --- | --- |
| CRAFTOPIAPATH | C:\steamcmd_craftopia | steamcmd等の格納先 |

### 起動

craftopia_handler.cmdとcraftopia_handler.ps1は同じフォルダに入れてください。  
craftopia_handler.cmdを実行するとcraftopiaサーバーが普通に起動します。

止めたくなったら、craftopia_commander.cmdを実行すると、いつか止まります(Craftopia依存です)。  
もちろんcraftopia_commander.ps1と同じフォルダに入れてください。

handlerとcommanderは別のフォルダでもいいです。

### 注意

UDPポート6588を使います。  
craftopia_handlerの初回実行時に、ファイアウォールが「ポート使わせていいか？」と聞いてくると思うので、許可して下さい。
