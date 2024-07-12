#!/bin/bash

function my_zenity () {
    zenity \
        --list \
        --column="" \
        --text="" \
        $@
}

SELECTED_ITEM=$( my_zenity $@)

echo "/menu/done/${SELECTED_ITEM}" | socat - UNIX:${VF_SOCKET_PATH}
#echo "${SELECTED_ITEM}"

