#!/bin/bash
iface="eth0"
username=""
password=""
params=$(
  curl -s --interface "$iface" -L http://baidu.com -v 2>&1 \
  | grep '> GET .*auth.html' \
  | sed -e 's/^.*auth.html?//;s/ HTTP.*$//;s/ac-ip/acip/'
)
[ -z $params ] && echo "already online" && exit 0
params="${params}&agreed=1&validCode=aaaa"
params="${params}&userName=${username}&&userPass=${password}"
result=$(curl -s 'https://net-auth.shanghaitech.edu.cn:19008/portalauth/login' \
         --data "$params")
echo "auth result: $result"
if [ "true" == $(sed -E 's/^.*("success":\s*([a-z]*)).*$/\2/' <<< "$result") ]
then
  echo "auth succeeded"
  exit 0
fi
code=$(sed -E 's/^.*("errorcode":\s*"([0-9]*)").*$/\2/' <<< "$result")
echo "auth failed because" >&2
curl -s 'https://net-auth.shanghaitech.edu.cn:19008/material/custom/lang/common-zh.js' \
  | grep "$code" >&2
exit 1
