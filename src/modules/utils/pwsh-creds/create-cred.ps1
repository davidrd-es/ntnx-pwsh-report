$userPassword = 'Patata2022!'
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
$secStringPassword | Export-Clixml -Path ".\\config\\cred.xml"