#!/bin/bash

_parm_=$1

while IFS=' ' read -r _user_ _name_; do
    if [[ $_parm_ == $_user_ ]]; then
        _user_="$_name_"
        echo "$_user_"
        break
    fi
done < "${_user_list_path_}"