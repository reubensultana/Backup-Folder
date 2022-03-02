# Backup-Folder

A simple backup solution to copy contents of multiple folders to an external drive.

Just copy the `Backup-Folder.ps1` and `config.txt` files to the target drive, Fill the `config.txt` file with the list of folders you want backed up (full folder path), and of course make sure that the target has sufficient free space for the files being backed up.

Then just run the `.\Backup-Folder.ps1` script. It is recommended that the PS1 script is run using Administrator privileges.

The script will generate a CMD file for each folder, with each CMD file containing a `robocopy` command, based on the template in the PS1 file. Feel free to adapt according to your needs.
