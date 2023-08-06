# Synopsis

Manage DLSite contents with Harukamy style.

# Precaution

* I made it for DLSite contents.
* It is assumed that files with Japanese file names are included in the archive file.

# Premise

* Put "Library Directory" (`$libdir`) somewhere
* Put "Library Entity Directory" `.library` on `$libdir`
* Content Files consists of
    * `${libdir}/${category}/${title}`
    * `${libdir}/${category}/_${circle}/${title}`
    * `${libdir}/${category}/_${circle}/_${series}/${title}`
* `$title` is symlink to `${libdir}/${entity}` or `${libdir}/${entity}/${subdir}`

# Install

* Include `zshrc.zsh` in any zshrc file.
* Set `$DLSITE_LIBRARY_DIR` to path to `.library`

# Usage

## Create library entity and its link

`dlsite_extract` extracts archive file into `.library` directory.

```
dlsite_extract [-u|--unconvert] [-i|--insjis] [-o|--outsjis] [-7|--7z] <source_file>
```

|Option|Effect|
|--------|--------------------|
|`7`, `--7z`||Use `7z` instead of `unzip` or `unrar`.|
|`i`, `--insjis`||Add `-I sjis` option for `unzip` instead of `-O sjis`|
|`o`, `--outsjis`||Add `-O sjis` option for `unzip`. It is no effect because it is default behavior.|
|`u`, `--unconverted`||Remove `-O sjis` option for `unzip`.|

After extraction, if you ask `y` to question `Is it OK? [y/N]`, delete archive file and set `$dexfile` and `$dexfpath`. Otherwise delete entity directory.

`$dexfile` is extracted directory name on `.library`, `$dexfpath` is absolute path to extracted directory, and `$dexname` is file name of first entity on archive file.

If you are on `${libdir}/${category}/${circle}` directory, you can create title symlink in typically case.

```bash
ln -vs ../../.library/$dexfile $dexname
```

## Move library link

```
dlsite_movelink <source> <dest>
```

Create new library link `<dest>` and delete `<source>`
You can use it like `mv`.

## Delete from library

```
dlsite_remove_from_library <link>
```

Delete library link and entity.