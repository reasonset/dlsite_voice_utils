# dlsite_voice_utils

デジタルコンテンツ(特にDLsite(特にASMR音声作品))を管理・表示・検索するためのソフトウェア

# Requirement

required

* Ruby >= 3.0

optional

* XDG Based desktop
* Nemo
* Zsh
* ffmpeg
* sox

# Usage

## Introduction

DLsite voice utilsは音声作品の検索・管理のためのウェブアプリケーションを提供する。
アプリケーションはindex.htmlから開かれ、完全にオフラインで動作する。

ウェブアプリケーション本体はindex.htmlからロードされるapp.jsで、作品情報はmeta.jsである。

DLsite voice utilsは以下のファイルを扱う:

|File|Description|
|--------|------------------------------------|
|`index.html`|ウェブアプリケーションのコンテナ|
|`index.en.html`|ウェブアプリケーションのコンテナ (英語版)|
|`app.js`|アプリケーション本体|
|`meta.js`|app.jsが扱う作品のメタデータ|
|`.dlvumeta.yaml`|meta.jsの生成に使われる、ユーザーが編集する作品のメタデータ|
|`config.js`|[LWMP](https://github.com/reasonset/localwebmediaplayer)とともに使うための設定ファイル|

DLsite voice utilsを使うには、各ファイルを決められたように配置する必要があり、このファイル配置をもとにコレクションが生成される。

`.dlvumeta.yaml`はユーザーが編集するファイルである。
`mkmeta.rb`はまだ存在しない作品に対してテンプレートを`.dlvumeta.yaml`として展開する。
このファイルは空のメタデータテンプレートであり、ユーザーが内容を埋めるべきものである。

`mkjson.rb`は`.dlvumeta.yaml`とファイル配置を利用して`meta.js`を生成する。
`.dlvumeta.yaml`を編集した場合、`mkjson.rb`を実行してアップデートする。

## ファイル配置

ライブラリディレクトリの名前は`_VoiceLibrary`でなければならない。

音声作品はライブラリディレクトリから見て`../Voice`に配置する。
`Voice`以下には`_circle/_series/work`, `_circle/work`, あるいは`work`の形で配置する。
`work`以下はひとつの音声作品として扱われる。

`work`や`Voice`はシンボリックリンクでも良い。

`work`のファイル名はユニークでなければならない。
DLsite voice utilsはこのファイル名をキーとして扱うため、重複していると問題を生じる。

`../_VoiceByCast`にキャスト情報を配置する。
このディレクトリ直下にキャストのディレクトリを配置する。キャストディレクトリの名前はキャストの名前となる。
キャストディレクトリには作品へのシンボリックリンクを配置する。

もしシリーズすべての作品に出演している場合、`__`で始まるファイル名でシリーズへのシンボリックリンクを作成する。
もしサークルすべての作品に出演している場合、`_`で始まるファイル名でサークルへのシンボリックリンクを作成する。

## 名前のソート

日本語のキャスト名・サークル名を並べ替えるため、これらの名前にはよみがなを設定できる。

キャスト名によみがなをつけるには、`[よみがな]_名前`の形式を使う。
サークル名によみがなをつけるには、`_[よみがな]_名前`の形式を使う。

よみがなはかなではなくアルファベットを用いても良い。

## ファイル配置の例

```
_VoiceLibrary/
  mkmeta.rb
  mkjson.rb
  meta.yaml
  meta.json
Voice/
  _[さーくるA]_サークルA/
    作品A/
  _[さーくるB]_サークルB
    _シリーズ_B/
      作品-B1/
      作品-B2/
  作品-C
  _[さーくるD]_サークルD/
    作品-D/
_VoiceByCast/
  [ひなたゆか]_陽向葵ゅか/
    _circle-A -> ../../Voice/_[さーくるA]_サークルA
    __series-B -> ../../Voice/_[さーくるB]_サークルB/_シリーズ_B
    work-C -> ../../Voice/作品-C
    work-D -> ../../Voice/_[さーくるD]_サークルD/作品-D
```

## メタデータの生成と編集

配置が完了したら、`mkmeta.rb`を実行することで各作品ディレクトリに`.dlvumeta.yaml`が生成される。

`.dlvumeta.yaml`は直接編集することもできるが、Nemoを使っているのなら`95-edit-dlvoice.nemo_action`と`edit-dlvoice.rb`をNemo Actionsにインストールすることで、作品フォルダのコンテキストメニューから作品情報を編集できるようになる。

## サムネイル

作品フォルダの直下に`thumb.jpg`を配置すると、サムネイルとして使われる。

## meta.jsの生成

準備ができたら`mkjson.rb`を実行し、`meta.js`を生成する。

## カスタムURLハンドラ

アプリケーションからフォルダを開けるようにするには、`desktop/dlsite_voice_folder.desktop`を`~/.local/share/applications`に配置し、`desktop/dlvfol.zsh`を`PATH`以下に配置する。

そして

```bash
xdg-mime default dlsite_voice_folder.desktop x-scheme-handler/dlvfol
```

を実行する。

このステップは一度だけ実行すれば良い。

## index.htmlを開く

「たのしんで」ください。

# メタデータの説明

* `btime`
    * 作品の購入日
    * `mkmeta.rb`は自動的にbtimeを使ってこの項目を埋める
    * ファイルシステムがbtimeをサポートしていない場合、`mkmeta.rb`はmtimeを使う
* `tags[]`
    * タグの文字列配列
* `duration`
    * 作品の長さ(分)
    * `voice-duration.zsh`を使って調べることを想定している
* `rate`
    * 作品の評価
    * 1〜5の整数
* `description`
    * 作品の説明
    * `mkjson.rb`はREADMEを使って自動的に埋める
* `note[]`
    * メモの文字列配列
    * この項目はアプリケーションでの表示上でのみ使用される

# LWMPと組み合わせる

1. `config.js`に記載されている`voice_library_dir`を`_Voice`の絶対パスに設定する
2. `lwmp_server`をLWMPで配信しているアドレスに変更する
3. `_VoiceLibrary` ディレクトリを任意のwebサーバーで配信する

# 大きな変更点

## 2025-11-09

従来`mkmeta.rb`はライブラリディレクトリに`meta.yaml`を生成していたが、作品別ディレクトリに`.dlvumeta.yaml`を配置する方式に戻した。
このため、`mkmeta.rb`, `mkjson.rb`, `edit-dlvoice.rb`は同時に更新される必要がある。

`meta.yaml`から`.dlvumeta.yaml`に変換するには、`utils/split-metayaml.rb`を使用する。
これはライブラリディレクトリ上で実行する必要がある。

# 日本語の詳しい説明

[可能性を感じる「クライアント完結型ウェブアプリ」 & カスタム検索エンジンを自作する話](https://chienomi.org/articles/devel/202305-dlsite-voice-viewer.html)

