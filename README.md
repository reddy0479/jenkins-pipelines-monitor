# Jenkins-pipelines-monitor

This script will get the master build status of the jenkins pipelines and will send the status report in a single email. This script will be helpful when ur Manager/PM wants to see the status report just once in a day of all the critical pipelines. Schedule the exucution of this script in a cron job and you will get the report daily.

In order to generate the api token in Jenkins follow the below mentioned steps

* Log in to Jenkins.
* Click you name (upper-right corner).
* Click Configure (left-side menu).
* Use "Add new Token" button to generate a new one then name it.
* You must copy the token when you generate it as you cannot view the token afterwards.
