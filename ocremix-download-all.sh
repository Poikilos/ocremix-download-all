#!/bin/bash


SHOW_W="/tmp/ocremix-download-all-show_w.txt"
if [ -f "$SHOW_W" ]; then
    rm "$SHOW_W"
fi

_DATE_STRING="`date '+%Y-%m-%d'`"
LOG_PATH="$HOME/.var/log/ocremix-download-all-$_DATE_STRING.log"
# ^ such as ~/.var/log/ocremix-download-all-2021-10-12.log

echo | tee -a "$LOG_PATH"
echo "#`date`" | tee -a "$LOG_PATH"

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

if [ -z "$FOLDER" ]; then FOLDER="OCRemix"; fi
if [ -z "$START" ]; then START=1; fi
if [ -z "$END" ]; then END=3000; fi
if [ -z "$MIRROR" ]; then MIRROR="ocrmirror.org"; fi
if [ -z "$LIMIT" ]; then LIMIT="100m"; fi
if [ -z "$WAIT" ]; then WAIT=0; fi

myConfsDir="$HOME/.config/ocremix-download-all"
mkdir -p "$myConfsDir"
myConf="$myConfsDir/settings.rc"

_FOLDER="$FOLDER"
_START="$START"
_END="$END"
_LIMIT="$LIMIT"
_WAIT="$WAIT"

if [ -f "$myConf" ]; then
    . $myConf
fi

if [ "@$SHOW_BANDWIDTH_WARNING" = "@" ]; then
    SHOW_BANDWIDTH_WARNING=true
fi

if [ ! -f "$myConf" ]; then
    touch "$myConf"
fi

if [ -z "`cat $myConf | grep FOLDER`" ]; then
    echo "FOLDER=\"$FOLDER\"" >> "$myConf"
fi
if [ -z "`cat $myConf | grep START`" ]; then
    echo "START=$START" >> "$myConf"
fi
if [ -z "`cat $myConf | grep END`" ]; then
    echo "END=$END" >> "$myConf"
fi
if [ -z "`cat $myConf | grep MIRROR`" ]; then
    echo "MIRROR=$MIRROR" >> "$myConf"
fi
if [ -z "`cat $myConf | grep LIMIT`" ]; then
    echo "LIMIT=$LIMIT" >> "$myConf"
fi
if [ -z "`cat $myConf | grep WAIT`" ]; then
    echo "WAIT=$WAIT" >> "$myConf"
fi

echo

echo "\"$myConf\":"
cat "$myConf"

echo
_CHANGED=false
if [ "@$_FOLDER" != "@" ]; then
    FOLDER="$_FOLDER"
    echo "overridden by environment: FOLDER=$FOLDER"
    _CHANGED=true
fi
if [ "@$_START" != "@" ]; then
    START="$_START"
    echo "overridden by environment: START=$START"
    _CHANGED=true
fi
if [ "@$_END" != "@" ]; then
    END="$_END"
    echo "overridden by environment: END=$END"
    _CHANGED=true
fi
if [ "@$_MIRROR" != "@" ]; then
    MIRROR="$_MIRROR"
    echo "overridden by environment: MIRROR=$MIRROR"
    _CHANGED=true
fi
if [ "@$_WAIT" != "@" ]; then
    WAIT="$_WAIT"
    echo "overridden by environment: WAIT=$WAIT"
    _CHANGED=true
fi

if [ "@$_CHANGED" = "@true" ]; then
    echo
    printf "* saving the above new settings..."
    echo "FOLDER=\"$FOLDER\"" > "$myConf"
    echo "START=$START" >> "$myConf"
    echo "END=$END" >> "$myConf"
    echo "MIRROR=$MIRROR" >> "$myConf"
    echo "LIMIT=$LIMIT" >> "$myConf"
    echo "WAIT=$WAIT" >> "$myConf"
    echo "SHOW_BANDWIDTH_WARNING=$SHOW_BANDWIDTH_WARNING" >> "$myConf"
    echo "LAST_RUN_DATE=`date '+%Y-%m-%d'`" >> "$myConf"
    if [ $? -ne 0 ]; then
        echo "FAILED"
    else
        echo "OK"
    fi
