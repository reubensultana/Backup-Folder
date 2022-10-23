# This script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Warning "You didn't run this script as an Administrator. Please close this session and start the process as an Administrator before running the script."
    return
}

# get the current folder
[string] $CurrentFolder = $(Get-Location).Path
[string] $ConfigFile = "$CurrentFolder\config.txt"
[string] $LogFolder = "$CurrentFolder\_log"
[string] $FolderName = ""

# check if config file exists
if ($false -eq (Test-Path $ConfigFile -PathType Leaf)) {
    Write-Error "The config file could not be found."
    return
}

# load folder list from config
$FolderList = Get-Content -Path $ConfigFile

# check if config file contains and details
if ($FolderList.Count -eq 0) {
    Write-Error "Config file is empty." 
    return
}

# check and create log folder
if ($false -eq (Test-Path $LogFolder -PathType Container)) {
    New-Item -Path $LogFolder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
}

# command template
[string] $CopyCommandTemplate = "robocopy ""{0}"" ""$CurrentFolder\{1}"" *.* /copyall /e /purge /w:1 /r:1 /tee /np /XO /xd '`$RECYCLE.BIN' /xf 'desktop.ini' /xf 'DockerDesktop.vhdx' /xf '*.iso' /xf '*.vhd*' /xf 'thumbs.db' /v /LOG:""$LogFolder\{2}.log"" & pause"

# spawn multiple copy processes
foreach ($Folder in $FolderList) {
    # get the name of the folder being copied
    $FolderName = $(Get-Item $Folder).Name

    ## build copy command
    [string] $CopyCommand = $CopyCommandTemplate -f $Folder,$FolderName,$FolderName

    Write-Output $CopyCommand
    Start-Process -UseNewEnvironment -FilePath "cmd.exe" -ArgumentList "/C $CopyCommand"
}
