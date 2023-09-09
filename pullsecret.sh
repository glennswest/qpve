export OFFLINE_ACCESS_TOKEN=$(cat .accesstoken)
export BEARER=$(curl \
--silent \
--data-urlencode "grant_type=refresh_token" \
--data-urlencode "client_id=cloud-services" \
--data-urlencode "refresh_token=${OFFLINE_ACCESS_TOKEN}" \
https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token | \
jq -r .access_token)
curl -X POST https://api.openshift.com/api/accounts_mgmt/v1/access_token --header "Content-Type:application/json" --header "Authorization: Bearer $BEARER" | jq


