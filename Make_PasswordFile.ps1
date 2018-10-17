$O365Cred = Get-Credential
$O365Cred.Password | ConvertFrom-SecureString | Set-Content ($PSScriptRoot + "\PW.pass")