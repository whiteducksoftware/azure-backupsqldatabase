# Backup Azure SQL database

The current Automated Export for SQL database will **discontinue on March 1, 2017**. If you need to export your data you either have to setup a *Long-term retention backup* or use *Azure Automation*. This article provides a script and description for the latest.

The following script will export an Azure SQL database to a [BACPAC](https://msdn.microsoft.com/library/ee210546.aspx#Anchor_4) file stored in an Azure Blob storage.

## Prerequisites
+ Azure Automation account
+ *AzureRunAsConnection* connection asset ([Create a new Automation Account from the Azure Portal](https://docs.microsoft.com/en-us/azure/automation/automation-sec-configure-azure-runas-account))
+ [Updated Azure modules in Automation](http://dinventive.com/blog/2016/10/13/5-simple-steps-how-to-update-the-default-global-modules-to-latest-version-under-assets-in-microsoft-azure-automation-account/) (for the ```New-AzureRmSqlDatabaseExport``` cmdlet).

## Instructions
### Add the Runbook
Download the above [**Backup-SqlDatabase.ps1**](https://github.com/whiteducksoftware/azure-backupsqldatabase/blob/master/Backup-SqlDatabase.ps1) and import it by going to your Azure Automation Account -> Runbooks -> Add a Runbook -> Import an existing runnbok:

![Import Runbook](https://github.com/whiteducksoftware/azure-backupsqldatabase/blob/master/resources/importrunbook.png)

### Publish the Runbook
Select the previously created **Backup-SQLDatabase** runbook and click on *Edit* and then *Publish*:

![Publish Runbook](https://github.com/whiteducksoftware/azure-backupsqldatabase/blob/master/resources/publishrunbook.png)

### Start the Runbook
After you have published the runbook you can start using *Start* button:

![Start Runbook](https://github.com/whiteducksoftware/azure-backupsqldatabase/blob/master/resources/startrunbook.PNG)
