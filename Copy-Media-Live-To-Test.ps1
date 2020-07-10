$srcResGroupName = "johnblair"
$srcWebAppName = "johnblair"
$srcDirectory = "/site/wwwroot/media/"

$dstResGroupName = "johnblairtest"
$dstWebAppName = "johnblairtest"
$dstDirectory = "/site/wwwroot/media/"

Set-PSDebug -Trace 2

# Get publishing profile for SOURCE application

$srcWebApp = Get-AzWebApp -Name $srcWebAppName -ResourceGroupName $srcResGroupName
[xml]$publishingProfile = Get-AzWebAppPublishingProfile -WebApp $srcWebApp

# Create Base64 authorization header

$username = $publishingProfile.publishData.publishProfile[0].userName
$password = $publishingProfile.publishData.publishProfile[0].userPWD
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$apiBaseUrl = "https://$($srcWebApp.Name).scm.azurewebsites.net/api"

# Download the ZIP file to ./tmp.zip

Invoke-RestMethod -Uri "$apiBaseUrl/zip$($srcDirectory)" `
                    -Headers @{UserAgent="powershell/1.0"; `
                     Authorization=("Basic {0}" -f $base64AuthInfo)} `
                    -Method GET `
                    -OutFile ./tmp.zip

# Get publishing profile for DESTINATION application

$dstWebApp = Get-AzWebApp -Name $dstWebAppName -ResourceGroupName $dstResGroupName
[xml]$publishingProfile = Get-AzWebAppPublishingProfile -WebApp $dstWebApp

# Create Base64 authorization header

$username = $publishingProfile.publishData.publishProfile[0].userName
$password = $publishingProfile.publishData.publishProfile[0].userPWD
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$apiBaseUrl = "https://$($dstWebApp.Name).scm.azurewebsites.net/api"

# Upload and extract the ZIP file

Invoke-RestMethod -Uri "$apiBaseUrl/zip$($dstDirectory)" `
                    -Headers @{UserAgent="powershell/1.0"; `
                     Authorization=("Basic {0}" -f $base64AuthInfo)} `
                    -Method PUT `
                    -InFile ./tmp.zip `
                    -ContentType "multipart/form-data"