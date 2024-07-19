## Overview
`GetAzureARMLimits.ps1` is a PowerShell script designed to check and display the remaining Azure Resource Manager (ARM) API limits for a specified Azure subscription. 

Understand how Azure Resource Limits are applied: https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/request-limits-and-throttling

__The script uses 'Az' Powershell Module as previous AzureRM module is no longer compatible with Powershell 7.x and later, making the previous GetArmLimits.ps1 script incompatible.__

The script ensures that the necessary Azure PowerShell module (`Az`) is installed and prompts the user to install it if not present. It also handles authentication and context switching for Azure subscriptions.

## Improvements
- [x] Works with Azure Powershell Module 'Az' 
- [x] Supports Powershell 7.x and later
- [x] Checks Pre-requisites and prompts user to install if not present
- [x] Prompts user to select Azure Subscription

## Prerequisites
- PowerShell 5.1 or later
- Azure PowerShell Module (`Az`)

## Usage
1. Download the script
2. Execute it in PowerShell with Administrative privileges (otherwise the script will prompt for it)

Quick-start:
```powershell
# Download the script via PowerShell
$scriptUrl = "https://raw.githubusercontent.com/your-repository/GetAzureARMLimits.ps1"
$outputPath = "GetAzureARMLimits.ps1"
Invoke-WebRequest -Uri $scriptUrl -OutFile $outputPath

# Run the script
.\GetAzureARMLimits.ps1
```
## License
This project is licensed under the terms of the [LICENSE](./LICENSE) file. Please make sure to review the LICENSE file for detailed information regarding the usage and distribution of this script.



