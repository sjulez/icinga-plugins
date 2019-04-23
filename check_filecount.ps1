# This little script checks the number of files in a folder the powershell way
# It takes the Path to the folder and threshhols as arguments
# 

param(
    [String]$path,
    [Int]$warn,
    [Int]$crit
)

$filecount = (Get-ChildItem "$path\*" | Measure-Object ).Count;

# If there is no specification, take these values as standard
if ( $warn -eq $null ) { $warn = 100 }
if ( $crit -eq $null ) { $crit = 200 }

if ( $filecount -lt $warn){
    Write-Host "OK - Filecount in " $path" is "$filecount
    Return 0
    } 
 elseif ( ($filecount -ge $warn) -and ( $filecount -lt $crit) ){
    Write-Host "WARNING - Filecount  in " $path" is "$filecount
    Return 1
    }
 elseif ( $filecount -ge $crit ){
    Write-Host "CRITICAL - Filecount  in " $path" is "$filecount
    Return 2
    }
 else {
    Write-Host "Unknown - something went wrong"
    Return 3
    }