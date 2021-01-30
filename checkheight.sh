chainheight=$(curl -s https://crossfire.crypto.com/commit | jq -r '.result.signed_header.header.height')
localheight=$(docker exec -i crossfire-docker_crossfire_1 curl -s http://127.0.0.1:26657/commit | jq -r '.result.signed_header.header.height')
difference=$(expr $chainheight - $localheight)

echo "Chain height: $chainheight"
echo "Local height: $localheight"
echo "Height difference: $difference"