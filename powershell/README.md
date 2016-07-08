#Usage
`.\Get-GoServerStats.ps1 -user goaccount -pass Password -domain .domain.com -servers @('service1','service2')`

#switches 
* -full "prints out a large table with more info in it"
* -report "saves a report to disk"
* -user "the go user to run http requests as"
* -pass "the password for the above user"
* -domain "the domain that the go servers are found on"
* -servers "the list of go servers to run the code against"

#results
```
ServiceName    NumberBuild NumberTest NumberPreprod NumberProd SvnBuild SvnTest SvnPreprod SvnProd StatusBuild StatusTest StatusPreprod StatusProd
-----------    ----------- ---------- ------------- ---------- -------- ------- ---------- ------- ----------- ---------- ------------- ---------- 
FooApi                  26         26            19         19    16070   16070      15590   15590 PP          PP         PPP           PPU
FooProcessor            27         26            20         20    16078   16075      15602   15602 PF          P          PP            PP
BarApi                  55         55            55         49    16083   16083      15583   15599 PP          PP         PPP           PPP
FooBarService           48         48            48         48    16038   16038      16038   16038 PP          P          PP            PP
FoobarEventsApi         18         18            12         12    16061   16061      15725   15725 PP          PP         PPP           PPP
```

* The Numbers reported are the pipeline numbers
* The Svn numbers are the revision of SVN as deployed in that environment
* The status is Passed, Failed, Unknown

In the example above you can see FooBarService has the latest version fully deployed to prod, and FooProcessor has failed the test stage of the build.