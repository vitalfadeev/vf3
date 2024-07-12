#!/bin/bash

function my_xmenu () {
    xmenu
}

SELECTED_ITEM=$( my_xmenu)

echo "/menu/done/${SELECTED_ITEM}" | socat - UNIX:${VF_SOCKET_PATH}
#echo "${SELECTED_ITEM}"

