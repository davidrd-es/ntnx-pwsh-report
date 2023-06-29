Install-Module PSWriteHTML -AllowClobber -Force -Scope CurrentUser
Install-Module Dashimo -AllowClobber -Force -Scope CurrentUser 
Install-Module Statusimo -AllowClobber -Force -Scope CurrentUser
Install-Module Emailimo -AllowClobber -Force -Scope CurrentUser

$userPassword = 'Patata2022!'
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
$secStringPassword | Export-Clixml -Path '.\config\cred.xml'

