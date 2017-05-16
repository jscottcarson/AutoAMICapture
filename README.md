# Auto-AMI

This is a script run on a server that takes a daily snapshot of the and deletes any snapshots older than 3 days. The snapashot is used in the high availability failover script. This script writes the instance ID of the AMI it creates to  a file called lastami.txt. This file is used by the automated failover script to stand up a new server from the last good backup.
