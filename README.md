# go-stats-aggregation
Code that can be used to visualise the status of your go pipelines 

##Conventions
The go servers and pipelines need to conform to certain naming standards for these scripts to work.

###Go servers
The servers need to have urls like the following `https:\\go-server1.domain.com:8154` where server1 is the instance of the server.
for example my servers are accessed on
* https:\\go-product.foobar.com:8154
* https:\\go-platform.foobar.com:8154
* https:\\go-journey.foobar.com:8154

Loosely named after the bounded context of the services built on that particular server

###Pipelines
All the pipelines also follow a very specific convention, the deployment pipelines must have the same name as the build pipeline with the environment following it, example:
* Build-FooApi, Deploy-FooApi-Test-Uk, Deploy-FooApi-Preprod-Uk, Deploy-FooApi-Prod-Uk
* Build-FooProcessor, Depoly-FooProcessor-Test-Uk, Depoly-FooProcessor-Preprod-Uk, Depoly-FooProcessor-Prod-Uk

We have ~500 pipelines which makes it really important to have a naming standard and to follow it.
