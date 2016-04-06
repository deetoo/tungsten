#!/bin/bash

VER="0.04"

# uncomment next line for DEBUG info.
# DEBUG="1"

function Preamble {
clear
echo "Tungsten MySQL Replicator Installation  v$VER"
echo ""
echo "This script assumes the following items are already in place:"
echo "----------"
echo "1) You have a DB user, with password already provisioned on each DB within replication environment."
echo "2) You have have firewall rules in place to allow port 22, 2112 and 10000 communication between all servers replicating."
echo "3) You have a Trusted SSH Key relationship between this server and all remaining servers in this replication environment."
echo "4) Each DB will need the following items added to it's my.cnf filei within the [mysqld] section:"
echo "  a) max_allowed_packet=52m"
echo "  b) log-bin=mysql-bin"
echo "  c) server-id=<unique int value>"
echo "5) JDK 1.7 is installed and  JAVA_HOME is set correctly."
echo "----------"
printf  "If these requirments have been met, press [ENTER] to continue, otherwise press [CTRL-C] "
read -r PAUSE
}

function GetTopology {
echo ""
echo "Choose Topology:"
echo "1) Master->Slave"
echo "2) Master<>Master"
printf  "Enter Choice [1-2]: "
read -r TOPOLOGY
case $TOPOLOGY in
        1)
                echo "You have selected Master->Slave.."
                MyTopology="master-slave";
                ;;
        2)
                echo "You have selected Master<>Master.."
                MyTopology="master-master"
                ;;
        *)
                echo "Invalid choice!"
                clear
                GetTopology
                ;;
esac

}



# --------
# start running stuff..
# show requirements

Preamble
echo ""
echo ""
echo "-- A 'Service Name' is a label given to this replication environment."
echo "-- You can use any service name, an example might be 'standard'"
echo "--"
printf "--- Enter Service Name: "
read -r MyServiceName

GetTopology

# Get the Masters hostname:
printf '--- Enter the FQDN of the Master Server: '
read -r MyMasterHost

# Get the Replication username, typically 'tungsten'
printf '*NOTE* This user must already exist in MySQL.'
printf '--- Enter the replication username (ex: tungsten): '
read -r MyRepUser

# Get the RepUser password
printf '--- Enter the password for %s: ' "$MyRepUser"
read -r MyRepUserPassword


# test MySQL connections
CMD=`mysql -u $MyRepUser --password=$MyRepUserPassword -e status |head -2 |tail -1 |awk '{print $1}'`
if [[ $CMD  = "mysql" ]]
        then
                echo "-- MySQL connection [SUCESSFUL]"
        else
                echo "-- MySQL connection [FAILED]"
                exit 127
        fi

# Get the  installation directory
printf '--- Enter the directory to install Tungsten to (ex: /opt/continuent): '
read -r MyInstallDir

printf  '--- Enter a comma delimited list of all servers in this replication environment (ex: vmd01,vmd02): '
read -r  MyRepMembers

if [ "$DEBUG" ]
        then
                echo "DEBUG INFO"
                echo "-----------------------------------------------"
                echo "Service: Name: $MyService"
                echo "Topology: $MyTopology"
                echo "Master Host: $MyMasterHost"
                echo "Replication User: $MyRepUser"
                echo "Replication Password: $MyRepUserPassword"
                echo "Installation Directory: $MyInstallDir"
                echo "Replication Servers: $MyRepMembers"
                echo "-----------------------------------------------"

                echo "Command to be executed:"
                echo "/opt/tungsten/bin/tpm install $MyService --topology=$MyTopology --master=$MyMasterHost --replication-user=$MyRepUser --replication-password=$MyRepUserPassword --install-directory=$MyInstallDir --members=$MyRepMembers --start"
        fi


echo "--- Tungsten is now ready to install.."
echo "Press [ENTER] to proceed, press [CTRL-C] to abort."
read LASTCHANCE

# need a check to see if tpm exists, and if /opt/tungsten/bin is in the users
# PATH
/opt/tungsten/bin/tpm install $MyService --topology=$MyTopology --master=$MyMasterHost --replication-user=$MyRepUser --replication-password=$MyRepUserPassword --install-directory=$MyInstallDir --members=$MyRepMembers --start

