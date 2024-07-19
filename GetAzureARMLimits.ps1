<#
.SYNOPSIS
    GetAzureARMLimits.ps1 - A script to check and display the remaining Azure Resource Manager (ARM) API limits for a specified Azure subscription.

.DESCRIPTION
    This script ensures that the necessary Azure PowerShell module (`Az`) is installed and prompts the user to install it if not present. It handles authentication and context switching for Azure subscriptions, and retrieves the remaining ARM API limits.

.PARAMETER None
    This script does not take any parameters.

.EXAMPLE
    .\GetAzureARMLimits.ps1
    This command runs the script and displays the remaining ARM API limits for the authenticated Azure subscription.

.NOTES
    Author: Samuel Matildes
    Date: 2024-07-19
    Version: 0.0.1

.LINK
    https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/request-limits-and-throttling
    https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-12.1.0&tabs=windowspowershell&pivots=windows-psgallery
#>

# Check if Az module is installed
if (-not(Get-Module -ListAvailable -Name Az)) {
    Write-Host "Notice: Azure PowerShell Module (Az) is required to be installed and loaded." -ForegroundColor Yellow
    Write-Host "Instructions can be found at: https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-12.1.0&tabs=windowspowershell&pivots=windows-psgallery" -ForegroundColor Yellow
    Write-Host "Do you want to install the Az module now? (y/n)" -ForegroundColor Yellow
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script needs to be run as an administrator. Do you want to restart it with elevated privileges? (y/n)" -ForegroundColor Yellow
        $elevate = Read-Host
        if ($elevate -eq "y") {
            Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
            exit
        } else {
            Write-Host "Administrator rights are required to proceed. Exiting script." -ForegroundColor Red
            exit
        }
    }

    $install = Read-Host
    if ($install -eq "y") {
        Install-Module -Name Az -Repository PSGallery -Force
    }
    return
}

# Function to get the Azure access token
function Get-AzCachedAccessToken() {
    $ErrorActionPreference = 'Stop'

    if (-not (Get-Module Az.Accounts)) {
        Import-Module Az.Accounts
    }

    $azContext = Get-AzContext

    if (-not $azContext) {
        Write-Error "Ensure you have logged in before calling this function."
    }

    $token = (Get-AzAccessToken).Token
    return $token
}

Write-Host "Log in to your Azure subscription..." -ForegroundColor Green

# Authenticate to Azure
Connect-AzAccount

# Get the access token
$token = Get-AzCachedAccessToken

# Get the list of available subscriptions
$subscriptions = Get-AzSubscription

# Display the available subscriptions to the user
Write-Host "Available Subscriptions:" -ForegroundColor Cyan
$subscriptions | ForEach-Object { Write-Host "$($_.Name) - " -NoNewline; Write-Host "$($_.Id)" -ForegroundColor Green }

# Ask the user to input the subscription ID they wish to use
$selectedSubscriptionId = Read-Host "Please enter the Subscription ID you wish to get the limits for"

# Set the selected subscription context
Set-AzContext -SubscriptionId $selectedSubscriptionId

# Update the token with the new context
$token = Get-AzCachedAccessToken

$currentAzContext = Get-AzContext

$requestHeader = @{
    "Authorization" = "Bearer " + $token
    "Content-Type" = "application/json"
}

$Uri = "https://management.azure.com/subscriptions/" + $currentAzContext.Subscription.Id + "/resourcegroups?api-version=2016-09-01"
$r = Invoke-WebRequest -Uri $Uri -Method GET -Headers $requestHeader
Write-Host ("Remaining Global Read Operations: " + $r.Headers["x-ms-ratelimit-remaining-subscription-global-reads"])
Write-Host ("Remaining Read Operations: " + $r.Headers["x-ms-ratelimit-remaining-subscription-reads"])
