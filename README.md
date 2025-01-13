# Azure CLI Quick Start Guide

This guide will walk you through logging into Azure, updating the Azure CLI, and running Bash commands to set up resources using the Azure CLI Cloud Shell within the Azure Portal.

## Prerequisites
- Access to [Azure Portal](https://portal.azure.com/).
- Basic understanding of Azure resources.

---

## Steps

### 1. Open Azure CLI Cloud Shell in the Azure Portal
1. Log in to [Azure Portal](https://portal.azure.com/).
2. In the top-right corner of the portal, click on the **Cloud Shell** icon (a `>`_ symbol).
3. Choose **Bash** as your shell environment if prompted.
4. The Cloud Shell will open at the bottom of your browser.

### 2. Update Variables and Run the Script
1. Copy the code block below.
2. Paste code into a application without reformating.
3. Update the variables (e.g., Subscription, ResourceGroupName, etc.) with your desired values.
4. Copy update code.
5. Paste it into the Cloud Shell.
7. Press **Enter** to execute the script.

---

### Code - Create or Update an Azure Web Application

```bash
# Define variables
Subscription="<update>" # Update with Subscription Name or ID
ResourceGroupName="<resourcegroupname>-rsg" # Update with desired Resource Group name
WebAppName="<webappname>-app" # Update with desired Web App name, which will also be the subdomain of the app
AppServicePlanName="<appserviceplanname>-asp" # Update with desired App Service Plan name
Location="centralus" # Update with desired Location (az account list-locations -o table)
Sku="F1" # Update with desired SKU "F1, B1, B2"
ContainerImage="index.docker.io/<username/imsage:tag>" # Update with desired Container URL/Image:Tag
Tags=("owner=<name>" "email=<email>") # Update with Name and Email

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
```

---

### 3. Verify Resource Creation
After running the script, verify the resources:
- In the Azure Portal, navigate to **Resource Groups** to check your newly created resource group.
- Check **App Services** for the web app.

### 4. Update Azure Web Application Network Restriction for F5 Distributed Cloud

```bash
# Define variables for resource group name and web app name
Subscription="<update>" #Update with Subscription Name or ID
ResourceGroupName="<resourcegroupname>-rsg" #Update with target Resource Group name
WebAppName="<webappname>-app" #Update with target Web App name.

# Define the URL containing the IP ranges
url="https://docs.cloud.f5.com/docs-v2/downloads/platform/reference/network-cloud-ref/ips-domains.txt"

echo "Fetching data from URL: $url..."
# Fetch the data from the URL
data=$(curl -s "$url")

# Define the start and end markers
start_marker="### Public IPv4 Subnet Ranges for F5 Regional Edges"
end_marker="### Public IPv4 Subnet Ranges for F5 Content Distribution Network Services"

echo "Extracting relevant IP ranges..."
# Extract the relevant section between the markers
filtered_ranges=$(echo "$data" | awk "/$start_marker/{flag=1; next} /$end_marker/{flag=0} flag" | grep -oE '\b[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+\b' | sort -u)

# Group size for IP ranges
group_size=6
group_number=1
total_groups=0

echo "Grouping IP ranges into batches of $group_size..."
# Temporary file to store grouped IP ranges
temp_file=$(mktemp)

# Group IP ranges into batches of 6
current_group=()
for ip in $filtered_ranges; do
    current_group+=("$ip")
    if [ ${#current_group[@]} -eq $group_size ]; then
        echo "${current_group[*]}" | tr ' ' ',' >> "$temp_file"
        current_group=()
        group_number=$((group_number + 1))
        total_groups=$((total_groups + 1))
    fi
done

# Add the remaining IPs to a group if any
if [ ${#current_group[@]} -gt 0 ]; then
    echo "${current_group[*]}" | tr ' ' ',' >> "$temp_file"
    total_groups=$((total_groups + 1))
fi

# Setting desired Azure Subscription
az account set --subscription "$Subscription"

echo "Removing existing access restriction rules from $WebAppName..."
# Step 1: Remove existing access restriction rules
for i in $(seq 1 $total_groups); do
    rule_name="ipXC$i"
    echo "Removing rule: $rule_name"
    az webapp config access-restriction remove --resource-group "$ResourceGroupName" \
                                                --name "$WebAppName" \
                                                --rule-name "$rule_name" &>/dev/null
done

echo "Adding new access restriction rules to $WebAppName..."
# Step 2: Add new access restriction rules
priority=100
group_number=1
while IFS= read -r ip_group; do
    rule_name="ipXC$group_number"
    echo "Adding rule: $rule_name with IPs: $ip_group and priority: $priority"
    az webapp config access-restriction add --resource-group "$ResourceGroupName" \
                                             --name "$WebAppName" \
                                             --rule-name "$rule_name" \
                                             --ip-address "$ip_group" \
                                             --priority "$priority" \
                                             --action Allow &>/dev/null
    priority=$((priority + 1))
    group_number=$((group_number + 1))
done < "$temp_file"

# Clean up temporary file
rm -f "$temp_file"

echo "Restriction rule update for $WebAppName has been completed."
```
**_NOTE:_** Restriction group removal will error if group isn't present. No action is needed.

---

## Troubleshooting
- **Authentication issues**: Ensure you’re logged into Azure in the Cloud Shell.
- **Permission errors**: Confirm your Azure account has the necessary permissions to create resources.

---

For more details, refer to the [Azure CLI documentation](https://learn.microsoft.com/en-us/cli/azure/) and the [Azure Portal documentation](https://learn.microsoft.com/en-us/azure/azure-portal/).

