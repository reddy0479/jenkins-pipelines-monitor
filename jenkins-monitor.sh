#!/bin/bash

#---------------------------------------------------------------------------
# Purpose:  This script will monitor the Jenkins pipelines
#---------------------------------------------------------------------------


URL="https://jenkins.com"
TOKEN=”TOKEN”
USER=”USER”

ARG_EMAIL_TO="abc@xyz.com"
ARG_EMAIL_FROM="Pipeline Report <pipeline@monitor.com>"
ARG_EMAIL_SUBJECT="Status of Pipelines"

LOG="Here is the master branch build report of some of the pipelines owned by our team as of `date +%m/%d/%Y@%T`"
LOG+="... Green-->SUCCESS, ORANGE-->UNSTABLE/ABORTED, RED-->FAILED state."

Script=$(echo -e $0 | awk -F"/" '{print $NF}')

LogFile=/usr/logs/Jenkins/${Script}.log

/syslib/rotate_logs ${LogFile}

exec 3>&1 1>>${LogFile} 2>&1


#----------------------------------------------------------------------
# Getting the CRUMB response from Jenkins 
#----------------------------------------------------------------------

CRUMB=$(curl -s -u "${USER}:${TOKEN}" ${URL}/crumbIssuer/api/xml?xpath=concat\(//crumbRequestField,%22:%22,//crumb\))

#----------------------------------------------------------------------
# Running loop to get the latest Master build status of specified repo's 
#----------------------------------------------------------------------

for i in repo1 repo2 repo3
do
   STATUS=$(curl -s -X GET -u "${USER}:${TOKEN}" --cookie "$COOKIEJAR" -H "$CRUMB" ${URL}/job/${i}/job/master/lastCompletedBuild/api/json | jq -r '.result')
   if [ ${STATUS} == "SUCCESS" ]
   then
      echo -e "$i is in Successful state"
      LOG+=$(echo -e "<h4 style='color: green;'>${i} --> <a href='${URL}/job/${i}/job/master/lastCompletedBuild/console'>Click here for logs</a> </h4>")   
   elif [ ${STATUS} == "UNSTABLE" ] || [ ${STATUS} == "ABORTED" ]
   then
      echo -e "\n$i is in UNSTABLE state"
      LOG+=$(echo -e "<h3 style='color: orange;'>${i} --> <a href='${URL}/job/${i}/job/master/lastCompletedBuild/console'>Click here for logs</a> </h3>")
   else
      echo -e "\n$i is in FAILED state"
      LOG+=$(echo -e "<h2 style='color: red;'>${i} --> <a href='${URL}/job/${i}/job/master/lastCompletedBuild/console'>Click here for logs</a> </h2>")
   fi
done

echo "$LOG"

(
  echo "To: ${ARG_EMAIL_TO}"
  echo "From: ${ARG_EMAIL_FROM}"
  echo "Subject: ${ARG_EMAIL_SUBJECT}"
  echo "Mime-Version: 1.0"
  echo "Content-Type: text/html; charset='utf-8'"
  echo
  echo $LOG
) | /usr/sbin/sendmail -t


