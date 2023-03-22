@minLength(1)
param hypervHostDnsName string = 'hypervhostupdateme'

@minLength(1)
param HyperVHostAdminUserName string = 'rootadmin'

@minLength(1)
@secure()
param HyperVHostAdminPassword string = 'demo@pass123'

param location string = resourceGroup().location

var OnPremVNETPrefix = '10.0.0.0/16'
var OnPremVNETSubnet1Name = 'VMHOST'
var OnPremVNETSubnet1Prefix = '10.0.0.0/24'
var HyperVHostName = 'HYPERVHOST'
var HyperVHostImagePublisher = 'MicrosoftWindowsServer'
var HyperVHostImageOffer = 'WindowsServer'
var HyperVHostWindowsOSVersion = '2022-Datacenter'
var HyperVHostVmSize = 'Standard_D8s_v3'
var HyperVHost_NSG_Name = '${HyperVHostName}-NSG'
var HyperVHostVnetID = OnPremVNET.id
var HyperVHostSubnetRef = '${HyperVHostVnetID}/subnets/${OnPremVNETSubnet1Name}'
var HyperVHostNicName = '${HyperVHostName}-NIC'
var HyperVHost_PUBIPName = '${HyperVHostName}-PIP'
var HyperVHostConfigURL = 'https://github.com/weeyin83/Lab-Deployment-in-Azure/blob/main/HyperVHostConfig.zip?raw=true'
var HyperVHostInstallHyperVScriptFolder = '.'
var HyperVHostInstallHyperVScriptFileName = 'InstallHyperV.ps1'
var HyperVHostInstallHyperVURL = 'https://raw.githubusercontent.com/weeyin83/Lab-Deployment-in-Azure/main/InstallHyperV.ps1'

resource HyperVHost_NSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: HyperVHost_NSG_Name
  location: location
  properties: {
    securityRules: [
      {
        name: 'RDP_Access'
        properties: {
          description: 'Allow RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: OnPremVNETSubnet1Prefix
          access: 'Allow'
          priority: '100'
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource OnPremVNET 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: 'OnPremVNET'
  location: location
  tags: {
    Purpose: 'LabDeployment'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        OnPremVNETPrefix
      ]
    }
    subnets: [
      {
        name: OnPremVNETSubnet1Name
        properties: {
          addressPrefix: OnPremVNETSubnet1Prefix
          networkSecurityGroup: {
            id: HyperVHost_NSG.id
          }
        }
      }
    ]
  }
  dependsOn: []
}

resource HyperVHost_PUBIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: HyperVHost_PUBIPName
  location: location
  tags: {
    Purpose: 'LabDeployment'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: hypervHostDnsName
    }
  }
  dependsOn: []
}

resource HyperVHostNic 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: HyperVHostNicName
  location: location
  tags: {
    Purpose: 'LabDeployment'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: HyperVHostSubnetRef
          }
          publicIPAddress: {
            id: HyperVHost_PUBIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: HyperVHost_NSG.id
    }
  }
}

resource HyperVHost 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: HyperVHostName
  location: location
  tags: {
    Purpose: 'LabDeployment'
  }
  properties: {
    hardwareProfile: {
      vmSize: HyperVHostVmSize
    }
    osProfile: {
      computerName: HyperVHostName
      adminUsername: HyperVHostAdminUserName
      adminPassword: HyperVHostAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: HyperVHostImagePublisher
        offer: HyperVHostImageOffer
        sku: HyperVHostWindowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: 500
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: HyperVHostNic.id
        }
      ]
    }
  }
}

resource HyperVHostName_InstallHyperV 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = {
  parent: HyperVHost
  name: 'InstallHyperV'
  location: location
  tags: {
    displayName: 'Install Hyper-V'
  }
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        HyperVHostInstallHyperVURL
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${HyperVHostInstallHyperVScriptFolder}/${HyperVHostInstallHyperVScriptFileName}'
    }
  }
}

resource HyperVHostName_HyperVHostConfig 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = {
  parent: HyperVHost
  name: 'HyperVHostConfig'
  location: location
  tags: {
    displayName: 'HyperVHostConfig'
  }
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url: concat(HyperVHostConfigURL)
        script: 'HyperVHostConfig.ps1'
        function: 'Main'
      }
      configurationArguments: {
        nodeName: HyperVHostName
      }
    }
  }
  dependsOn: [

    HyperVHostName_InstallHyperV
  ]
}
