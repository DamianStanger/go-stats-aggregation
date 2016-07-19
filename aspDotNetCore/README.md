# Build and run the project in local Kestrel server
* cd .\src\GoStatsAggregation\
* dotnet restore
* dotnet build
* dotnet run
* browse to `http://localhost:5000`

# Run the tests with dotnet
* cd .\test\GoStatsAggregation.Tests\
* dotnet restore
* dotnet test

# Run the tests with the powershell script
* cd .\test
* .\runtests.ps1