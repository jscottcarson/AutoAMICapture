#!/bin/bash

echo  Starting AMI Capture

#To create a unique AMI name for this script
echo "customname-`date +%d%b%y`" > /tmp/aminame.txt

cat /tmp/aminame.txt

#To create AMI of defined instance
aws ec2 create-image --instance-id  --region us-west-2 --name "`cat /tmp/aminame.txt`" --description "This is for Daily auto AMI creation" --no-reboot | grep -i ami | sed -e 's/"//g' -e 's/.*://' | tr -d ' ' > /tmp/amiID.txt

#Showing the AMI name created by AWS
echo -e "AMI ID is: `cat /tmp/amiID.txt`\n"

echo -e "Looking for AMI older than 3 days:\n "

#Finding AMI older than 3 days which needed to be removed
echo "customname-`date +%d%b%y --date '3 days ago'`" > /tmp/amidel.txt

#Finding Image ID of instance which needed to be Deregistered
aws ec2 describe-images --region us-west-2 --filters "Name=name,Values=`cat /tmp/amidel.txt`" | grep -i imageid | awk '{ print  $4 }' > /tmp/imageid.txt

if [[ -s /tmp/imageid.txt ]];
then

echo -e "Following AMI is found : `cat /tmp/imageid.txt`\n"

#Find the snapshots attached to the Image need to be Deregister
aws ec2 describe-images --region us-west-2 --image-ids `cat /tmp/imageid.txt` | grep snap | awk ' { print $4 }' > /tmp/snap.txt

echo -e "Following are the snapshots associated with it : `cat /tmp/snap.txt`:\n "

echo -e "Starting the Deregister of AMI... \n"

#Deregistering the AMI
aws ec2 deregister-image --region us-west-2 --image-id `cat /tmp/imageid.txt`

echo -e "\nDeleting the associated snapshots.... \n"

#Deleting snapshots attached to AMI
for i in `cat /tmp/snap.txt`;do aws ec2 delete-snapshot --region us-west-2 --snapshot-id $i ; done

else

echo -e "\nNo AMI found older than minimum required no of days\n"
fi

cp /tmp/amiID.txt lastami.txt
cd /tmp
rm -rf imageid.txt amidel.txt amiID.txt aminame.txt snap.txt

