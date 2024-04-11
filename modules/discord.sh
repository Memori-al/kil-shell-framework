#!/bin/bash


# time title message color
function _Color() {
    case $_code_ in
        "400") # 오류 색상 : 빨강
            _color_=fc3003
        ;;
        "200") # 성공 색상 : 파랑
            _color_=002fff
        ;;
        "300") # 경고 색상 : 노랑
            _color_=fff700
        ;;
		# 아래 색상들은 현재 비활성화 상태
        "purple")
            _color_=7e07e6
        ;;
        "orange")
            _color_=ff8800
        ;;
        "white")
            _color_=ffffff
        ;;
        "black")
            _color_=000000
        ;;
        "green")
            _color_=00ff22
        ;;
        *)
			# 내부함수	호출 shell	메세지
            _Json "handler.sh" "Function _Color(): 해당 함수에서 파라미터 오류가 발생했습니다."
        ;;
    esac

	# 16진수로 변환
    _color_=$((16#$_color_))
}


function _Form() {
	# 결과 정의 200 성공 : 400 실패
    if [[ $_code_ == "200" ]]; then
        _result_="성공"
    else
        _result_="실패"
    fi

	# 해당 스크립트가 수행되는 서버의 ip 주소 변수 할당
    _ip_=$(ip addr show ens192 | grep 'inet ' | awk '{print $2}' | cut -f1 -d'/')

_form_data_success_() {
    cat <<EOF
{
  "content": "",
  "embeds": [{
    "title": "쉘 스크립트 통신 결과",
    "description": "",
    "url": "https://example.com",
    "timestamp": "$(date +"%Y-%m-%dT%H:%M:%S%z")",
    "color": $_color_,
    "footer": {
      "text": "수행 시간",
      "icon_url": "https://cdn-icons-png.flaticon.com/512/3133/3133158.png"
    },
    "thumbnail": {
      "url": ""
    },
    "image": {
      "url": ""
    },
    "author": {
      "name": "Shell Manager",
      "icon_url": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOfciayL8Z_uODUu9EvIsZmCwCdEWewv7BtinnUhRmxg&s"
    },
    "fields": [
      {
        "name": "\`IP\` : $_ip_",
        "value": "\`실행자\` : **${_user_}** \n\`스크립트\` : **${_file_}** \n\`실행결과\` : **${_result_}**\n\`메세지\` : **${_message_}**",
        "inline": true
      }
    ]
  }]
}
EOF
}

_form_data_failed_() {
    cat <<EOF
{
  "content": "",
  "embeds": [{
    "title": "쉘 스크립트 통신 결과",
    "description": "",
    "url": "https://example.com",
    "timestamp": "$(date +"%Y-%m-%dT%H:%M:%S%z")",
    "color": $_color_,
    "footer": {
      "text": "수행 시간",
      "icon_url": "https://cdn-icons-png.flaticon.com/512/3133/3133158.png"
    },
    "thumbnail": {
      "url": ""
    },
    "image": {
      "url": ""
    },
    "author": {
      "name": "Shell Manager",
      "icon_url": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOfciayL8Z_uODUu9EvIsZmCwCdEWewv7BtinnUhRmxg&s"
    },
    "fields": [
      {
        "name": "\`IP\` : $_ip_",
        "value": "\`실행자\` : **${_user_}** \n\`스크립트\` : **$_file_**\n\`실행결과\` : **${_result_}**\n\`실패사유\` : ${_message_}",
        "inline": true
      }
    ]
  }]
}
EOF
}

    _Sender
}


function _Sender() {
    # Generalized Discord Notification Script
    # https://discord.com/api/webhooks/1222828328843743283/0EA4_rJ4nbmgv0mXEjSozW48D0zhjfvR2-Xkzqg2USB6FCRZcg_ddxAq02U6phYTSjzT
    if [[ $_result_ == "성공" ]]; then
        curl -H "Content-Type: application/json" -X POST -d "$(_form_data_success_)" ${_discord_webhook_}
    else
        # Send POST request to Discord Webhook
        curl -H "Content-Type: application/json" -X POST -d "$(_form_data_failed_)" ${_discord_webhook_}
    fi
}


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


# discord.sh 실행 시 들어온 파라미터 출력
echo -e "[Discord Webhook Module\n$@\nJson Data Checked.]"

# 들어온 JSON 데이터 파싱
source ${_json_parser_sh_} "$@"

# 사용자 계정 전송
source ${_user_sh_} "$_user_"

# 오류 코드 전송
_Color "${_code_}"

# 파일명 및 메세지와 사용자계정 전송
_Form "${_file_}" "${_messages_}" "${_user_}"



# source ./handler.sh "$(basename "$0")" "$(date +"%Y-%m-%d") $(date "+%H:%M:%S")" "Parameters Error."