fi
echo


if [ "@$SHOW_BANDWIDTH_WARNING" = "@true" ]; then
    echo
    echo "First download using torrent to avoid slamming the servers:"
    echo "<https://ocremix.org/torrents>"
    echo
    echo "then use this script to only download updated files, otherwise change the START and END environment variables in $myConf (limit the bitrate in bytes as per wget --limit-rate using the LIMIT setting)!"
    sleep 2
    echo "Press Ctrl C within 5 seconds to cancel..."
    sleep 1
    echo "4..."
    sleep 1
    echo "3..."
    sleep 1
    echo "2..."
    sleep 1
    echo "1..."
    sleep 1
    echo "SHOW_BANDWIDTH_WARNING=false" >> "$myConf"
fi


cd "$FOLDER"
if [ $? -ne 0 ]; then
    echo "Error: 'cd \"$FOLDER\"' failed."
    exit 1
else
    echo "* in \"`pwd`\""
fi


echo "#PWD=\"`pwd`\"" | tee -a "$LOG_PATH"
echo "#START=$START" | tee -a "$LOG_PATH"
echo "#END=$END" | tee -a "$LOG_PATH"

for ((i=$START;i<=$END;i++)); do
    strlen=${#i};
    ERROR=""
    case $strlen in
        "1") file="0000$i"; ;;
        "2") file="000$i";  ;;
        "3") file="00$i";   ;;
        "4") file="0$i";    ;;
        "5") file="$i";     ;;
    esac
    printf "* Retrieving OCR$file DATA..."
    LOGGABLE_HTML_URL="https://ocremix.org/remix/OCR$file"
    url=$(curl --silent https://ocremix.org/remix/OCR$file | grep $MIRROR | sed 's/<a href=\"\(.*\)\">\(.*\)/\1/');
    url=$(echo $url | sed 's/<[^>]*>/\n/g');
    url=$(echo "$url" | sed 's/&amp;/\&/g'); # replace &amp; with & (See <https://www.unix.com/unix-for-dummies-questions-and-answers/158742-replace.html>)
    # ^ remove additional tags such as <li>
    if [ -n "$url" ]; then
        # -n: non-zero-length string
        DL_NAME="${url##*/}" # Get the basename from a URL in bash.
        if [ ! -f "$DL_NAME" ]; then
            printf "Retrieving MP3...";
            # echo "* $DL_NAME doesn't exist in `pwd`."
            wget --limit-rate=$LIMIT --continue --no-verbose $url
            # -c: --continue
            # -nv: --no-verbose
            # -nc: --no-clobber
            if [ $? -ne 0 ]; then
                ERROR="FAILED: Downloading $url failed (See <$LOGGABLE_HTML_URL>)."
                echo "#$ERROR" | tee -a "$LOG_PATH"
            else
                echo "OK"
                echo "#<$url>:" | tee -a "$LOG_PATH"
                echo "`pwd`/$DL_NAME" | tee -a "$LOG_PATH"
            fi
            if [ $WAIT -gt 0 ]; then
                echo "Waiting $WAIT seconds.";
                sleep $WAIT;
            fi
        else
            # echo "* INFO: \"`pwd`/$DL_NAME\" already exists"
            echo "#`pwd`/$DL_NAME" | tee -a "$LOG_PATH"
        fi
    else
        # ERROR="* Error: URL=\"$url\" (blank) for OCR$file (See <$LOGGABLE_HTML_URL>)";
        ERROR="* INFO: There was no song URL at the page <$LOGGABLE_HTML_URL> (This is only a problem if it happens in all cases)."
        echo "$ERROR" | tee -a "$LOG_PATH"
    fi
done

echo "# Done $START to $END" | tee -a "$LOG_PATH"
