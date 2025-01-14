# Azure CLI Quick Start Guide

This guide will walk you through logging into Azure, updating the Azure CLI, and running Bash commands to set up resources using the Azure CLI Cloud Shell within the Azure Portal.

## Prerequisites
- Access to [Azure Portal](https://portal.azure.com/).
- Basic understanding of Azure resources.

---

## Steps - Azure Web Application

### 1. Open Azure CLI Cloud Shell in the Azure Portal
1. Log in to [Azure Portal](https://portal.azure.com/).
2. In the top-right corner of the portal, click on the **Cloud Shell** icon (a `>`_ symbol).
3. Choose **Bash** as your shell environment if prompted.
4. The Cloud Shell will open at the bottom of your browser.

### 2. Update Variables and Run the Script
1. Copy the code block below.
2. Paste it into the Cloud Shell.
3. Press **Enter** to execute the script.

---

### Code - Create or Update an Azure Web Application

```bash
#!/bin/bash

# Define color codes
YELLOW='\033[0;33m'
RESET='\033[0m'

while true; do
    # List available subscriptions
    echo -e "${YELLOW}Fetching available subscriptions...${RESET}"
    Subscriptions=$(az account list --query "[].{Name:name, ID:id}" -o tsv)
    
    if [[ -z "$Subscriptions" ]]; then
        echo -e "${YELLOW}No subscriptions found. Please ensure you are logged in to Azure.${RESET}"
        exit 1
    fi

    # Display subscriptions with numbers
    echo -e "${YELLOW}Available Subscriptions:${RESET}"
    IFS=$'\n'  # Set IFS to handle multi-line input correctly
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
        Subscription="${SubscriptionArray[$((Selection-1))]}"
        echo -e "${YELLOW}Selected Subscription ID:${RESET} $Subscription"
    else
        echo -e "${YELLOW}Invalid selection. Please try again.${RESET}"
        continue
    fi

    # Prompt for app name
    read -p "$(echo -e ${YELLOW}Name your app [e.g., yourname-demoapp]: ${RESET})" AppBaseName

    # Generate names based on app name
    ResourceGroupName="${AppBaseName}-rsg"
    AppServicePlanName="${AppBaseName}-asp"
    WebAppName="${AppBaseName}-app"

    # Allow users to override default names
    echo ""
    echo -e "${YELLOW}Generated Resource Group name:${RESET} $ResourceGroupName"
    read -p "$(echo -e ${YELLOW}Would you like to use this name? [Y/N]: ${RESET})" ConfirmRsg
    if [[ "$ConfirmRsg" != "Y" && "$ConfirmRsg" != "y" ]]; then
        read -p "$(echo -e ${YELLOW}Enter custom Resource Group name: ${RESET})" ResourceGroupName
    fi

    echo -e "${YELLOW}Generated App Service Plan name:${RESET} $AppServicePlanName"
    read -p "$(echo -e ${YELLOW}Would you like to use this name? [Y/N]: ${RESET})" ConfirmAsp
    if [[ "$ConfirmAsp" != "Y" && "$ConfirmAsp" != "y" ]]; then
        read -p "$(echo -e ${YELLOW}Enter custom App Service Plan name: ${RESET})" AppServicePlanName
    fi

    echo -e "${YELLOW}Generated Web App name:${RESET} $WebAppName"
    read -p "$(echo -e ${YELLOW}Would you like to use this name? [Y/N]: ${RESET})" ConfirmWebApp
    if [[ "$ConfirmWebApp" != "Y" && "$ConfirmWebApp" != "y" ]]; then
        read -p "$(echo -e ${YELLOW}Enter custom Web App name: ${RESET})" WebAppName
    fi

    # Display location options
    echo -e "${YELLOW}Available Locations:${RESET}"
    LocationOptions=("eastus" "eastus2" "centralus" "westus" "westus2" "Enter your own")
    for i in "${!LocationOptions[@]}"; do
        echo -e "[$((i + 1))] ${YELLOW}${LocationOptions[$i]}${RESET}"
    done

    # Prompt user to select a location
    echo ""
    read -p "$(echo -e ${YELLOW}Select a location or enter your own [number]: ${RESET})" LocationSelection

    if [[ "$LocationSelection" =~ ^[0-9]+$ && "$LocationSelection" -ge 1 && "$LocationSelection" -le "${#LocationOptions[@]}" ]]; then
        if [[ "$LocationSelection" -eq "${#LocationOptions[@]}" ]]; then
            read -p "$(echo -e ${YELLOW}Enter your custom location: ${RESET})" Location
        else
            Location="${LocationOptions[$((LocationSelection - 1))]}"
        fi
        echo -e "${YELLOW}Selected Location:${RESET} $Location"
    else
        echo -e "${YELLOW}Invalid selection. Please try again.${RESET}"
        continue
    fi

    # Display SKU options
    echo -e "${YELLOW}Available SKUs:${RESET}"
    SkuOptions=("F1" "B1" "B2" "Enter your own")
    for i in "${!SkuOptions[@]}"; do
        echo -e "[$((i + 1))] ${YELLOW}${SkuOptions[$i]}${RESET}"
    done

    # Prompt user to select a SKU
    echo ""
    read -p "$(echo -e ${YELLOW}Select a SKU or enter your own [number]: ${RESET})" SkuSelection

    if [[ "$SkuSelection" =~ ^[0-9]+$ && "$SkuSelection" -ge 1 && "$SkuSelection" -le "${#SkuOptions[@]}" ]]; then
        if [[ "$SkuSelection" -eq "${#SkuOptions[@]}" ]]; then
            read -p "$(echo -e ${YELLOW}Enter your custom SKU: ${RESET})" Sku
        else
            Sku="${SkuOptions[$((SkuSelection - 1))]}"
        fi
        echo -e "${YELLOW}Selected SKU:${RESET} $Sku"
    else
        echo -e "${YELLOW}Invalid selection. Please try again.${RESET}"
        continue
    fi

    # Prompt for container image
    read -p "$(echo -e ${YELLOW}Enter Container Image URL [e.g., index.docker.io/username/image:tag]: ${RESET})" ContainerImage

    # Prompt for tags
    read -p "$(echo -e ${YELLOW}Enter Owner name: ${RESET})" OwnerName
    OwnerName=${OwnerName:-<name>}  # Default to <name> if empty
    read -p "$(echo -e ${YELLOW}Enter Email: ${RESET})" Email
    Email=${Email:-<email>}  # Default to <email> if empty
    Tags=("owner=$OwnerName" "email=$Email")

    # Display entered values for confirmation
    echo ""
    echo -e "${YELLOW}Please confirm the following values:${RESET}"
    echo -e "${YELLOW}Subscription:${RESET} $Subscription"
    echo -e "${YELLOW}Resource Group:${RESET} $ResourceGroupName"
    echo -e "${YELLOW}App Service Plan:${RESET} $AppServicePlanName"
    echo -e "${YELLOW}Web App:${RESET} $WebAppName"
    echo -e "${YELLOW}Location:${RESET} $Location"
    echo -e "${YELLOW}SKU:${RESET} $Sku"
    echo -e "${YELLOW}Container Image:${RESET} $ContainerImage"
    echo -e "${YELLOW}Tags:${RESET} ${Tags[@]}"
    echo ""

    # Ask for confirmation
    read -p "$(echo -e ${YELLOW}Are these values correct? [Y/N]: ${RESET})" Confirm

    if [[ "$Confirm" == "Y" || "$Confirm" == "y" ]]; then
        # Setting desired Azure Subscription
        az account set --subscription "$Subscription" && \

        # Create Resource Group
        az group create --name "$ResourceGroupName" \
                        --location "$Location" \
                        --tags "${Tags[@]}" && \

        echo "Resource Group $ResourceGroupName has been created." && \

        # Create App Service Plan
        az appservice plan create --name "$AppServicePlanName" \
                                  --resource-group "$ResourceGroupName" \
                                  --location "$Location" \
                                  --sku "$Sku" \
                                  --is-linux \
                                  --tags "${Tags[@]}" && \

        echo "App Service Plan $AppServicePlanName has been created." && \

        # Create Web App
        az webapp create --resource-group "$ResourceGroupName" \
                         --plan "$AppServicePlanName" \
                         --name "$WebAppName" \
                         --container-image-name "$ContainerImage" \
                         --tags "${Tags[@]}" && \

        echo "WebApp $WebAppName has been created."

        # Exit the loop after successful execution
        break
    else
        echo -e "${YELLOW}Please re-enter the values.${RESET}"
    fi
done
```

---



### 3. Verify WebApp Creation
After running the script, verify the resources:
- In the Azure Portal, navigate to **Resource Groups** to check your newly created resource group.
- Select the created **App Services** for the web app.
- within **Overview** click on the listed **Default domain** to browse to the site.

**_NOTE:_** This might take up to 5 mins, while the service becomes available for the first time.

## Optional Steps - Azure Network Restriction (Public)

### 1. Update Variables and Run the Script for 
1. Copy the code block below.
2. Paste it into the Cloud Shell.
3. Press **Enter** to execute the script.

### Code - Update Azure Web Application Network Restriction for F5 Distributed Cloud

```bash
Coming soon!
```
**_NOTE:_** Restriction group removal will error if group isn't present. No action is needed.


---

### 2. Verify Restriction Creation
After running the script, verify the resources:
- In the Azure Portal, navigate to **Resource Groups** to check your newly created resource group.
- Select the created **App Services** for the web app.
- Click on **Networking** on the left hand side, under **Settings**
- Click on **Enabled with access restrictions** for **Public network access**.

---

## Troubleshooting
- **Authentication issues**: Ensure you’re logged into Azure in the Cloud Shell.
- **Permission errors**: Confirm your Azure account has the necessary permissions to create resources.

---

For more details, refer to the [Azure CLI documentation](https://learn.microsoft.com/en-us/cli/azure/) and the [Azure Portal documentation](https://learn.microsoft.com/en-us/azure/azure-portal/).

