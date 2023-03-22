param location string = resourceGroup().location

@minLength(1)
param hypervHostDnsName string = 'hypervhostupdateme'

@minLength(1)
param HyperVHostAdminUserName string = 'rootadmin'

@secure()
@minLength(8)
param HyperVHostAdminPassword string

var OnPremVNETName = 'OnPremVNET'
var OnPremVNETPrefix = '10.0.0.0/16'
var OnPremVNETSubnet1Name = 'VMHOST'
var OnPremVNETSubnet1Prefix = '10.0.0.0/24'
var HyperVHostName = 'HYPERVHOST'
var HyperVHostImagePublisher = 'MicrosoftWindowsServer'
var HyperVHostImageOffer = 'WindowsServer'
var HyperVHostWindowsOSVersion = '2022-Datacenter'
var HyperVHostOSDiskName = '${HyperVHostName}-OSDISK'
var HyperVHostVmSize = 'Standard_D8s_v3'
var HyperVHostNSGName = '${HyperVHostName}-NSG'
var HyperVHostNicName = '${HyperVHostName}-NIC'
var HyperVHost_PUBIPName = '${HyperVHostName}-PIP'
var HyperVHostConfigArchiveFolder = '.'
var HyperVHostConfigArchiveFileName = 'HyperVHostConfig.zip'
var HyperVHostConfigURL = 'https://github.com/weeyin83/Lab-Deployment-in-Azure/blob/main/HyperVHostConfig.zip?raw=true'
var HyperVHostInstallHyperVScriptFolder = '.'
var HyperVHostInstallHyperVScriptFileName = 'InstallHyperV.ps1'
var HyperVHostInstallHyperVURL = 'https://raw.githubusercontent.com/weeyin83/Lab-Deployment-in-Azure/main/InstallHyperV.ps1'

resource HyperVHost_NSG 'Microsoft.Network/networkSecurityGroups@2015-06-15' = {
  name: HyperVHostNSGName
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

resource OnPremVNET 'Microsoft.Network/virtualNetworks@2018-12-01' = {
  name: OnPremVNETName
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
}

resource HyperVHost_PUBIP 'Microsoft.Network/publicIPAddresses@2018-12-01' = {
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

resource HyperVHostNic 'Microsoft.Network/networkInterfaces@2018-12-01' = {
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
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', OnPremVNETName, OnPremVNETSubnet1Name)
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

resource HyperVHost 'Microsoft.Compute/virtualMachines@2018-10-01' = {
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
        name: HyperVHostOSDiskName
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
