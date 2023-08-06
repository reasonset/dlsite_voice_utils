#!/bin/zsh

export DLSITE_LIBRARY_DIR="$HOME/dlsite/.library"

dlsite_extract() {
  typeset usage=("dlsite_extract [-u|--unconvert] [-i|--insjis] [-o|--outsjis] [-7|--7z] <source_file>")
  typeset flag_uc flag_os flag_is flag_7z
  typeset -g dexname
  
  if [[ -z $DLSITE_LIBRARY_DIR ]]
  then
    print "DLsite Library Directory is not set." >&2
    return 1
  fi
  
  type 7z=$DLSITE_EXTRACT_7Z
  
  zmodload zsh/zutil
  zparseopts -D -F -K -- {u,-unconvert}=flag_uc {i,-insjis}=flag_is {o,-outsjis}=flag_os {7,-7z}=flag_7z || {
    print -l $usage >&2
    return 2
  }
  
  typeset source_file="$1"
  shift
  
  typeset filename_base=${${${source_file:t}:r}%.part<->}
 
  typeset outdir="$DLSITE_LIBRARY_DIR/${filename_base}" 
  mkdir "$outdir"
  
  if [[ -n $flag_7z ]]
  then
    7z l -slt "$source_file" | sed -n -e '0,/^----------/ d' -e '/^Path = / { s:Path = ::; s:/.*::; p }' | sort -u | read dexname # Extract article name (7z)
    7z x -o"$outdir" "$source_file"
  else
    case "${source_file:e}" in
      rar | exe)
        unrar lb "$source_file" | sed 's:/.*::' | sort -u | read dexname # Extract article name (unrar)
        unrar x -op"$outdir" "$source_file"
        ;;
      zip)
        if [[ -n $flag_uc ]]
        then
          unzip -l "$source_file" | sed -e '0,/^--/ d' -e '/^--/,$ d' | sed -e 's: *[0-9]*::' -e 's: *[0-9-]*::' -e 's: *[0-9:]* *::' -e 's:/.*::' | sort -u | read dexname # Extract article name (unzip)
          unzip "$source_file" -d "$outdir"
        elif [[ -n $flag_is ]]
        then
          unzip -I sjis -l "$source_file" | sed -e '0,/^--/ d' -e '/^--/,$ d' | sed -e 's: *[0-9]*::' -e 's: *[0-9-]*::' -e 's: *[0-9:]* *::' -e 's:/.*::' | sort -u | read dexname # Extract article name (unzip in Sjis)
          unzip -I sjis "$source_file" -d "$outdir"
        else
          unzip -O sjis -l "$source_file" | sed -e '0,/^--/ d' -e '/^--/,$ d' | sed -e 's: *[0-9]*::' -e 's: *[0-9-]*::' -e 's: *[0-9:]* *::' -e 's:/.*::' | sort -u | read dexname # Extract article name (unzip out Sjis)
          unzip -O sjis "$source_file" -d "$outdir"
        fi
        ;;
    esac
  fi
  
  typeset -i extract_status=$?

  print "$outdir"
  
  if (( extract_status == 0 ))
  then
    read -q "?Is it OK? [y/N]"
    extract_status=$?
  fi
  
  print "$outdir"
  
  if (( extract_status == 0 ))
  then
    print "COMPLETED. DELETE SOURCE."
    rm -v "${source_file:h}/${filename_base}"(.part<->|).(zip|rar|exe)
    typeset -g dexfile="${outdir:t}"
    typeset -g dexfpath="${outdir}"
  else
    print "DELETE OUTPUT."
    print "rm -rv $outdir"
    rm -rv "$outdir"
  fi
}

dlsite_movelink() {
  ln -srv "$(readlink -f "$1")" "$2" && rm -v "$1"
}

dlsite_remove_from_library() {
  typeset original_file="$(readlink -f "$1")"
  rm -rv "$original_file" && rm -v "$1"
}