#!/bin/bash
# openclaw200 告警发送脚本
# 创建时间：2026-04-08

TITLE="$1"
MESSAGE="$2"

# 颜色
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}发送告警：${TITLE}${NC}"

# 1. 邮件告警
if [ -n "${ALERT_EMAIL}" ]; then
    echo "${MESSAGE}" | mail -s "[openclaw200 告警] ${TITLE}" ${ALERT_EMAIL}
    echo "✓ 邮件已发送到 ${ALERT_EMAIL}"
fi

# 2. 钉钉机器人告警
if [ -n "${ALERT_DINGTALK_TOKEN}" ]; then
    curl -X POST https://oapi.dingtalk.com/robot/send \
      -H "Content-Type: application/json" \
      -d "{
        \"msgtype\": \"text\",
        \"text\": {
          \"content\": \"【openclaw200 备份告警】\\n标题：${TITLE}\\n内容：${MESSAGE}\\n时间：$(date)\"
        }
      }"
    echo "✓ 钉钉消息已发送"
fi

# 3. Webhook 告警
if [ -n "${ALERT_WEBHOOK}" ]; then
    curl -X POST ${ALERT_WEBHOOK} \
      -H "Content-Type: application/json" \
      -d "{
        \"title\": \"${TITLE}\",
        \"message\": \"${MESSAGE}\",
        \"timestamp\": \"$(date -Iseconds)\",
        \"source\": \"openclaw200\"
      }"
    echo "✓ Webhook 已发送"
fi

echo "告警发送完成"
