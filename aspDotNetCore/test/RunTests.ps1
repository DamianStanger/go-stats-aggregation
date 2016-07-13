 Param(
    [switch] $Integration = $false,
    [switch] $Unit = $false
 )
 
 if(!$Integration -and !$Unit) {
    $Unit = $true
    $Integration = $true
}

if($unit){
    write-host
    Write-host -ForegroundColor Yellow "Starting Unit tests"
    dotnet test .\GoStatsAggregation.Tests\project.json
    
    if($LASTEXITCODE -ne 0){
       write-host
       write-host -ForegroundColor Red "Unit tests failed. Stopping here"
       exit 1
    }
 }
 if($Integration){
    write-host
    Write-host -ForegroundColor Yellow "Starting Integration tests"
    dotnet test .\GoStatsAggregation.IntegrationTests\project.json

    if($LASTEXITCODE -ne 0){
       write-host
       write-host -ForegroundColor Red "Integration tests failed. Stopping here"
       exit 1
    }
 }

 write-host
 Write-Host -ForegroundColor Green "Fin"