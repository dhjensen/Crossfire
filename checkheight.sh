echo "Chain height:"
curl -s https://crossfire.crypto.com/commit | jq "{height: .result.signed_header.header.height}"
echo -e  "\nLocal height:"
docker exec -i crossfire-docker_crossfire_1 curl -s http://127.0.0.1:26657/commit | jq '{height: .result.signed_header.header.height}'