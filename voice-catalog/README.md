# Synopsis

Create catalog and search page for ASMR Voice contents.

# Premise

* Put "Library Directory" (`$libdir`) somewhere
* Put "Voice Content Directory" `Voice` on `$libdir`
* The Voice Content Directory consists of
    * `${title}`
    * `_${circle}/${title}`
    * `_${circle}/_${series}/${title}`
* Put "Voice Cast Directory" `_VoiceByActress` on `$libdir`
* The Voice Cast Directory consists of
    * `${cast_name}/${title_link}`
    * `${cast_name}/_${circle_link}`
    * `${cast_name}/__${series_link}`
* Put "Voice Catalog Directory" (*This*) on `$libdir`

# Step to use

## Create & Edit Meta

`mkmeta.rb` looks `Voice` directory, and create `meta.yaml`.

You can edit `meta.yaml` with editor.

You can automatic update `meta.yaml` with `mkmeta.rb`.

```
mkmeta.rb
```

Note1: *`$title` should be title string before do it.*

Note2: *Do not duplicate `$title`*

## (Optional) create thumbnail

`thumb.jpg` on `$title` directory is used as cover art.

You can do it automaticaly by running `create-thumbnail.zsh` on `Voice` directory.

`create-thumbnail` seraches largest image file and convert it to `thumb.jpg` with `convert(1)` and `jpegoptim(1)` for each title.

## Generate database

`mkjson.rb` looks `meta.yaml` and `_VoiceByActress`, and generate `meta.js`.
`meta.js` is a database used by `app.js`.

`mkjson.rb` expands content path to absolute path.
If path to `$libdir` is changed, you should re-generate database with `mkjson.rb`.

```
mkmeta.rb
```

## (Optional) add folder handler

`app.js` create links on title text to title directory with `dlvfol://` schema.

You can handle it by registering schema handler.

for example:

```zsh
#!/bin/zsh

cat <<EOF > ~/.local/share/applications/dlsite_voice_folder.desktop
[Desktop Entry]
Type=Application
Name=dlvfol open folder
Exec=dlvfol.zsh %u
StartupNotify=false
MimeType=x-scheme-handler/dlvfol;
EOF

cat <<'EOF' > ~/.local/bin/dlvfol.zsh
#!/bin/zsh

xdg-open "file://${1##dlvfol://}"
EOF

chmod 755 ~/.local/bin/dlvfol.zsh

xdg-mime default dlsite_voice_folder.desktop x-scheme-handler/dlvfol
```

## Play it

Now you can use content browser.
It is able to filter and sort.

If you do not understand Japanese, the following table will help you.

|Japanese|in English|
|--------|---------------------|
|検索|Search|
|タグ|Tag|
|評価下限|Minimum star rate|
|出演者|Cast|
|サークル|Circle|
|キーワード|Keyword|
|カバー|Cover art|
|作品名|Title|
|シリーズ|Series|
|btime|btime|
|長さ|Duration|
|評価|Rate|
|概要|Description|

# Helper tools

## `voice-duration.zsh`

```
voice-duration.zsh [files...]
```

Sum up given files duration with `soxi(1)`.

## inode Utilities

inode Utilities are for moving/renaming files under `Voice` directory.

`inode-create.rb` creates inode mapping database `ino.yaml` under `Voice` directory.
You should do it before rename.

`inode-diff.rb` checks renaming and create `diff.yaml`.

`inode-update.rb` update `meta.yaml` with `diff.yaml`

When it's done, you should do `inode-create.rb` again.

## Play voice with voice cover

* If you use Nemo (Cinnamon)
* Put `nemo/*` to `~/.local/share/nemo/actions`
* Right click on voice contents directory
* You will make so happy

(It needs `yad(1)` and `mpv(1)`.)

