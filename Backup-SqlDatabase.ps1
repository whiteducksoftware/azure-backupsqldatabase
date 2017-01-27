
Param
(
    [Parameter(Mandatory=$true)]
    [string]$ServerName,

    [Parameter(Mandatory=$true)]
    [string]$ServerAdmin,

    [Parameter(Mandatory=$true)]
    [string]$ServerPassword,

    [Parameter(Mandatory=$true)]
    [string]$DatabaseName,

    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory=$true)]
    [string]$StorageAccountKey,

    [Parameter(Mandatory=$true)]
    [string]$StorageContainer
)

function New-AzureStorageContainerIfNotExists
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,

        [Parameter(Mandatory=$true)]
        [string]$StorageAccountKey,

        [Parameter(Mandatory=$true)]
        [string]$StorageContainer
    )
    $azureStorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey 

    # try to get a container reference
    $destinationContainer = Get-AzureStorageContainer -Context $azureStorageContext | 
            Where-Object { $_.Name -like $StorageContainer }
    
    # create the container if not exists
    if (-not $destinationContainer)
    {
        New-AzureStorageContainer -Name $StorageContainer -Context $azureStorageContext
    }
}

# main

# Get the connection "AzureRunAsConnection "
$servicePrincipalConnection = Get-AutomationConnection -Name 'AzureRunAsConnection'         

"Logging in to Azure"
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId `
    -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
     
"Setting context to a specific subscription"     
Set-AzureRmContext -SubscriptionId $servicePrincipalConnection.SubscriptionId 

# Create secure password
$securePassword = ConvertTo-SecureString -String $serverPassword -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $serverAdmin, $securePassword

# Generate a unique filename for the BACPAC
$bacpacFilename = $DatabaseName + (Get-Date).ToString("yyyyMMddHHmm") + ".bacpac"

# Create the storage container if it's not exists
New-AzureStorageContainerIfNotExists -StorageAccountName $StorageAccountName `
        -StorageAccountKey $StorageAccountKey -StorageContainer $StorageContainer

# Storage account info for the BACPAC
$BaseStorageUri = "https://{0}.blob.core.windows.net/{1}/" -f $StorageAccountName, $StorageContainer
$BacpacUri = $BaseStorageUri + $bacpacFilename
$StorageKey = $StorageAccountKey      

"Starting SQL Database export request"   
$exportRequest = New-AzureRmSqlDatabaseExport -ResourceGroupName $ResourceGroupName -ServerName $ServerName `
    -DatabaseName $DatabaseName -StorageKeytype "StorageAccessKey" -StorageKey $StorageKey -StorageUri $BacpacUri `
    -AdministratorLogin $creds.UserName -AdministratorLoginPassword $creds.Password

$exportRequest

# Check status of the export
Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink        
