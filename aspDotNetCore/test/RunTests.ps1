 write-host
 Write-host -ForegroundColor Yellow "Starting Unit tests"
 dotnet test .\GoStatsAggregation.Tests\project.json
 
 if($LASTEXITCODE -ne 0){
    write-host
    write-host -ForegroundColor Red "Unit tests failed. Stopping here"
    exit 1
 }

 write-host
 Write-host -ForegroundColor Yellow "Starting Integration tests"
 dotnet test .\GoStatsAggregation.IntegrationTests\project.json

 if($LASTEXITCODE -ne 0){
    write-host
    write-host -ForegroundColor Red "Integration tests failed. Stopping here"
    exit 1
 }

 write-host
 Write-Host -ForegroundColor Green "Fin"