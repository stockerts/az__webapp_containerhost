#!/bin/bash

# Define color codes
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Prompt user for subscription
while true; do
    echo -e "${YELLOW}Fetching available subscriptions...${RESET}"
    Subscriptions=$(az account list --query "[].{Name:name, ID:id}" -o tsv 2>/dev/null)

    if [[ -z "$Subscriptions" ]]; then
        echo -e "${YELLOW}No subscriptions found. Please ensure you are logged in to Azure.${RESET}"
        exit 1
    fi

    # Display subscriptions
    echo -e "${YELLOW}Available Subscriptions:${RESET}"
    IFS=$'\n'
    SubscriptionArray=()
    i=1
    for Subscription in $Subscriptions; do
        Name=$(echo "$Subscription" | cut -f1)
        ID=$(echo "$Subscription" | cut -f2)
        echo -e "[$i] ${YELLOW}Name:${RESET} $Name ${YELLOW}ID:${RESET} $ID"
        SubscriptionArray+=("$ID")
        ((i++))
    done

    # Prompt user to select a subscription
    echo ""
    read -p "$(echo -e ${YELLOW}Enter the number of your desired subscription: ${RESET})" Selection

    if [[ "$Selection" =~ ^[0-9]+$ && "$Selection" -ge 1 && "$Selection" -le "${#SubscriptionArray[@]}" ]]; then
        Subscription="${SubscriptionArray[$((Selection - 1))]}"
        echo -e "${YELLOW}Selected Subscription ID:${RESET} $Subscription"
        az account set --subscription "$Subscription" || {
            echo -e "${YELLOW}Failed to set the subscription. Please try again.${RESET}"
            continue
        }
        break
    else
        echo -e "${YELLOW}Invalid selection. Please try again.${RESET}"
    fi
done

# Prompt user for resource group name
echo ""
read -p "$(echo -e ${YELLOW}Enter the Resource Group Name [e.g., my-resource-group]: ${RESET})" ResourceGroupName

# Prompt user for web app name
echo ""
read -p "$(echo -e ${YELLOW}Enter the Web App Name [e.g., yourname-appname-app]: ${RESET})" WebAppName

# Output the collected variables
echo -e "\n${YELLOW}Collected Variables:${RESET}"
echo -e "${YELLOW}Subscription:${RESET} $Subscription"
echo -e "${YELLOW}Resource Group:${RESET} $ResourceGroupName"
echo -e "${YELLOW}Web App:${RESET} $WebAppName"

# Ask for confirmation
read -p "$(echo -e ${YELLOW}Are these values correct? [Y/N]: ${RESET})" Confirm

if [[ "$Confirm" == "Y" || "$Confirm" == "y" ]]; then
    # Define the URL containing the IP ranges
    url="https://docs.cloud.f5.com/docs-v2/downloads/platform/reference/network-cloud-ref/ips-domains.txt"

    # Fetch the data from the URL
    echo ""
    echo -e "${YELLOW}Fetching IP ranges...${RESET}"
    data=$(curl -s "$url")
    if [[ -z "$data" ]]; then
        echo -e "${RED}Failed to fetch IP ranges. Please check the URL.${RED}"
        exit 1
    fi

    # Define start and end markers
    startMarker="### Public IPv4 Subnet Ranges for F5 Regional Edges"
    endMarker="### Public IPv4 Subnet Ranges for F5 Content Distribution Network Services"

    # Extract the relevant section between the markers
    filteredRanges=$(echo "$data" | awk "/$startMarker/{flag=1;next}/$endMarker/{flag=0}flag")

    # Filter lines to only keep valid IP ranges
    ipRanges=$(echo "$filteredRanges" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+' | sort -u)

    # Initialize variables for grouping
    groupSize=6
    groupNumber=1
    priority=100
    ipArray=($ipRanges)
    totalGroups=0
    declare -A ipGroups

    for ((i=0; i<${#ipArray[@]}; i+=groupSize)); do
        group=$(printf "%s," "${ipArray[@]:i:groupSize}")
        group=${group%,}
        ipGroups["ipXC$groupNumber"]="$group"
        echo "Created variable: ipXC$groupNumber = $group"
        ((groupNumber++))
        ((totalGroups++))
    done

    # Step 1: Remove existing access restriction rules
    echo ""
    echo -e "${YELLOW}Removing existing access restriction rules...${RESET}"
    for ((group=1; group<=totalGroups; group++)); do
        ruleName="ipXC$group"
        az webapp config access-restriction remove \
            --resource-group "$ResourceGroupName" \
            --name "$WebAppName" \
            --rule-name "$ruleName" &>/dev/null \
            && echo "Successfully removed access restriction rule: $ruleName" \
            || echo "Failed to remove access restriction rule: $ruleName"
    done

    # Step 2: Add new access restriction rules
    echo ""
    echo -e "${YELLOW}Adding new access restriction rules...${RESET}"
    for ((group=1; group<=totalGroups; group++)); do
        ruleName="ipXC$group"
        ipAddressList="${ipGroups[ipXC$group]}"
        az webapp config access-restriction add \
            --resource-group "$ResourceGroupName" \
            --name "$WebAppName" \
            --rule-name "$ruleName" \
            --action Allow \
            --priority "$priority" \
            --ip-address "$ipAddressList" &>/dev/null \
            && echo "Successfully added access restriction rule: $ruleName with IPs: $ipAddressList" \
            || echo "Failed to add access restriction rule: $ruleName"
        ((priority++))
    done

    echo -e "${YELLOW}Completed processing all access restriction rules.${RESET}"
else
    echo -e "${YELLOW}Operation cancelled by user.${RESET}"
fi
