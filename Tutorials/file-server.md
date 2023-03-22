# Deploy an Azure File Share with an on-prem endpoint

## Deploy the Azure lab

The first that that you need to do is deploy the Azure virtual machine (VM) that will act as your on-prem environment.  You can start the deployment via the following button: 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fweeyin83%2FLab-Deployment-in-Azure%2Fmain%2FVMdeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

_It can take 55minutes for the lab to fully deploy._

## Set up the lab

Once the Azure deployment has completed, there are a few things you need to do within the lab before you can start using it. 

* Log onto your Azure VM
* Launch Hyper-V
* Log onto AD01, the login name is **tailwindtraders\administrator** and the password is: **Password**: demo@pass123 
* Configure the IP address to a static one, the configuration should be: 
    - IP Address: 192.168.0.2
    - Subnet Mask: 255.255.255.0
    - Default Gateway: 192.168.0.1
    - Preferred DNS: 127.0.0.1
    - Alternative DNS: 8.8.8.8
* Restart the 4 other servers hosted within the Hyper-V environment _(Restarting them will force them all to pick up an IP address from the AD01 server)_


## Configure the Azure File Share

### Create a storage account

Before you can work with an Azure file share, you must create an Azure storage account.

* Head over to the Azure portal - [https://azure.portal.com](https://azure.portal.com)
* Under **Azure Services**, select **Storage Accounts**
* Select + Create to create a storage account
* Under Project details, select the Azure subscription in which to create the storage account. If you have only one subscription, it should be the default
* If you want to create a new resource group, select Create new and enter a name such as myexamplegroup
* Under Instance details, provide a name for the storage account. You might need to add a few random numbers to make it a globally unique name. A storage account name must be all lowercase and numbers, and must be between 3 and 24 characters. Make a note of your storage account name. You'll use it later
* In Region, select the region you want to create your storage account in
* In Performance, keep the default value of Standard
* In Redundancy, select Locally redundant storage (LRS)
* Select Review to review your settings. Azure will run a final validation
* When validation is complete, select Create. You should see a notification that deployment is in progress

### Create a file share

Now you have a storage account, it's time to create the file share. 

* Within the Storage account you created navigate to **Data Storage** and **File Shares** 
* Select + File Share
* Name the new file share **ttfileshare**, leave the tier set to Transaction optimized, and then select Create. You only need 5 TiB for this tutorial

### Deploy the Storage Sync Service


