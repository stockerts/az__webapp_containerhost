# Azure CLI Quick Start Guide

This guide will walk you through logging into Azure, updating the Azure CLI, and using Bash to execute commands. It also includes a code block for setting up Azure resources using the Azure CLI and instructions for using the Azure Portal UI.

## Prerequisites
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed.
- A Bash shell environment.

---

## Steps

### 1. Log In to Azure
#### Using Azure CLI
To log into your Azure account:
```bash
az login
```
This will open a browser window for authentication. Follow the on-screen instructions to complete the process. If you’re working on a headless environment, use:
```bash
az login --use-device-code
```

#### Using Azure Portal
1. Go to [Azure Portal](https://portal.azure.com/).
2. Log in with your Azure account credentials.
3. Once logged in, navigate to the **Dashboard** to view and manage your resources.

### 2. Update the Azure CLI
To ensure you’re using the latest version of the Azure CLI:
```bash
az upgrade
```
Follow any prompts to complete the update.

### 3. Using Bash to Execute Azure Commands
Bash is commonly used for scripting Azure CLI commands. Use the following example script to set up Azure resources:

---

### Code
Copy and paste the following code block into your Bash shell to set up an Azure environment:

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

### 4. Setting Up Azure Resources Using the Azure Portal
1. **Create a Resource Group**:
   - In the Azure Portal, search for **Resource Groups** in the search bar.
   - Click **+ Create**.
   - Fill in the required fields:
     - **Subscription**: Select your Azure subscription.
     - **Resource group**: Enter a name for the resource group.
     - **Region**: Choose a location (e.g., Central US).
   - Click **Review + Create** and then **Create**.

2. **Create an App Service Plan**:
   - Search for **App Service Plans** in the search bar.
   - Click **+ Create**.
   - Fill in the required fields:
     - **Subscription**: Select your Azure subscription.
     - **Resource Group**: Select the resource group you just created.
     - **Name**: Enter a name for the App Service Plan.
     - **Operating System**: Select **Linux**.
     - **SKU and Size**: Choose a pricing tier (e.g., F1).
   - Click **Review + Create** and then **Create**.

3. **Create a Web App**:
   - Search for **App Services** in the search bar.
   - Click **+ Create**.
   - Fill in the required fields:
     - **Subscription**: Select your Azure subscription.
     - **Resource Group**: Select the resource group you created.
     - **Name**: Enter a unique name for the Web App.
     - **Publish**: Select **Docker Container**.
     - **Operating System**: Select **Linux**.
     - **Region**: Choose the same location as the resource group.
     - **App Service Plan**: Select the App Service Plan you created.
   - Configure the Docker container settings with your container image.
   - Click **Review + Create** and then **Create**.

### 5. Verify Resource Creation
Once the resources are created, you can verify them in the Azure Portal or by using the following Azure CLI commands:

- List resource groups:
  ```bash
  az group list -o table
  ```

- List web apps:
  ```bash
  az webapp list -o table
  ```

---

## Troubleshooting
- **Azure CLI commands not recognized**: Ensure the Azure CLI is installed and added to your system PATH.
- **Authentication issues**: Double-check your Azure account credentials.
- **Permission errors**: Confirm that your Azure account has the necessary permissions to create resources.

---

For more details, refer to the [Azure CLI documentation](https://learn.microsoft.com/en-us/cli/azure/) and the [Azure Portal documentation](https://learn.microsoft.com/en-us/azure/azure-portal/).

