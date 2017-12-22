# Define the nodes to configure
$nodes = ("node1","node2","node3","node4","node5")
#####################################################################################################################################

# Install Windows Roles and Features
Invoke-Command $nodes { Install-WindowsFeature Data-Center-Bridging }
Invoke-Command $nodes { Install-WindowsFeature Multipath-IO }
Invoke-Command $nodes { Install-WindowsFeature Failover-Clustering -IncludeAllSubFeature -IncludeManagementTools }
Invoke-Command $nodes { Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart }
#####################################################################################################################################

# Configure QoS and Jumbo Packets
Invoke-Command $nodes { Get-NetAdapter | ? InterfaceDescription -Match "Mellanox*" | Sort number | % {$_ | Set-NetAdapterAdvancedProperty -RegistryKeyword "*JumboPacket" -RegistryValue 9000 } }
Invoke-Command $nodes { New-NetQosPolicy "SMB" -NetDirectPortMatchCondition 445 -PriorityValue8021Action 3 }
Invoke-Command $nodes { Enable-NetQosFlowControl -Priority 3 }
Invoke-Command $nodes { Disable-NetQosFlowControl -Priority 0,1,2,4,5,6,7 }
Invoke-Command $nodes { Get-NetAdapter | ? InterfaceDescription -Match "Mellanox*" | Enable-NetAdapterQos }
Invoke-Command $nodes { New-NetQosTrafficClass "SMB" -Priority 3 -BandwidthPercentage 50 -Algorithm ETS }
#####################################################################################################################################

# Disable Priority Flow Control
Invoke-Command $nodes { Set-NetAdapterAdvancedProperty -InterfaceDescription "*Mellanox*" -RegistryKeyword "*FlowControl" -RegistryValue 0 }
#####################################################################################################################################

# Map physcial network adapters to virtual net adapters
Invoke-Command $nodes { (Get-NetAdapter | ? { $_.Name -like "Slot 4*" -and $_.Status -eq "Up" }).Name | ?{ Set-VMNetworkAdapterTeamMapping -VMNetworkAdapterName "Storage1" -ManagementOS -PhysicalNetAdapterName $_ } }
Invoke-Command $nodes { (Get-NetAdapter | ? { $_.Name -like "Slot 6*" -and $_.Status -eq "Up" }).Name | ?{ Set-VMNetworkAdapterTeamMapping -VMNetworkAdapterName "Storage2" -ManagementOS -PhysicalNetAdapterName $_ } }
#####################################################################################################################################

# Run cluster validation
Test-Cluster -Node $nodes -Include "Storage Spaces Direct","Inventory","Network","System Configuration"
#####################################################################################################################################

# Create the S2D Cluster
New-Cluster -Name "S2D-Cluster" -Node $nodes -StaticAddress 192.168.0.30 -NoStorage -Verbose
#####################################################################################################################################

# Run the following command locally, NOT REMOTELY!, on one of the s2d cluster nodes
Enable-ClusterS2D -Verbose
#####################################################################################################################################

# Enable RDMA on the Storage vNICs, Configure LiveMigration performance to SMB, Verify RDMA Configuration (if it shows rdma capable false, make sure to install mellanox drivers from
# dells website)
Invoke-Command $nodes { Enable-NetAdapterRdma -Name "vEthernet (Storage1)", "vEthernet (Storage2)" }
Invoke-Command $nodes { Set-VMHost -VirtualMachineMigrationPerformanceOption SMB }
Invoke-Command $nodes { Get-SmbClientNetworkInterface | Where-Object { $_.FriendlyName -like "*Storage*" } | Format-Table }
#####################################################################################################################################

# Remove host mgmt network from available live migration network
$ClusterResourceType = Get-ClusterResourceType -Name "Virtual Machine"
$HostNetworkID = Get-ClusterNetwork | Where-Object { $_.Address -eq "192.168.0.0" } | Select -ExpandProperty ID
set-ClusterParameter -InputObject $ClusterResourceType -Name MigrationExcludeNetworks -Value $HostNetworkID
#####################################################################################################################################

# Configure hardware timeout for the spaces port, restart each node 1 at a time after this is ran
Invoke-Command $nodes { Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\spaceport\Parameters -Name HwTimeout -Value 0x00002710 -Verbose }
#####################################################################################################################################

# Create the CSV for VMFleet (run this on one of the nodes)
Get-ClusterNode | % { New-Volume -StoragePoolFriendlyName S2D* -FriendlyName $_ -FileSystem CSVFS_ReFS -Size 1TB }
New-Volume -StoragePoolFriendlyName S2D* -FriendlyName collect -FileSystem CSVFS_ReFS -Size 1TB
#####################################################################################################################################