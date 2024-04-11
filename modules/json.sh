#!/bin/bash

function _Json() {
	local _destination_=$1
	# 오류 핸들러로의 JSON 폼 데이터 전송
	if [[ $_destination_ == "handler.sh" ]]; then
		local _messages_=$2
		# json 폼 데이터 생성
		json='{
			"source": "'$(basename "$0")'",
			"destination": "'${_destination_}'",
			"time": "'$(date +"%Y-%m-%d") $(date "+%H:%M:%S")'",
			"code": 400,
			"messages": "'${_messages_}'"
		}'
		source ${_handler_sh_} \"${_json_}\"
	fi
}

if [[ -z $@ ]]; ; then
    eval $(jq -r '. | to_entries[] | "export _\(.key)_=\"\(.value)\""' $@)
else
    _Json "handler.sh" "function void(): 들어온 파라미터가 없습니다."
fi
