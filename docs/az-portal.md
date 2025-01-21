## Azure Portal - Click-Ops

### 1. Azure Portal
1. Log in to [Azure Portal](https://portal.azure.com/).

### 2. Azure Marketplace

1. **Create a Resource**  
   - Navigate to the **Azure services** bar and click **Create a resource**.

2. **Search for Web App**  
   - In the search bar, type **Web App**.  
   - *(Recommended)* Check **Azure services only** to narrow down the options.

3. **Create Web App**  
   - On the Web App Marketplace page, click **Create**.

### 3. Create a Web App

1. **Basics**

    **Select Subscription**  
    Choose the desired **Subscription** if you have more than one.

    **Set Resource Group**  
    Select an existing **Resource Group** or create a new one.  
    *(Example)*: `yourname-appname-rsg`

    **Update App Name**  
    Set the **Name** field, ensuring it’s unique across all Azure subscriptions.  
    *(Example)*: `yourname-appname-app`

    **Select Publish Method**  
    Choose **Container** as the Publish method.

    **Choose Operating System**  
    *(Recommended)* Select **Linux**.

    **Select Region**  
    Choose a **Region** to deploy Azure resources. *(Note: Not all regions support all SKUs.)*

    **Create App Service Plan**  
    Select **Create New** and name it appropriately.  
    *(Example)*: `yourname-appname-asp`

    **Choose Pricing Plan**  
    Select a Pricing Plan from the dropdown.  
    *(Recommended)*:  
    - **F1** - Free (60 mins/day)  
    - **B1** - ~$11/month  
    - **B2** - ~$22/month  
    To explore more options, click **Explore pricing plans**.
    
    **Navigate to Container Options**  
    Click **Next: Container >** at the bottom of the page.

2. **Deployment**  

    **Configure Image Source**  
    Select **Other container registries** as the **Image Source**.

    **Set Docker Hub Options**  
    Configure the following settings under Docker Hub:  
    - **Access Type**: Public  
    - **Registry Server URL**: `https://index.docker.io` (default)  
    - **Image and Tag**: Specify the desired container image.  
    *(Examples)*:  
        - `stockdemo/demoapp:latest`  
        - `bkimminich/juice-shop:latest`
        - `stockdemo/demobankapi:latest`

    **Navigate to Network Options**  
    Click **Next: Networking >** at the bottom of the page.

3. **Networking**

    **Choose an Access Type**
    Check **On** for Enabled public access

    **Navigate to Monitoring Options**  
    Click **Next: Monitor & Secure >** at the bottom of the page.

4. **Monitor + Secure**

    **Monitoring Selection**
    Keep default selection, Enable Application Insight **No**.

    **Navigate to Tags Options**  
    Click **Next: Tags >** at the bottom of the page.

5. **Tags**

    **Add a tag**
    Update the following fields
        - **Name**: owner
        - **Value**: youremail

    **Navigate to Review & Create**  
    Click **Next: Review + create >** at the bottom of the page.

22. **Review + create**

    **Create the Web App**  
    Click **Create** at the bottom of the page.

### 4. Verify Web App Creation

1. In the Azure Portal, navigate to **Resource Groups**, select your **Resource Group**.

2. Select your **App Service**.

3. Within **Overview** click on the listed **Default domain** on the right side of the page to browse to the site.

### 5. Create Web App Restriction Rules (Optional)

1. In the Azure Portal, navigate to **Resource Groups**, select your **Resource Group**.

2. Select your **App Service**.

3. Click on **Networking** on the left hand side, under **Settings**.

4. Click on **Enabled with access restrictions** next to **Public network access**.

5. Click the **+ Add** to open Add Rule slider, update the following then click **Add rule**.

    - **Name**: YourRuleName

    - **Action**: Allow

    - **Priority**: 100

    - **Type**: IPv4

    - **IP Address Block**: IPv4 CIDR
    
    **_Note_**: Multi IPs can be added seperated by a comma up to 7 per rule. Distributed Cloud IP list can be found at [xc ips-domain](
    https://docs.cloud.f5.com/docs-v2/downloads/platform/reference/network-cloud-ref/ips-domains.txt)

6. Continue to add rules as needed, then check the following are checked

    - **Pubic network access**: Enabled from select virutal networks and IP address

    - **Unmatched rule action**: Deny

7. Click **Save** near the top left of the page.

### 6. Verify Restriction Creation

1. In the Azure Portal, navigate to **Resource Groups**, select your **Resource Group**.

2. Select your **App Service**.

3. Click on **Networking** on the left hand side, under **Settings**.

4. Click on **Enabled with access restrictions** next to **Public network access**.

5. Verify rules have been added.