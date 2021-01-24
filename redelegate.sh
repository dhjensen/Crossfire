#!/bin/bash --

operatorAddress="cro1rtqp26y4z9pshwv3w06uqd3dt7myxth4l6fuu3"
validatorAddress="crocncl1rtqp26y4z9pshwv3w06uqd3dt7myxth4uh247d"
keyPasswordFile="$1"
keyring="cross-fire-testing"
#node=$5

function chain-maind() {
  local argument="$1"
  #echo $variable
  runDocker="docker exec -i crossfire-docker_crossfire_1 chain-maind $argument"
  #echo "$runDocker"
  eval $runDocker
  #docker exec -i crossfire-docker_crossfire_1 chain-maind $partial_cmd --from ${keyring} --chain-id 'crossfire' --gas-prices 6000basetcro --yes < $keyPasswordFile
  #docker exec -i crossfire-docker_crossfire_1 chain-maind tx distribution withdraw-rewards crocncl1rtqp26y4z9pshwv3w06uqd3dt7myxth4uh247d --from cross-fire-testing --chain-id "crossfire" --gas-prices 6000basetcro --yes < ~/.bleh
}

function transaction() {
  local partial_cmd="$1"
  local cmd="${partial_cmd} --from ${keyring} --chain-id 'crossfire' --gas auto --gas-adjustment 1.5 --gas-prices 0.1basetcro --yes < $keyPasswordFile"
  local retries=3
  success=false

  while (( retries > 0 )); do
    #echo $cmd
    tx=$(chain-maind "${cmd}" 2>~/.error)
    if [ $? -eq 0 ]; then
      #echo "Printing tx: $tx"
      tx_hash=$(echo $tx | jq '.txhash' | tr -d '"')
      if [ ! -z "$tx_hash" ]; then
        success=true
        #echo $tx_hash
        break;
      fi
    else
      tx_timeout=$(grep -c "timed out waiting" < ~/.error)
      if [ $tx_timeout -eq 1 ]; then
        success=true
        #echo "Success but timeout"
        sleep 2
        break;
      else
        ((retries=retries-1))
        echo "Failed to perform tx: '${partial_cmd}'. Waiting a couple of seconds and then retrying again. Retries remaining: ${retries}."
      fi
    fi
  done
}

function collect_reward() {
  transaction "tx distribution withdraw-rewards ${validatorAddress}"
}

function collect_commission() {
  transaction "tx distribution withdraw-rewards ${validatorAddress} --commission"
}

function set_withdraw_addr {
  local address=$1
  transaction "tx distribution set-withdraw-addr $address"
}

function collect_reward_five_minutes() {
  runtime="5 minute"
  endtime=$(date -ud "$runtime" +%s)
  echo "$(date): Collect for 5 minutes"
  while [[ $(date -u +%s) -le $endtime ]]
  do
    #echo "Time Now: `date +%H:%M:%S`"
    collect_reward
  done
}

function set_withdraw_addr_five_minutes() {
  runtime="5 minute"
  endtime=$(date -ud "$runtime" +%s)
  echo "$(date): Set address for 5 minutes"
  while [[ $(date -u +%s) -le $endtime ]]
  do
    #echo "Time Now: `date +%H:%M:%S`"
    set_withdraw_addr $operatorAddress
  done
}


get_wallet_balance() {
  balance=$(chain-maind "query bank balances ${operatorAddress} --output json --denom basetcro | jq '.amount | tonumber'")
}

delegate() {
  get_wallet_balance
  echo "Current wallet balance is: ${balance} basetcro"
  delegatable="$(($balance-1000))"
  echo "Can delegate a total of ${delegatable} basetcro"

  if [ $delegatable -gt 0 ]; then
    transaction "tx staking delegate ${validatorAddress} ${delegatable}basetcro"
    if [ "$success" = true ]; then
      echo "Successfully performed delegation to ${validatorAddress} - tx hash: ${tx_hash}"
    else
      echo "Failed to delegate to ${validatorAddress} !"
    fi
  else
    echo "We don't have sufficient basetcro to delegate"
  fi
}

function run() {
  while true
  do
    set_withdraw_addr_five_minutes
    #collect_reward_five_minutes
    collect_commission
    delegate
  done
}

run
