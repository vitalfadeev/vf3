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

# echo "${VF_EVENT_TPL}${SELECTED_ITEM}" | socat - UNIX:/tmp/vf_bus.soc 
echo "${SELECTED_ITEM}"
