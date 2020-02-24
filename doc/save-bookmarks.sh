#!/bin/bash

for F in $*; do
    echo $F
    gio info -a "metadata::evince::bookmarks" "$F" |
        sed '1,2d; 3s/  metadata::evince::bookmarks: //' > "$F.bookmarks"
done
