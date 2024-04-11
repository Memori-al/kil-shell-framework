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
    # 정의된 쉘 및 리소스 파일 경로 변수화
    eval $(jq -r '.defined | to_entries[] | "export _\(.key)_sh_=\"\(.value)\""' ../resources/settings.json)
    eval $(jq -r '.resources | to_entries[] | "export _\(.key)_path_=\"\(.value)\""' ../resources/settings.json)
	eval $(jq -r '.webhook | to_entries[] | "export _\(.key)_webhook_=\"\(.value)\""' ../resources/settings.json)
else
    # 도착지 메세지
    _Json "handler.sh" "function void(): 들어온 파라미터가 없습니다."
fi