function Get-Query-Network {
<#
.SYNOPSIS
Add-on for module Get-Query
Network scanner to search for users and shadow connection
Used modules:
Import-Module PoshRSJob # ping network
Import-Module ActiveDirectory # check OS and hostname
Import-Module Get-Query # check users
.DESCRIPTION
Example:
Get-Query-Network 192.168.1.0 | ft
Get-Query-Network 192.168.1.0 -Shadow # output to GridView and shadow connection to user
Get-Query-Network 192.168.1.0 -Shadow -NoConsent # shadow connection to user no consent
Get-Query-Network 192.168.1.0 -xml # output to Excel file
.LINK
https://github.com/Lifailon/Get-Query-Network
https://github.com/Lifailon/Get-Query
https://github.com/Lifailon/MTPing
https://github.com/proxb/PoshRSJob
#>
Param (
$network,
[switch]$Shadow,
[switch]$NoConsent,
[switch]$xml
)
if (!$network) {
Write-Host (Get-Help Get-Query-Network).DESCRIPTION.Text -ForegroundColor Cyan
return
}
$net = $network -replace "\.\d{1,3}$"
$1 = ($net -split "\.")[0]
foreach ($4 in 1..254) {
$ip = "$net.$4"
(Start-RSJob {(ping -n 1 -w 50 $using:ip)[2]}) | Out-Null
}
$ping = Get-RSJob | Receive-RSJob
Get-RSJob | Remove-RSJob

$on = $ping -match $1
$rep = $on -replace ".+(?<=$1)","$1"
$ipon = $rep -replace "\:.+"

$OS = Get-ADComputer -Filter {OperatingSystem -like "*Windows*"} -Properties IPv4Address,OperatingSystem
$ipwin = @()
foreach ($srv in $ipon) {
$ipwin += $OS | where IPv4Address -like $srv
}

$Collections = New-Object System.Collections.Generic.List[System.Object]
foreach ($srv in $ipwin) {
$Query = Get-Query $srv.DNSHostName
foreach ($q in $Query) {
$Collections.Add([PSCustomObject]@{
Server = $srv.DNSHostName
IP = $srv.IPv4Address
OS = $srv.OperatingSystem
User = $q.User
ID = $q.ID
Status = $q.Status
Session = $q.Session
IdleTime = $q.IdleTime
LogonTime = $q.LogonTime
})
}
}
if ((!($out)) -and (!($xml))) {
$Collections
}

if ($Shadow) {
$Count = $Collections.Count
$Connection = $Collections | Out-GridView -Title "Session count: $Count" -PassThru
$Server = $Connection.Server
$ID = $Connection.ID
if ($NoConsent) {
mstsc /v:$Server /shadow:$ID /control /noconsentprompt
}
if (!($NoConsent)) {
mstsc /v:$Server /shadow:$ID /control
}
}

if ($xml) {
$path = "$home\Desktop\$network.xlsx"
$Excel = New-Object -ComObject Excel.Application
$Excel.Visible = $false
$ExcelWorkBook = $Excel.Workbooks.Add()
$ExcelWorkSheet = $ExcelWorkBook.Worksheets.Item(1)
$ExcelWorkSheet.Name = "Get-Query-Network"
$ExcelWorkSheet.Cells.Item(1,1) = "Server"
$ExcelWorkSheet.Cells.Item(1,2) = "IP"
$ExcelWorkSheet.Cells.Item(1,3) = "OS"
$ExcelWorkSheet.Cells.Item(1,4) = "User"
$ExcelWorkSheet.Cells.Item(1,5) = "ID"
$ExcelWorkSheet.Cells.Item(1,6) = "Status"
$ExcelWorkSheet.Cells.Item(1,7) = "Session"
$ExcelWorkSheet.Cells.Item(1,8) = "IdleTime"
$ExcelWorkSheet.Cells.Item(1,9) = "LogonTime"
$ExcelWorkSheet.Rows.Item(1).Font.Bold = $true
$ExcelWorkSheet.Rows.Item(1).Font.size=14
$ExcelWorkSheet.Columns.Item(1).ColumnWidth=25
$ExcelWorkSheet.Columns.Item(2).ColumnWidth=15
$ExcelWorkSheet.Columns.Item(3).ColumnWidth=40
$ExcelWorkSheet.Columns.Item(4).ColumnWidth=15
$ExcelWorkSheet.Columns.Item(5).ColumnWidth=5
$ExcelWorkSheet.Columns.Item(6).ColumnWidth=10
$ExcelWorkSheet.Columns.Item(7).ColumnWidth=15
$ExcelWorkSheet.Columns.Item(8).ColumnWidth=15
$ExcelWorkSheet.Columns.Item(9).ColumnWidth=20
$counter = 2
foreach ($collection in $Collections) {
$ExcelWorkSheet.Columns.Item(1).Rows.Item($counter) = $collection.Server
$ExcelWorkSheet.Columns.Item(2).Rows.Item($counter) = $collection.IP
$ExcelWorkSheet.Columns.Item(3).Rows.Item($counter) = $collection.OS
$ExcelWorkSheet.Columns.Item(4).Rows.Item($counter) = $collection.User
$ExcelWorkSheet.Columns.Item(5).Rows.Item($counter) = $collection.ID
$ExcelWorkSheet.Columns.Item(6).Rows.Item($counter) = $collection.Status
$ExcelWorkSheet.Columns.Item(7).Rows.Item($counter) = $collection.Session
$ExcelWorkSheet.Columns.Item(8).Rows.Item($counter) = $collection.IdleTime
$ExcelWorkSheet.Columns.Item(9).Rows.Item($counter) = $collection.LogonTime
if ($collection.Status -eq "Active") {
$ExcelWorkSheet.Columns.Item(6).Rows.Item($counter).Font.Bold = $true
}
$counter++
}
$ExcelWorkBook.SaveAs($path)
$ExcelWorkBook.close($true)
$Excel.Quit()
}
}