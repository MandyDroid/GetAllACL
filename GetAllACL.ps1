#Set variables
$path = ""
$pathDefault = "\\some.remote.net\SHARE$\"
$depth = ""
$depthDefault = 0
$path = Read-Host "Enter the path you wish to check [default= $pathDefault]"
    If ( $path -eq "" ){ $path = $pathDefault }
$depth = Read-Host "Enter the recursive depth (default= $depthDefault)"
    If ($depth -eq "" ){ $depth = $depthDefault }
$userGroups = @()
$testGroup = @()
$group = ""
$output_path = "C:\Powershell-results\"
$filename = "GetAllACL." + (Get-Date -Format "MM-dd-yyyy_hh-mm-ss_tt") + ".log"
$date = Get-Date
$spacelist = " "

#Place Headers on out-put file
$list = "Permissions report for: $path ($depth sub-=folders deep)" | format-table | Out-File "$output_path$filename"
$datelist = "Report Run Time: $date`n`n"| format-table | Out-File -append "$output_path$filename"
$heading = " `n" | format-table | Out-File -append "$output_path$filename"

#Populate Folders Array
[Array] $folders = Get-ChildItem -path $path -force -recurse -depth $depth | Where {$_.PSIsContainer}
$heading = "---------------------- The list of sub-folders in $path`: ----------------------`n" | format-table | Out-File -append "$output_path$filename"
$heading = $folders.name | Sort-Object | Format-Table | Out-File -append "$output_path$filename"
$heading = " `n" | format-table | Out-File -append "$output_path$filename"

#Process data in array
ForEach ($folder in [Array] $folders){
    #Convert Powershell Provider Folder Path to standard folder path
    $PSPath = (Convert-Path $folder.pspath)
    $list = ("***** Path: $PSPath *****")
    $list | format-table | Out-File -append "$output_path$filename"
    Get-Acl -path $PSPath | Format-Table -property AccessToString | Out-File -append "$output_path$filename"
    $spacelist | format-table | Out-File -append "$output_path$filename"
    $testGroup += Get-Acl -Path $PSPath | Select-Object -ExpandProperty Access
    ForEach ($group in [Array] $testGroup.IdentityReference){
        If ($userGroups -contains $group.ToString().remove(0,6)){}
        Else {
            $userGroups += $group.ToString().remove(0,6)
        }
    }
} #end ForEach

$heading = "---------------------- Security Groups ----------------------" | Out-File -append "$output_path$filename"

$userGroups | Sort-Object | format-table | Out-File -append "$output_path$filename"


ForEach ($group in $userGroups){
    $list = ("----------------- Objects in OPENX\$group -----------------")
    $list | Out-File -append "$output_path$filename"
    Get-ADGroupMember $group | Select-Object name | Sort-Object name | format-table | Out-File -append "$output_path$filename"
    $list = " `n" | format-table | Out-File -append "$output_path$filename"
}


#Place Footers on out-put file
$spacelist | format-table | Out-File -append "$output_path$filename"
$end = "Report Finsih Time: $date"
$end | format-table | Out-File -append "$output_path$filename"
