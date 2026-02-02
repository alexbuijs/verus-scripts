#!/bin/bash
source $(dirname $BASH_SOURCE)/verus.sh

# Parse arguments
NO_CONVERSION=false
APPROXIMATE_CONVERSION=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n) NO_CONVERSION=true; shift ;;
    -a) APPROXIMATE_CONVERSION=true; shift ;;
    *) shift ;;
  esac
done

# Format function
format() {
  local type=$1
  local value=$2
  case "$type" in
    euro)        printf "€%'.2f" "$value" ;;
    bigeuro)     printf "€%'.0f" "$value" ;;
    usd)         printf "\$%'.2f" "$value" ;;
    smallnumber) printf "%.1f" "$value" ;;
    largenumber) printf "%'.9g" "$value" ;;
  esac
}

# Convert VRSC to EUR using safe.trade and kraken
verusconvert() {
  local vrsc=$1
  local safe_trade=$(curl -s "$SAFE_TRADE_URL" -H 'user-agent: Mozilla/5.0')
  local kraken=$(curl -s "$KRAKEN_URL")
  local vrsc_usdt=$(echo "$safe_trade" | jq -r '.avg_price')
  local usdt_eur=$(echo "$kraken" | jq -r '.result.USDTEUR.p[1]')
  local safe_trade_fee=3
  local usdt=$(echo "$vrsc * $vrsc_usdt - $safe_trade_fee" | bc -l)
  local kraken_conversion_fee=0.99
  local kraken_withdrawal_fee=1
  local eur=$(echo "$usdt * $usdt_eur * $kraken_conversion_fee - $kraken_withdrawal_fee" | bc -l)
  echo "$eur"
}

# Querying Verus CLI
info=$(verus getinfo)
mining_info=$(verus getmininginfo)
addresses=$(verus listaddressgroupings)
block_subsidy=$(verus getblocksubsidy)
balance=$(verus getbalance)

# Parsing Verus CLI responses
version=$(echo "$info" | jq -r '.VRSCversion')
local_blocks=$(echo "$mining_info" | jq -r '.blocks')
staking_enabled=$(echo "$mining_info" | jq -r '.staking')
connections=$(echo "$info" | jq -r '.connections')
chain=$(echo "$mining_info" | jq -r '.chain')
address=$(echo "$addresses" | jq -r '.[] | map(select(.[1] > 0.1)) | select(length > 0) | map("\(.[0]) (\(.[1] | floor))") | join("\n- ")')
current_reward=$(echo "$block_subsidy" | jq -r '.miner')
block_fee=$(echo "$mining_info" | jq -r '.averageblockfees')
staking_supply=$(echo "$mining_info" | jq -r '.stakingsupply')

# Querying price data
eur_per_vrsc=0
usd_per_vrsc=0
balance_in_eur=0

if [[ "$NO_CONVERSION" == false ]]; then
  if [[ "$APPROXIMATE_CONVERSION" == true ]]; then
    balance_in_eur=$(verusconvert "$balance")
    eur_per_vrsc=$(echo "$balance_in_eur / $balance" | bc -l)
  else
    # Note: This requires CMC_API_KEY environment variable to be set
    if [[ -n "$CMC_API_KEY" ]]; then
      cmc=$(curl -s -H "X-CMC_PRO_API_KEY: $CMC_API_KEY" -d "symbol=VRSC&convert=EUR" -G "$CMC_URL")
      eur_per_vrsc=$(echo "$cmc" | jq -r '.data.VRSC[0].quote.EUR.price')
      cmc_usd=$(curl -s -H "X-CMC_PRO_API_KEY: $CMC_API_KEY" -d "symbol=VRSC" -G "$CMC_URL")
      usd_per_vrsc=$(echo "$cmc_usd" | jq -r '.data.VRSC[0].quote.USD.price')
      balance_in_eur=$(echo "$balance * $eur_per_vrsc" | bc -l)
    else
      # Fall back to approximate conversion if no API key
      balance_in_eur=$(verusconvert "$balance")
      eur_per_vrsc=$(echo "$balance_in_eur / $balance" | bc -l)
    fi
  fi
fi

# Calculations
eur_per_reward=$(echo "$current_reward * $eur_per_vrsc" | bc -l)
expected_vrsc_per_day=$(echo "$balance * ($current_reward + $block_fee) * 720 / $staking_supply" | bc -l)
expected_days_per_reward=$(echo "$current_reward / $expected_vrsc_per_day" | bc -l)
expected_vrsc_per_year=$(echo "$expected_vrsc_per_day * 365" | bc -l)
expected_yearly_roi=$(echo "$expected_vrsc_per_year * 100 / $balance" | bc -l)
expected_eur_per_year=$(echo "$expected_vrsc_per_year * $eur_per_vrsc" | bc -l)

remote_blocks=$(_verus_remote_blocks)

# Output
echo "Version: $version"
echo "Current block: $local_blocks"
if [[ "$local_blocks" == "$remote_blocks" ]]; then
  echo "Up-to-date: yes"
else
  echo "Up-to-date: no (remote blocks: $remote_blocks)"
fi
echo "Staking enabled: $staking_enabled ($connections connections, chain: $chain)"
echo -e "Addresses:\n- $address"
echo "Current price: $(format euro "$eur_per_vrsc") ($(format usd "$usd_per_vrsc"))"
echo "Current balance: $(format largenumber "$balance") \$VRSC ($(format bigeuro "$balance_in_eur"))"
echo "Expected reward: $(format smallnumber "$current_reward") \$VRSC every $(format smallnumber "$expected_days_per_reward") days ($(format euro "$eur_per_reward"))"
echo "Expected yearly ROI: $(format smallnumber "$expected_yearly_roi")% ($(format bigeuro "$expected_eur_per_year"))"
