Param(
    [switch] $full = $false,
    [switch] $report = $false,
    [string] $user = 'goserverreadonlyuser',
    [string] $pass = 'password',
    [string] $domain = '.mydomain.com',
    [string[]] $servers = @(),
    [string] $tenant = ''
)

Set-StrictMode -Version 3

if($tenant.Length -gt 0){ $tenant = "-"+$tenant}
write-host -ForegroundColor Cyan "tenant is set to '$tenant'"

$pair = "$($user):$($pass)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{
    Authorization = $basicAuthValue
}




function GetGoServerStats([string] $goserver){
    Write-Host -ForegroundColor Cyan "processing server '$goserver' on domain '$domain'"
    
    $cctrayUrl = "https://go-$goserver$domain"+":8154/go/cctray.xml"
    Write-Host -ForegroundColor Cyan "Getting $cctrayUrl"
    $response = Invoke-WebRequest -Uri $cctrayUrl -Headers $Headers

    function GetBuildLabels([string]$regex, [string] $remove){
        [XML] $xml = $response.Content
        $builds = $xml.Projects.Project | Where-Object {$_.name -match $regex} | Select-Object name, lastbuildlabel, lastbuildtime
        foreach($build in $builds){
            $build.name = $build.name -replace $remove, ""    
        }
        return $builds
    }    

    $allBuilds = GetBuildLabels "(build|artifact)$" " :: (Build|Artifact)"
    $allDeployTest = GetBuildLabels "^Deploy-[^\-]+-Test$tenant[^:]+:: Deploy$" " :: Deploy"
    $allDeployProd = GetBuildLabels "^Deploy-[^\-]+-Prod$tenant[^:]+:: Deploy$" " :: Deploy"
    $allDeployPreprod = GetBuildLabels "^Deploy-[^\-]+-Preprod$tenant[^:]+:: Deploy$" " :: Deploy"

    $results = @()

    Class ValueStream{
        [string] $ServiceName    
        
        [int] $NumberBuild
        [int] $NumberTest
        [int] $NumberPreprod
        [int] $NumberProd
        
        [int] $SvnBuild
        [int] $SvnTest
        [int] $SvnPreprod
        [int] $SvnProd
        
        [string] $StatusBuild
        [string] $StatusTest
        [string] $StatusPreprod
        [string] $StatusProd

        [datetime] $DateBuild
        [datetime] $DateTest
        [datetime] $DatePreprod
        [datetime] $DateProd

        [string] $CommitterBuild
        [string] $CommitterTest
        [string] $CommitterPreprod
        [string] $CommitterProd
    }

    function GetJson([string] $pipelineName, [string] $pipelineNumber){
        $pipelineNumber = $pipelineNumber.Split(" ")[0]
        $valueStreamUrl = $null
        $response = $null
        $json = $null

        $valueStreamUrl = "https://go-$goserver$domain"+":8154/go/pipelines/value_stream_map/$pipelineName/$pipelineNumber.json"
        Write-Host -ForegroundColor Cyan "Getting $valueStreamUrl"
        
        $response = Invoke-WebRequest -Uri $valueStreamUrl -Headers $Headers
        $json = ConvertFrom-Json $response.Content    
        return $json
    }

    function GetStatusString($json, $name){
        $result = ""
        $currentNode = $json.levels.nodes | Where-Object {$_.id -eq $name}
        foreach($stage in $currentNode.instances.stages){
            $result += $stage.status.substring(0,1)
        }
        return $result
    }

    function ProcessEnvironmentsValueStream($valueStream, $environment, $envMonika){
        $NumberField = "Number$envMonika"
        $SvnField = "Svn$envMonika"
        $StatusField = "Status$envMonika"
        $DateField = "Date$envMonika"
        $CommitterField = "Committer$envMonika"

        $json = $null
        $buildNode = $null
        $sourceNode = $null
        $json = GetJson $environment.name $environment.lastBuildLabel        
        $currentNode = $json.levels.nodes | Where-Object {$_.id -eq $environment.name}
        $buildNode = $json.levels.nodes | Where-Object {$_.id -eq "Build-" + $valueStream.ServiceName}
        $sourceNode = $json.levels.nodes | Where-Object {$_.id -eq $buildNode.parents[0] -and $_.name -notmatch ".*Automation\.GitHubSource.*"}        
        $valueStream.$NumberField = $buildNode.instances.counter
        
        $valueStream.$StatusField = GetStatusString $json $environment.name
        $valueStream.$DateField = [DateTime]::Parse($environment.lastbuildtime)        

        if($sourceNode){
            $valueStream.$CommitterField = $sourceNode.instances.user
            $valueStream.$SvnField = $sourceNode.instances.revision   
        }
    }


    foreach($prod in $allDeployProd){
        $tmp = $null
        $valueStream = $null
        $valueStreamUrl = $null
        $response = $null
        $json = $null
        $buildNode = $null
        $sourceNode = $null
        $preprod = $null
        $test = $null
        $build = $null

        if($prod.name -match "-excludethispipeline-"){
            #Write-Host -ForegroundColor DarkYellow "skipping pipeline '-excludethispipeline-'"
            continue
        }

        #Write-Host -ForegroundColor Cyan $prod.name
        $tmp = $prod.name -match "Deploy-([^\-]+)-"    
   

        $valueStream = [ValueStream]::New()
        $valueStream.ServiceName = $matches[1]
        #Write-Host -ForegroundColor Cyan "Processing service name" $valueStream.ServiceName    
        ProcessEnvironmentsValueStream $valueStream $prod "prod"

        $preprod = $allDeployPreprod | Where-Object {$_.name -match "-" + $valueStream.ServiceName + "-"}
        ProcessEnvironmentsValueStream $valueStream $preprod "preprod"

        $test = $allDeployTest | Where-Object {$_.name -match "-" + $valueStream.ServiceName + "-"}        
        ProcessEnvironmentsValueStream $valueStream $test "test"

        $build = $allBuilds | Where-Object {$_.name -match "-" + $valueStream.ServiceName + "$" }            
        ProcessEnvironmentsValueStream $valueStream $build "build"

        $results += $valueStream
    }

    
    
    if($full){
        $results | Sort-Object ServiceName | Format-Table servicename, NumberBuild, NumberTest, NumberPreprod, NumberProd, SvnBuild, SvnTest, SvnPreprod, SvnProd, StatusBuild, StatusTest, StatusPreprod, StatusProd, DateBuild, DateTest, DatePreprod, DateProd, CommitterBuild, CommitterTest, CommitterPreprod, CommitterProd
    }
    else {
        $results | Sort-Object ServiceName | Format-Table servicename, NumberBuild, NumberTest, NumberPreprod, NumberProd, SvnBuild, SvnTest, SvnPreprod, SvnProd, StatusBuild, StatusTest, StatusPreprod, StatusProd    
    }
    if($report){
        $date = Get-Date -Format s
        $date = $date -replace "-|:", ""
        $filename = Get-Location
        $filename = $filename.Path + "\GoReports\$date-$goserver.txt"
        #Write-Host $filename
        New-Item -ItemType Directory GoReports -ErrorAction SilentlyContinue
        "Report for $goserver at $date" >> $filename
        
        foreach($service in $results){
            ""  >> $filename
            ""  >> $filename
            $service.ServiceName + " - Latest build #" + $service.NumberBuild + " with SVN #" + $service.SvnBuild + " checked in by:" + $service.CommitterBuild  >> $filename
            "-----------------------------------------------------------------------------------------------------------------------------"  >> $filename            
            "value stream:    Build #" + $service.NumberBuild + "-svn" + $service.SvnBuild + " " + $service.StatusBuild + "  >>>  Test #" + $service.NumberTest + "-svn" + $service.SvnTest + " " + $service.StatusTest + "  >>>  Preprod #" + $service.NumberPreprod + "-svn" + $service.SvnPreprod + " " + $service.StatusPreprod + "  >>>  Prod #" + $service.NumberProd + "-svn" + $service.SvnProd + " " + $service.StatusProd   >> $filename
            $diffstring = "                       " + (("#"+$Service.NumberBuild) -replace ".", " ") + ((" svn"+$Service.SvnBuild) -replace "\w", " ") + ((" "+$Service.StatusBuild) -replace ".", " ") + "            "
            if($service.NumberBuild -ne $Service.NumberTest) {$diffstring += ("#"+$Service.NumberTest) -replace ".", "x"} else { $diffstring += ("#"+$Service.NumberTest) -replace ".", " "}
            if($service.SvnBuild -ne $Service.SvnTest) {$diffstring += (" svn"+$Service.SvnTest) -replace "\w", "x"} else { $diffstring += (" svn"+$Service.SvnTest) -replace "\w", " "}
            $diffstring += (" "+$Service.StatusTest) -replace ".", " "
            $diffstring += "               "
            if($service.NumberTest -ne $Service.NumberPreprod) {$diffstring += ("#"+$Service.NumberPreprod) -replace ".", "x"} else { $diffstring += ("#"+$Service.NumberPreprod) -replace ".", " "}
            if($service.SvnTest -ne $Service.SvnPreprod) {$diffstring += (" svn"+$Service.SvnPreprod) -replace "\w", "x"} else { $diffstring += (" svn"+$Service.SvnPreprod) -replace "\w", " "}
            $diffstring += (" "+$Service.StatusPreprod) -replace ".", " "
            $diffstring += "            "
            if($service.NumberPreprod -ne $Service.NumberProd) {$diffstring += ("#"+$Service.NumberProd) -replace ".", "x"} else { $diffstring += ("#"+$Service.NumberProd) -replace ".", " "}
            if($service.SvnPreprod -ne $Service.SvnProd) {$diffstring += (" svn"+$Service.SvnProd) -replace "\w", "x"} else { $diffstring += (" svn"+$Service.SvnProd) -replace "\w", " "}
            $diffstring += (" "+$Service.StatusProd) -replace ".", " "
            $diffstring >> $filename

        }
    }    
    
}

foreach($s in $servers){
    GetGoServerStats $s
}




Write-Host -ForegroundColor Cyan "Fin !!"