#!/bin/bash

# Redirect stdin to read from list-of-obsolete-pages.md
while read S E; do
    echo $S .. $E

    for (( FN=$S ; FN <= $E ; ++FN )) ; do
        F=$( printf '%04d' $FN )
        echo Mark pg_$F.pdf
        pdftk old/pg_$F.pdf stamp ../redx.pdf output ./pg_$F.pdf
    done
    echo
done

