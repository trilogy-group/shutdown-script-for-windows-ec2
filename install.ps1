param (
    [string]$Username
)

if (-not $Username) {
    Write-Error "Username parameter is required. Please provide a valid username."
    exit 1
}

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$taskName = "shutdownserviceui"
$filePath = "$scriptDirectory\shutdown-ui.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserId $Username -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable


$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File $filePath"
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask -TaskName $taskName -InputObject $task -Force

$serviceName = "ShutdownService"
$batchFilePath = "$scriptDirectory\shutdown.bat"
Start-Process "sc.exe" -ArgumentList "create", $serviceName, "binPath=", "`"$batchFilePath`"", "start=", "auto" -NoNewWindow -Wait