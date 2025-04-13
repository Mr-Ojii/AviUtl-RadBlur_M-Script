# RadBlur_M
AviUtl拡張編集用、GPUを使用した高速・高精度放射ブラースクリプト

## 導入方法
1. karoterra氏の[GLShaderKit](https://github.com/karoterra/aviutl-GLShaderKit)を導入
2. exedit.aufと同一ディレクトリにあるscriptディレクトリ内、またはそのディレクトリの1階層下に`RadBlur_M.anm`,`RadBlur_M.frag`,`RadBlur_M.lua`を配置

## パラメータ説明
### X
ブラーの中心となるX座標
### Y
ブラーの中心となるY座標
### amount
ブラーの適用量
### keep_size
サイズを保持したままエフェクトをかけるか
### quality
数字が大きければ大きいほどブラーとしての精度は向上するが、重くなります。
### reload
シェーダーを都度リロードするか  
主にデバッグ用なので、オフのままを推奨
### PI
トラックバーのパラメータインジェクション用

## 外部スクリプトから呼ぶためのドキュメント
### 呼び出し方
`package.path`変数を編集し、requireで読めるようにしてから、
```
local RadBlur_M = require("RadBlur_M")
RadBlur_M.RadBlur_M(x, y, amount, keep_size, quality, reload)
```
と呼び出すことにより、objバッファにエフェクトがかけられます。

### パラメーター説明
|変数名   |説明                  |型     |単位    |
|---------|----------------------|-------|--------|
|x        |X座標                 |number |ピクセル|
|y        |Y座標                 |number |ピクセル|
|amount   |エフェクトの程度      |number |なし?   |
|keep_size|サイズ保持            |boolean|なし    |
|quality  |描画精度              |number |なし    |
|reload   |シェーダーの再読み込み|boolean|なし    |
