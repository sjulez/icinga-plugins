<#
	.SYNOPSIS
		This little script checks the number of files in a folder the powershell way
		It takes the Path to the folder and threshhols as arguments

	.DESCRIPTION
		This Script here is to monitor a Windows-Location of your choice conceirning
		the amount of files that are in there.
		I developed this Script because I had to monitor several locations on different
		servers that get populated with files, that later on get processed and written
		to a database before they are deleted.

	.PARAMTER Path
		The only mandatory parameter for the script is the Location to check.
		Seems logical, doesn't it?

	.PARAMETER Warning
		Give the threshold for when the check should turn to warning state with this parameter.
		Defaults to 100 (files in Folder) if omitted.

	.PARAMETER Critical
		Give the threshold for when the check should turn to critical state with this parameter.
		Defaults to 100 (files in Folder) if omitted.
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
		[String]	$Path			,
    [Int]			$Warning	,
    [Int]			$Critical
)

# it shouldn't make a difference if the user inputs a path with or
# without a trailing backslash
if ( $Path.EndsWith('\') ) {
	$Filecount = (Get-ChildItem "$Path*" | Measure-Object ).Count;
} else {
	$Filecount = (Get-ChildItem "$Path\*" | Measure-Object ).Count;
}

# If there is no specification, take these values as standard
if ( $Warning -eq $null  -or $Warning -eq '' ) {
	$Warning = 100
}

if ( $Critical -eq $null -or $Critical -eq '' ) {
	$Critical = 200
}

if ( $Filecount -lt $Warning){
    $PluginOutput = "OK - Filecount in $Path is $($Filecount)"
    $exitcode = 0

} elseif ( ($Filecount -ge $Warning) -and ( $Filecount -lt $Critical) ) {
    $PluginOutput = "Warning - Filecount  in $Path is $($Filecount)"
    $exitcode = 1

} elseif ( $Filecount -ge $Critical ) {
    $PluginOutput = "Critical - Filecount  in $Path is $($Filecount)"
    $exitcode = 2
} else {
    $PluginOutput = "Unknown - something went wrong"
    $exitcode = 3
 }

# add performance data string to Plugin Output
# we compile a default label that is filecount_<Name of Destination Folder>
# e.g. "C:\Users\JonDoe\Downloads" defaults to "filecount_Downloads"
#
# Windows-Paths are represented with Backslash. Please, I beg you, don't use
# silly characters like whitespace in your Paths. Just don't.
$ExplodedPath = $Path.Split('\')
$LengthOfPath = $ExplodedPath.Length

# You don't have to worry whether ending your path with a backslash or not, we
# cover that here
if ( $Path.EndsWith('\') ) {
	$IndexSubtractor = 2
} else {
	$IndexSubtractor = 1
}

# If you're a madman -or have to deal with such madmen- and put whitespace in
# your folder names, we cover that edge case here and replace whitespace with
# underscore
$PerfDataLabel = "filecount_"
$PerfDataLabel += ($ExplodedPath[$($LengthOfPath-$IndexSubtractor)]).Replace(' ','_')


# Finally compile perfdata-string ans add it to the Plugin Output
$PluginOutput += "|$($PerfDataLabel)=$($Filecount);$($Warning);$($Critical)"

Write-Output $PluginOutput
exit $exitcode
