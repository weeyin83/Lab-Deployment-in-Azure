# Deploy the Lab

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
$HyperVHostAdminUserName = "adminuser"
$HyperVHostAdminPassword = ConvertTo-SecureString -AsPlainText -Force "demo@password123"
$vnetNeworExisting = "new"

## Create an Azure Resource Group
New-AzResourceGroup -Name $ResourceGroupName -Location $Location

## Deploy the Azure Lab using Bicep
New-AzResourceGroupDeployment -name $BicepDeploymentName -ResourceGroupName $ResourceGroupName -TemplateFile VMdeploy.bicep -HyperVHostAdminUserName $HyperVHostAdminUserName -HyperVHostAdminPassword $HyperVHostAdminPassword -vnetNeworExisting $vnetNeworExisting
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

The lab is now ready for you to use how you would like. 