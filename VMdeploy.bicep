@minLength(1)
param HyperVHostAdminUserName string 

@minLength(1)
@secure()
param HyperVHostAdminPassword string

param location string = resourceGroup().location

@description('Specify whether to provision new vnet or deploy to existing vnet')
@allowed([
  'new'
  'existing'
])
param vnetNewOrExisting string

var OnPremVNETName = 'OnPremVNET'
var OnPremVNETPrefix = '10.0.0.0/16'
var OnPremVNETSubnet1Name = 'VMHOST'
var OnPremVNETSubnet1Prefix = '10.0.0.0/24'
var OnPremVNETBastionSubnetName = 'AzureBastionSubnet'
var OnPremVNETBastionSubnetPrefix = '10.0.1.0/24'
var HyperVHostName = 'HYPERVHOST'
var HyperVHostImagePublisher = 'MicrosoftWindowsServer'
var HyperVHostImageOffer = 'WindowsServer'
var HyperVHostWindowsOSVersion = '2022-Datacenter'
var HyperVHostVmSize = 'Standard_D8s_v3'
var HyperVHost_NSG_Name = '${HyperVHostName}-NSG'
var HyperVHostVnetID = OnPremVNET.id
var HyperVHostSubnetRef = '${HyperVHostVnetID}/subnets/${OnPremVNETSubnet1Name}'
var HyperVHostNicName = '${HyperVHostName}-NIC'
var BastionNsgName = '${BastionHostName}-NSG'
var BastionHostName = 'azmigrationlab-bastion'
var Bastion_PUBIPName = '${BastionHostName}-PIP'
var HyperVHostConfigArchiveFolder = '.'
var HyperVHostConfigArchiveFileName = 'HyperVHostConfig.zip'
var HyperVHostConfigURL = 'https://github.com/weeyin83/Lab-Deployment-in-Azure/blob/main/HyperVHostConfig.zip?raw=true'
var HyperVHostInstallHyperVScriptFolder = '.'
var HyperVHostInstallHyperVScriptFileName = 'InstallHyperV.ps1'
var HyperVHostInstallHyperVURL = 'https://raw.githubusercontent.com/weeyin83/Lab-Deployment-in-Azure/main/InstallHyperV.ps1'

resource HyperVHost_NSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: HyperVHost_NSG_Name
  location: location
  tags: {
    Purpose: 'LabDeployment'
  }
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
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource bastionNsg 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: BastionNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource OnPremVNET 'Microsoft.Network/virtualNetworks@2022-07-01' = if (vnetNewOrExisting == 'new'){
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
      {
        name: OnPremVNETBastionSubnetName
        properties: {
          addressPrefix: OnPremVNETBastionSubnetPrefix
          networkSecurityGroup: {
            id: bastionNsg.id
          }
        }
      }
    ]
  }
  dependsOn: []
}

// if vnetNewOrExisting == 'existing', reference an existing vnet and create a new subnet under it
resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = if (vnetNewOrExisting == 'existing') {
  name: OnPremVNETName
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = if (vnetNewOrExisting == 'existing') {
  parent: existingVirtualNetwork
  name: OnPremVNETBastionSubnetName
  properties: {
    addressPrefix: OnPremVNETBastionSubnetPrefix
    networkSecurityGroup: {
      id: bastionNsg.id
    }
  }
}

resource Bastion_PUBIP 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: Bastion_PUBIPName
  sku:{
    name: 'Standard'
  }
  location: location
  tags: {
    Purpose: 'LabDeployment'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: BastionHostName
    }
  }
  dependsOn: []
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: BastionHostName
  location: location
  dependsOn: [
    OnPremVNET
    existingVirtualNetwork
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subnet.id
          }
          publicIPAddress: {
            id: Bastion_PUBIP.id
          }
        }
      }
    ]
  }
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
        }
      }
    ]
    networkSecurityGroup: {
      id: HyperVHost_NSG.id
    }
  }
  dependsOn: [
    OnPremVNET
  ]
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

resource HyperVHostName_InstallHyperV 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
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

resource HyperVHostName_HyperVHostConfig 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
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

