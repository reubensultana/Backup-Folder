# get the current folder
[string] $CurrentFolder = $(Get-Location).Path
[string] $ConfigFile = "$CurrentFolder\config.txt"
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

# command template - this technique is used to include double-quotes in the command
$CopyCommandTemplate = (@"
rem robocopy "{0}" "$CurrentFolder\{1}" *.* /e /w:1 /r:1 /tee /np /XO /xd "`$RECYCLE.BIN" /xf "desktop.ini" /xf "DockerDesktop.vhdx" /xf "*.iso" /xf "*.vhd*" /xf "thumbs.db" /v /LOG:"$CurrentFolder\_log\{2}.log" & pause
"@)

# spawn multiple copy processes
foreach ($Folder in $FolderList) {
    # get the name of the folder being copied
    $FolderName = $(Get-Item $Folder).Name

    $CopyCommandTemplate.Replace("{0}", $Folder).Replace("{1}", $FolderName).Replace("{2}", $FolderName)

    ## build copy command
    [string] $CopyCommand = $CopyCommandTemplate -f $Folder,$FolderName,$FolderName
    # Write-Output $CopyCommand

    # generate the batch files to run the backups
    $CopyCommand | Out-File -FilePath ".\$FolderName.cmd" -Encoding utf8 -Force

    Start-Process -UseNewEnvironment -FilePath "cmd.exe" -ArgumentList "/C $CurrentFolder\$FolderName.cmd"
}
