#!/bin/bash

set -eu

username="Packages Notification"
title="`hostname`"
message="`yum list updates -q |sed -e '1d' |awk -F ' ' '{print $1}' |tr '\n' ',' |sed 's/,/\\\n/g'`"
color="danger"
slack_webhook_url="https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX"

file=$(mktemp)
trap 'rm ${file}' EXIT

cat << EOL > "$file"
    payload={
        "link_names": 1,
        "attachments": [
            {
                "color": "${color}",
                "pretext": "更新対象のパッケージがあります。" ,
                "title": "${title}",
                "text": "${message}"
            }
        ]
    }
EOL

if [ "${message}" = "" ] ; then
  exit 1
fi
curl -s -S -X POST -d @"$file" "${slack_webhook_url}"