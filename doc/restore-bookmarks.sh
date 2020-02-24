#!/bin/bash

for F in $*; do
    echo $F
    gio set "$F" "metadata::evince::bookmarks" "`cat $F.bookmarks`"
done
