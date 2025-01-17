## Azure CLI - Script File

### 1. Open Azure CLI Cloud Shell in the Azure Portal
1. Log in to [Azure Portal](https://portal.azure.com/).
2. In the top-right corner of the portal, click on the **Cloud Shell** icon [`>`_].
3. Choose **Bash** as your shell environment if prompted.
4. The Cloud Shell will open at the bottom of your browser.

### 2. Clone Code Repository
1. Run clone command and change working directory

    ```bash
    git clone https://github.com/stockerts/az_webapp_containerhost.git
    cd az_webapp_containerhost
    ```
### 3. Run Web App Creation Script File
1. Update file permissions

    ```bash
    chmod +x Az-WebApp-ContainerHost-Prompt.sh
    ```
2. Run script file

    ```bash
    ./Az-WebApp-ContainerHost-Prompt.sh
    ```
### 3. Verify Web App Creation

1. In the Azure Portal, navigate to **Resource Groups**, select your **Resource Group**.
2. Select your **App Service**.
3. Within **Overview** click on the listed **Default domain** on the right side of the page to browse to the site.

**_NOTE:_** This might take up to 5 mins, while the service becomes available for the first time.

### 4. Run Web App Resitriction Script File (Optional)
Add IP ranges assosiated with F5 Distributed Cloud Regional Edges
1. Update file permissions

    ```bash
    chmod +x Az-WebApp-Restriction-Prompt.sh
    ```
2. Run script file

    ```bash
    ./Az-WebApp-Restriction-Prompt.sh
    ```
**_NOTE:_** You will receive "Failed to remove..." if no rule is present. Similar, you may receive "Failed to add..." if the App Service isn't ready.

### 2. Verify Restriction Creation
1. In the Azure Portal, navigate to **Resource Groups**, select your **Resource Group**.
2. Select your **App Service**.
3. Click on **Networking** on the left hand side, under **Settings**.
4. Click on **Enabled with access restrictions** next to **Public network access**.
5. Verify groups have been added with the name **ipXC**.