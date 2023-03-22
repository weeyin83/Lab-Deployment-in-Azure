# Assess the lab with Azure Migrate

## Deploy the Azure lab

The first that that you need to do is deploy the Azure virtual machine (VM) that will act as your on-prem environment. 

You can click on the following button and it will take you to the Azure Portal which will walk you through the deployment of the lab via the web browser experience: 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fweeyin83%2FLab-Deployment-in-Azure%2Fmain%2FVMdeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Alternatively if you would like to deploy the lab using Azure Bicep you can clone the repo and deploy the template using the following Azure PowerShell commands: 

```powershell

## Create variables - modify these to suit your deployment needs
$ResourceGroupName = "AzureLab"
$Location = "uksouth"
$BicepDeploymentName = "AzureLabDeployment"
$DNSName = "AzureLab"

## Create an Azure Resource Group
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

## Deploy the Azure Lab using Bicep
New-AzResourceGroupDeployment -name $BicepDeploymentName -ResourceGroupName $ResourceGroupName -TemplateFile VMdeploy.bicep -hypervHostDnsName $DNSName
```

_It can take 50-70 minutes for the lab to fully deploy._

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

## Discover with Azure Migrate

We are going to deploy Azure Migrate within our lab environment to assess the servers and look start the process for a migration.  Because we can't access the hypervisor layer we are going to treat our servers as if they were physical servers and deploy Azure Migrate in that manner. 

### Build a server to install Azure Migrate on

We need to build a server that can host the Azure Migrate software within our environment.  

* Obtain an ISO for Windows Server 2016 and store it within your Azure VM
* Open **Hyper-V Manager** within your Azure VM
* From the **Action** pane, click **New**, and then click **Virtual Machine**
* From the **New Virtual Machine Wizard**, click **Next**
* You will be asked to provide some information on the server:
    * Name
    * Generation: Specify Generation 1
    * Memory: Assign at least 8GB of memory
    * Networking: Select
    * Hard Disk: Specify at least 80GB
    * Select the Windows Server 2016 ISO for the operation system
* After verifying your choices in the **Summary** page, click **Finish**

### Create an Azure Migrate project

* In the Azure portal > All services, search for Azure Migrate
* Under Services, select Azure Migrate
* In Overview, select Create project
* In Create project, select your Azure subscription and resource group. Create a resource group if you don't have one
* In Project Details, specify the project name and the geography in which you want to create the project
* Select Create
