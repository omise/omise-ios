#!/usr/bin/env bash
set -eo pipefail

: "${GOOGLE_APPLICATION_CREDENTIALS:?Need GOOGLE_APPLICATION_CREDENTIALS}"
: "${FIREBASE_APP_ID:?Need FIREBASE_APP_ID}"

RETENTION_DAYS=60

cutoff_epoch=$(date -u -d "$RETENTION_DAYS days ago" +%s)
token=$(gcloud auth application-default print-access-token)
project_number=$(echo "$FIREBASE_APP_ID" | cut -d':' -f2)

base_url="https://firebaseappdistribution.googleapis.com/v1/projects/${project_number}/apps/${FIREBASE_APP_ID}"

old_names=()
page_token=""

while :; do
  url="${base_url}/releases"
  [ -n "$page_token" ] && url+="?pageToken=${page_token}"

  resp=$(curl -s -H "Authorization: Bearer $token" "$url")

  while read -r release; do
    name=$(echo "$release" | jq -r '.name')
    create_time=$(echo "$release" | jq -r '.createTime' | sed -E 's/\.[0-9]+Z$/Z/')
    epoch=$(date -u -d "$create_time" +%s)
    if (( epoch < cutoff_epoch )); then
      old_names+=("$name")
    fi
  done < <(echo "$resp" | jq -c '.releases[]?')

  page_token=$(echo "$resp" | jq -r '.nextPageToken // empty')
  [ -z "$page_token" ] && break
done

count=${#old_names[@]}
if [ "$count" -eq 0 ]; then
  echo "Cleanup: no releases older than ${RETENTION_DAYS} days."
  exit 0
fi

payload=$(jq -nc --argjson names "$(printf '%s\n' "${old_names[@]}" | jq -R . | jq -s .)" '{names: $names}')
batch_url="${base_url}/releases:batchDelete"
http_code=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "$batch_url")

if [ "$http_code" -ne 200 ]; then
  for name in "${old_names[@]}"; do
    curl -s -X DELETE \
      -H "Authorization: Bearer $token" \
      "https://firebaseappdistribution.googleapis.com/v1/${name}" >/dev/null
  done
fi

echo "Cleanup: deleted $count release(s) older than ${RETENTION_DAYS} days."
