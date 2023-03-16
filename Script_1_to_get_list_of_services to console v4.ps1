param(
    [switch]$Running,
    [switch]$Stopped,
    [switch]$Automatic,
    [switch]$Manual,
    [string]$OrderBy,
    [Alias('?', 'h', '/?', '/h', '--help', 'help', '-help')][switch]$HelpFunction,
    [switch]$OnlyServiceName
)

function Show-Help {
    @"
Usage: .\Get-Services.ps1 [[-Running] [-Stopped] [-Automatic] [-Manual]] [-OrderBy <ColumnName>] [-Help] [-OnlyServiceName]

-Running         : Display services with a "Running" status
-Stopped         : Display services with a "Stopped" status
-Automatic       : Display services with an "Automatic" startup type
-Manual          : Display services with a "Manual" startup type
-OrderBy         : Sort the output by the specified column name
-Help            : Show this help message
-OnlyServiceName : Display only the "Service Name" column

Examples:
.\Get-Services.ps1 -Running -Automatic
.\Get-Services.ps1 -Stopped -OrderBy "Display Name"
.\Get-Services.ps1 -Help
.\Get-Services.ps1 -OnlyServiceName
"@
}

if ($HelpFunction) {
    Show-Help
    exit
}

# Set default values if no arguments are provided
if (-not ($Running -or $Stopped -or $Automatic -or $Manual)) {
    $Running = $Stopped = $Automatic = $Manual = $true
}

$services = Get-Service | Select-Object -Property Name, DisplayName, Description, Status, StartType

# Filter services based on command line arguments
$filteredServices = $services | Where-Object {
    (($_.Status -eq 'Running') -and $Running) -or
    (($_.Status -eq 'Stopped') -and $Stopped) -or
    (($_.StartType -eq 'Automatic') -and $Automatic) -or
    (($_.StartType -eq 'Manual') -and $Manual)
}

# Sort services based on the provided OrderBy parameter
if ($OrderBy) {
    $filteredServices = $filteredServices | Sort-Object -Property $OrderBy
}

if ($OnlyServiceName) {
    $filteredServices | Select-Object -ExpandProperty Name
} else {
    $filteredServices | Format-Table -Property @{
        Name = 'Service Name'; Expression = { $_.Name }
    }, @{
        Name = 'Display Name'; Expression = { $_.DisplayName }
    }, @{
        Name = 'Description'; Expression = { $_.Description }
    }, @{
        Name = 'Status'; Expression = { $_.Status }
    }, @{
        Name = 'Startup Type'; Expression = { $_.StartType }
    } -AutoSize
}
