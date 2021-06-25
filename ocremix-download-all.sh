#!/bin/bash


SHOW_W="/tmp/ocremix-download-all-show_w.txt"
if [ -f "$SHOW_W" ]; then
    rm "$SHOW_W"
fi

DST="/dev/null"
if [ "@$1" = "@show" ]; then
    if [ "@$2" = "@c" ]; then
        if [ -f "license.txt" ]; then
            cat license.txt
        else
            echo "See license.txt in the ocremix-download-all directory"
            echo "or at <https://github.com/poikilos/ocremix-download-all>."
        fi
        exit 0
    fi
    DST="$SHOW_W"
fi
cat > $DST <<END
    ocremix-download-all syncs ocremix.org's library with a directory.
    Copyright (C) 2010 Kurin on ocremix.org

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
END
if [ -f "$SHOW_W" ]; then
    cat "$SHOW_W"
    rm "$SHOW_W"
    exit 0
else
    cat <<END
    ocremix-download-all  Copyright (C) 2010 Kurin on ocremix.org
    This program comes with ABSOLUTELY NO WARRANTY; for details type 'show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type 'show c' for details.
END
fi

FOLDER="OCRemix";
START=1;
END=3000;
MIRROR="ocrmirror.org";
LIMIT="100m";
WAIT=0;



cd $FOLDER
for ((i=$START;i<=$END;i++)); do
    strlen=${#i};
    case $strlen in
        "1") file="0000$i"; ;;
        "2") file="000$i";  ;;
        "3") file="00$i";   ;;
        "4") file="0$i";    ;;
        "5") file="$i";     ;;
    esac
    echo "Retrieving OCR$file DATA";
    url=$(curl --silent http://ocremix.org/remix/OCR$file/ | grep $MIRROR | sed 's/<a href=\"\(.*\)\">\(.*\)/\1/');
    if [ -n "$url" ]; then
        echo "Retrieving MP3";
        wget --limit-rate=$LIMIT -c -nv $url
        if [ $WAIT -gt 0 ]; then
            echo "Waiting $WAIT seconds.";
            sleep $WAIT;
        fi
    else
        echo "No file, skipping.";
    fi
done
