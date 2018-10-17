##########################################################################################
#変数
##########################################################################################
#作業アカウントを指定
$Working_Account = "AccountName@xxxxxxxx.onmicrosoft.com"

#パスワード情報が記録されているファイルを指定
$PW_File = "PW.pass"

#前日 0:00:00を指定（監査ログはUTCで出力されるため、前々日 15:00:00としています）
$Start_Date = (Get-Date(Get-Date).AddDays(-2) -UFormat %Y/%m/%d) + ' ' + '15:00:00' 

#当日 0:00:00を指定（監査ログはUTCで出力されるため、前日 15:00:00としています）
$End_Date = (Get-Date(Get-Date).AddDays(-1) -UFormat %Y/%m/%d) + ' ' + '15:00:00'

#監査ログのファイル名に設定する日付を指定（前日日付.csvとしています）
$Todays_Date = Get-Date(Get-Date).AddDays(-1) -UFormat %Y%m%d

#ファイル名のインデックス
$FileName_Index = 1

#監査ログの保存場所を指定（スクリプトと同じフォルダとしています）
$LogDir = $PSScriptRoot

#セッションIDを指定
$SessionId = "UnifiedAuditLogSearch" + (Get-Date -UFormat %Y%m%d%H%M%S)

##########################################################################################
#Office 365にログイン
##########################################################################################
Import-Module MSOnline
$PW = Get-Content ($PSScriptRoot + '\' + $PW_File) | ConvertTo-SecureString
$O365Cred = New-Object System.Management.Automation.PSCredential $Working_Account,$PW
Connect-MsolService -Credential $O365Cred

$ExOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/"  -Credential $O365Cred -Authentication Basic -AllowRedirection
Import-PSSession $ExOSession -DisableNameChecking

##########################################################################################
#監査ログをCSVファイルに出力
##########################################################################################
#無限ループ
while($True)
{
    #前日 00:00:00　～ 当日 00:00:00の監査ログを出力
    $Log = Search-UnifiedAuditLog -ResultSize "5000" -StartDate $Start_Date -EndDate $End_Date -SessionId $SessionId -SessionCommand "ReturnLargeSet" -Formatted
    if($Log)
    {
        $Log | Export-Csv -Encoding UTF8 -NoTypeInformation -Path ($LogDir + "\" + $Todays_Date + "_" + $FileName_Index + ".csv")
        $FileName_Index++
    }
    else
    {
        break
    }
}

##########################################################################################
#セッション終了
##########################################################################################
Remove-PSSession $ExOSession

