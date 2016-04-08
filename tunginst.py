#!/usr/local/bin/python
import sys
import string
import os
import subprocess
import MySQLdb


# verify user is root.
#if os.geteuid() != 0:
#	exit("\n**ERROR**\nYou need to be the root user to execute this script.\n")

myVer = "0.04"

def Preamble():
	print "Tungsten MySQL Replicator Installation  v" + myVer
	print ""
	print "This script assumes the following items are already in place:"
	print "----------"
	print "1) You have a DB user, with password already provisioned on each DB within replication environment."
	print "2) You have have firewall rules in place to allow port 22, 2112 and 10000 communication between all servers replicating."
	print "3) You have a Trusted SSH Key relationship between this server and all remaining servers in this replication environment."
	print "4) Each DB will need the following items added to it's my.cnf filei within the [mysqld] section:"
	print "  a) max_allowed_packet=52m"
	print "  b) log-bin=mysql-bin"
	print "  c) server-id=<unique int value>"
	print "5) JDK 1.7 is installed and  JAVA_HOME is set correctly."
	print "----------"
	readPause = raw_input('Press [ENTER] to continue..')




Preamble()
print("--- The replication user MUST already exist in MySQL..")
repUser = raw_input('Enter replication username: ')

print("--- The replication user password will be used to verify MySQL connectivity..")
repPass = raw_input('Enter replication user password: ')

# test MySQL connection.
try:
	print("--- Testing MySQL connection..")
	connString = "'localhostuser', '" + repUser + "', '"+ repPass + "'"
	db = MySQLdb.connect( connString)
	db.query("SELECT version()")
	result = db.use_result()
	print("Test Successful.")
except MySQLdb.error, e:
	print "ERROR: %d: %s" % (e.args[0], e.args[1]) 
	sys.exit(1)
finally:
	if db:
		db.close()
	

print("--- Choose the replication type below..")
MasterSlave = raw_input('Will this be a Master->Slave environment? [Y/N]: ')
if MasterSlave in ['y', 'Y']:
	Topology = "master-slave"
else:
	MasterMaster = raw_input('Will this be a Master<>Master environment? [Y/N]: ')
	if MasterMaster in [ 'y', 'Y']:
		Topology = "master-master"
	else:
		print("You did not enter a supported replication type!")
		exit()

print("--- A 'service name' is a label given to your replicated environment..")
serviceName = raw_input('Enter the replication service name [ex: standard]: ')


print("--- The 'Fully Qualified Domain Name' of the Master server is required..")
FQDN = raw_input("What is this server's FQDN? ")


print("--- The installation directory will contain all Tungsten files..")
installDir = raw_input('Enter the installation directory [ex: /opt/replication]: ')

print("\n** NOTE: You MUST include " + installDir + "/bin in your PATH environment **\n")


print("--- We need a list of ALL servers participating in this replicated environment (including this server.)")
serverList = raw_input('Enter a comma-delimited list of each server [ex: master1.domain.com,slave1.domain.com]: ')



# debug info output.
print("You have entered the following data:")
print("------------------------------------")
print("Replication Username: " + repUser + " Replication Password: " + repPass )
print("Topology: " + Topology )
print("Service name: " + serviceName)
print("This servers FQDN: " + FQDN)
print("install directory: " + installDir)
print("server list: " + serverList)
print("-----------------------------------")
lastChance = raw_input("Proceed with installation? [Y/N]: ")
if lastChance in ['y', 'Y']:
	print("starting installation, this will take a bit of time..")
	execString = "/opt/bin/tungsten/bin/tpm install " + serviceName + " --topology=" + Topology + " --master=" + FQDN + " --replication-user=" + repUser + " --replication-password=" + repPass + " --install-directory=" + installDir + " --members=" + serverList 
#	print( execString )
	subprocess.call([ 'execString'])
else:
	print("Installation aborted!")
	exit()