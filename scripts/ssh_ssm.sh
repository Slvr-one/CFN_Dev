#!/usr/bin/env bash
set -eux

region="eu-central-1"

JenkinsPWD="/var/lib/jenkins/secrets/initialAdminPassword"
PrvKey="/home/ec2-user/.ssh/jenkins_id_rsa"
# PubKey="/home/ec2-user/.ssh/jenkins_id_rsa.pub"
PubKey="$PrvKey.pub"


sudo ssh-keygen -t rsa -f $PrvKey -q -P ""
sudo chmod 775 $PrvKey && sudo chmod 775 $PrvKey

aws ssm put-parameter --region $region --name /jenkins/initialAdminPassword \
  --value file://$JenkinsPWD --type String --overwrite

aws ssm put-parameter --region $region --name /jenkins/SSH-Git-PrivateKey \
  --value file://$PrvKey --type String --overwrite

aws ssm put-parameter --region $region --name /jenkins/SSH-Git-PublicKey \
  --value file://$PubKey --type String --overwrite

#   access the console and view the parameters
