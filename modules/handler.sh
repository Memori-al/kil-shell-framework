#!/bin/bash

: << "Use-case Definition"

    1. 핸들러 모듈은 shell framework 내의 모든 모듈에서 발생한 오류를 처리하기 위한 모듈입니다.
    2. 핸들러 모듈은 오류 발생 시, 해당 오류를 로컬에 저장하고, 웹훅을 통해 디스코드로 전달합니다.
    3. 웹훅을 통해 디스코드로의 전달 시, Json 폼의 출발지가 discord.sh 가 아닌 경우에만 전달합니다.
    4. 따라서 Json 폼의 출발지가 discord.sh 인 경우에는 로컬에 저장만 하고, 디스코드로 전달하지 않습니다.

    // 아래와 같은 순환 절차를 가지고 있습니다. //
    ( 디스코드 모듈 오류 O ) 기타 모둘 -> 핸들러 모듈 -> 디스코드 모듈 (오류 발생) -> 핸들러 모듈 -> 로컬 저장
    ( 디스코드 모듈 오류 X ) 기타 모듈 -> 핸들러 모듈 -> 디스코드 모듈 -> 웹훅을 통한 메세지 전달
    // 상기 순환 절차로 더욱 효율적인 오류 처리가 가능합니다. //
Use-case Definition


function _Check() {
    # 로컬 핸들러 로그 저장 디렉토리 검사
    if [[ ! -d "/var/log/kil_sh" ]]; then
        # 존재하지 않을 때, 생성
        mkdir -p /var/log/kil_sh
        if [[ $? == 1 ]]; then
            _Local_Handler "function _Check(): 디렉토리 생성에 실패했습니다."
        fi
    fi
    
    if [[ $1 == "discord.sh" ]] || [[ $1 == "init.sh" ]]; then
        _Local_Handler "$_messages_"
    else
        # 시간 파일명 메세지 색상
        _Json "discord.sh" "function _Check(): 발생한 오류를 웹훅 통신을 위하여 discord.sh 로 전달함."
    fi
}

function _Local_Handler() {
    # 로그 파일 정의
    local _log_file_="$(date +"%y-%m-%d")_handler.log"

    # [시간] 파일명 함수명: 오류내용
    echo "[$(date +"%Y-%m-%d") $(date "+%H:%M:%S")] $1"
    echo "[$(date +"%Y-%m-%d") $(date "+%H:%M:%S")] $1" >> $_log_file_
    exit 1
}


function _Json() {
	local _destination_=$1
	# 오류 핸들러로의 JSON 폼 데이터 전송
	if [[ $_destination_ == "discord.sh" ]]; then
        local _messages_=$2
		# json 폼 데이터 생성
		json='{
			"source": "'$(basename "$0")'",
			"destination": "'${_destination_}'",
			"time": "'$(date +"%Y-%m-%d") $(date "+%H:%M:%S")'",
			"code": 400,
			"messages": "'${_messages_}'"
		}'
		source ${_discord_sh_} \"${_json_}\"
	fi
    
    if [[ $? == 1 ]]; then
        _Local_Handler "function _Json(): 오류 핸들러로의 JSON 폼 데이터 전송에 실패했습니다."
    fi
}

# handler.sh 실행 시 들어온 파라미터 출력
echo -e "[handler Module\n$@\nJson Data Checked.]"

if [[ -n $@ ]]; then
    _Local_Handler "function void(): 들어온 파라미터가 없습니다."
fi

# 들어온 JSON 데이터 파싱
source ${_json_parser_sh_} "$@"

# 사용자 계정 전송
source ${_user_sh_} "$_user_"

# 내부 함수에 출발지 쉘 스크립트 전달
_Check "${_source_}" 