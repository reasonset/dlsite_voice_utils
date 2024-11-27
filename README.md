# dlsite_voice_utils

Library and search utilities for digital content (specifically DLSite (specifically ASMR Voice content))

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

DLsite voice utils will eventually provide a web application for searching and managing collections of audio works.
The application can be opened from index.html and works completely offline.

The main body of the application that index.html loads is app.js, and the information about the works is meta.js.

The files handled by DLsite voice utils are as follows

|File|Description|
|--------|------------------------------------|
|index.html|Container file for loading the application.|
|app.js|The main body of the application.|
|meta.js|Information on works to be loaded by app.js.|
|meta.yaml|The piece information that the user edits to configure meta.js.|
|soundindex.js|Hints to be used for sorting items.|
|config.js|Configuration file for use with [LWMP](https://github.com/reasonset/localwebmediaplayer).|

In order to use DLsite voice utils, you must have the specified library folder and place the files as specified.
It will generate a collection based on the placed files.

`mkmeta.rb` generates a `meta.yaml` file based on the placed files. after the second time, it adds the newly added items to it.

`meta.yaml` is a user-editable file.
`mkmeta.rb` generates metadata for the work in `meta.yaml`. Some entries are automatically filled in, but it is the user who should fill in the metadata in `meta.yaml`.

`mkjson.rb` generates `meta.js` and `soundindex.js` based on the file hierarchy and the contents of `meta.yaml`.
You runs `mkjson.rb` when `meta.yaml` is updated.

## Library file hierarchy

The directory for this library must be `_VoiceLibrary`.

The audio work files are put on `../Voice` from utils directory.
The files under `Voice` must be placed in `_circle/_series/work`, `_circle/work`, or `work`. `work` is considered a single work.

Symbolic links are allowed for `work` or `Voice` directory.

`work` must be the name of the work and must be unique.
DLsite voice utils uses the work name as key, so duplicate filenames in the `work` directory, even if they exist in different directories, will cause problems.

Place the cast directory on `../_VoiceByCast`.
The name of the cast directory is the cast name, and the cast directory contains a symbolic link to the work.

If the cast appears in all the works in the series, the file name of the symbolic link should start with `__` and be a symbolic link to the series.
If the cast appears in all the works in circle, the file name of the symbolic link should begin with `_` and be a symbolic link to the circle.

## Ordering names

You can set Yomigana to circle name or cast name to control the order of Japanese names.

To add Yomigana to cast names, use `[Kana]_name`. To add kana to circle names, use `_[Kana]_name`.

You can also use the alphabet instead of kana and list them in alphabetical order.

## File hierarchy example

```
_VoiceLibrary/
  mkmeta.rb
  mkjson.rb
  meta.yaml
  meta.json
Voice/
  _[circlea]_サークルA/
    work-A/
  _[circleb]_サークルB
    _series_B/
      work-B1/
      work-B2/
  work-C
  _[circled]_サークルD/
    work-D/
_VoiceByCast/
  [HinataYuka]_陽向葵ゅか/
    _circle-A -> ../../Voice/_[circlea]_サークルA
    __series-B -> ../../Voice/_[circleb]_サークルB/_series_B
    work-C -> ../../Voice/work-C
    work-D -> ../../Voice/_[circled]_サークルD/work-D
```

## Create and edit meta file

Once file placement is complete, unknown works can be added to `meta.yaml` by running `mkmeta.rb`.

You can edit the `meta.yaml` directly, but if you are using Nemo, install `95-edit-dlvoice.nemo_action` and `edit-dlvoice.rb` as Nemo Actions so that you can edit the metadata of the relevant You can edit the metadata of the work from the context menu on the work directory.

## Thumbnail

If you place a file named `thumb.jpg` on the work directory, it will be used as a thumbnail.

## Create meta.js

When ready, run `mkjson.rb` to generate the `meta.js` file.

## Custom URL hundler

To have the folder open from the application, place `desktop/dlsite_voice_folder.desktop` in `~/.local/share/applications` and `desktop/dlvfol.zsh` in path.

and run

```bash
xdg-mime default dlsite_voice_folder.desktop x-scheme-handler/dlvfol
```

You perform this step only once.

## Open index.html

Enjoy!

# Explain metadata

* `path`
    * work directory relative path from library directory
* `btime`
    * Date of you brought
    * `mkmeta.rb` fills btime automatically with btime
    * If filesystem does not support btime (e.g. Ext4,) `mkmeta.rb` uses mtime.
* `tags[]`
    * Array of tag string
* `duration`
    * Work duration (min)
    * It is intended to be measured using `voice-duration.zsh`.
* `rate`
    * Score of work
    * Integer 1 to 5
* `description`
    * Work description
    * `mkjson.rb` fills automatically with README
* `note[]`
    * Array of note string
    * This item is used for display purposes only

# Use with LWMP

1. Set `voice_library_dir` in `config.js` to absolute path to `_Voice` folder.
2. Set `lwmp_server` in `config.js` to HTTP address to LWMP.
3. Publish `_VoiceLibrary` with web server you like.

