#!/bin/sh

# NOTE: Some inspiration for how to build shell script based CLI tools:
# * https://git.zx2c4.com/password-store/tree/src/password-store.sh
# * https://github.com/nmeum/tpm/blob/master/tpm
# * https://notabug.org/kl3/spm/src/master/spm

NOTES_DIR="$(pwd)"
ARCHIVE_DIR="${NOTES_DIR}/archive"

# export TODO_DIR="${HOME}/Syncthing/Notes-txt"

# echo "Globel config defaults"
# echo "$NOTES_DIR"
# echo "$ARCHIVE_DIR"

if [ -e ".notestxtrc" ] ; then
    . ".notestxtrc"
    # echo "Local config"
    # echo "$NOTES_DIR"
    # echo "$ARCHIVE_DIR"
elif [ -e "${HOME}/.notestxtrc" ] ; then
    . "${HOME}/.notestxtrc"
    # echo "Home dir config"
    # echo "$NOTES_DIR"
    # echo "$ARCHIVE_DIR"
fi

# exit 0

abort() {
    printf '%s\n' "${1}" 1>&2
    exit 1
}

search() {
    # TODO: figure out why I can't combine these two expressions into a single
    # `find` invocation.
    # find ./ -iname '*.txt' -or -iname '*.md' -exec egrep -nH "${1}" '{}' +

    find ./ -iname '*.txt' -exec egrep -nH "${1}" '{}' +
    find ./ -iname '*.md' -exec egrep -nH "${1}" '{}' +
}

new() {
    _tempfile=$(TMPDIR="${NOTES_DIR}" mktemp)

    xclip -o -selection clipboard > $_tempfile
    $EDITOR $_tempfile

    # NOTE: stripped out characters are loosely based on reserved characters
    # mentioned here:
    # https://en.wikipedia.org/wiki/Filename#Comparison_of_filename_limitations

    # NOTE: <Get the first line> | <remove potentially illegal characters> |
    # <make no longer than 60 characters> | <strip leading and trailing spaces>
    _title="$(head -n 1 $_tempfile | tr -d '#$?%*:|()<>.,"/\n\\' | cut -c 1-60 | sed -E -e 's/^[ _-]*//' -e 's/[ _-]*$//')"
    _full_title="${_title}-$(TZ=UTC date "+%Y%m%dT%H%M%SZ").txt"

    ln $_tempfile "${_full_title}"
    unlink $_tempfile

    test -f "${_full_title}"
    return $?
}

PROGRAM="${0##*/}"
COMMAND="$1"

# if [ $# -gt 2 ]; then
#   printf "$PROGRAM doesn't accept more than two arguments."
#   exit 1
# fi

case "${1}" in
  "new")    new "${2}" ;;
  "search") search "${2}" ;;
  *) abort "USAGE: $PROGRAM COMMAND ENTRY" ;;
esac

