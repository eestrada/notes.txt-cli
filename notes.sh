#!/bin/sh

# NOTE: Some inspiration for how to build shell script based CLI tools:
# * https://git.zx2c4.com/password-store/tree/src/password-store.sh
# * https://github.com/nmeum/tpm/blob/master/tpm
# * https://notabug.org/kl3/spm/src/master/spm

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
    _tempfile=$(TMPDIR="$(pwd)" mktemp)
    xclip -o -selection clipboard > $_tempfile
    $EDITOR $_tempfile

    # TODO: grab first line, strip trailing newline, trim it down to a
    # reasonable length, translate illegal characters into something safe for
    # filenames, then use this value as the filename.
    # head -n 1 $_tempfile | tr -d '\n' | tr 'bad' 'good'

    ln $_tempfile $(uuidgen)-datehere.txt

    # TODO: How to deal with the hardlink if it fails? Right now we
    # unequivically unlink the old file.
    unlink $_tempfile
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

