#!/bin/bash --

operatorAddress="cro1rtqp26y4z9pshwv3w06uqd3dt7myxth4l6fuu3"
validatorAddress="crocncl1rtqp26y4z9pshwv3w06uqd3dt7myxth4uh247d"
keyPasswordFile="$1"
keyring="cross-fire-testing"
#node=$5
runtime="5 minute"
endtime=$(date -ud "$runtime" +%s)


function chain-maind() {
  local argument="$1"
  #echo $variable
  runDocker="docker exec -i crossfire-docker_crossfire_1 chain-maind $argument"
  eval $runDocker
  #docker exec -i crossfire-docker_crossfire_1 chain-maind $partial_cmd --from ${keyring} --chain-id 'crossfire' --gas-prices 6000basetcro --yes < $keyPasswordFile
  #docker exec -i crossfire-docker_crossfire_1 chain-maind tx distribution withdraw-rewards crocncl1rtqp26y4z9pshwv3w06uqd3dt7myxth4uh247d --from cross-fire-testing --chain-id "crossfire" --gas-prices 6000basetcro --yes < ~/.bleh
}

function transaction() {
  local partial_cmd="$1"
  local cmd="${partial_cmd} --from ${keyring} --chain-id 'crossfire' --gas-prices 6000basetcro --yes < $keyPasswordFile"
  local retries=3
  success=false

  #chain-maind "$cmd"

  while (( retries > 0 )); do
    tx_hash=$(chain-maind "${cmd}" | jq '.txhash' | tr -d '"')
    if [ $? -eq 0 ] && [ ! -z "$tx_hash" ]; then
      success=true
      echo "Success"
      break;
    else
      ((retries=retries-1))
      echo "Failed to perform tx: '${partial_cmd}'. Waiting a couple of seconds and then retrying again. Retries remaining: ${retries}."
      #sleep 10s
    fi
  done
}

function collectreward() {
  #local commission=$1
  transaction "tx distribution withdraw-rewards ${validatorAddress}"
}

function collectcommission() {
  collectreward "--commission"
}

function run() {
  while [[ $(date -u +%s) -le $endtime ]]
  do
    echo "Time Now: `date +%H:%M:%S`"
  done
}


#chain-maind status

#run

collectreward
#transaction