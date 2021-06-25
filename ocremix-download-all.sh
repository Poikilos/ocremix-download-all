#!/bin/bash
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
