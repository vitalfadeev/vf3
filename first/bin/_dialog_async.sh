#!/bin/bash

function my_dialog () {
    dialog \
        --no-items \
        --output-fd 1 \
        --menu  \
        "Please select" 10 40 3  \
        $@
}

SELECTED_ITEM=$( my_dialog $@)

echo "/menu/done/${SELECTED_ITEM}" | socat - UNIX:${VF_SOCKET_PATH}
#echo "${SELECTED_ITEM}"
