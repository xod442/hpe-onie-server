#!/usr/bin/env python

'''
 Copyright 2016 Hewlett Packard Enterprise Development LP.
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
__author__ = "@netwookie"
__credits__ = ["Rick Kauffman"]
__license__ = "Apache2"
__version__ = "1.0.0"
__maintainer__ = "Rick Kauffman"
__email__ = "rick@rickkauffman.com"
__status__ = "Prototype"
'''
import comware
import os
import sys
import csv
from string import Template

# Create application variables
#----------------------------------------------------------------
# You will need to change the IP address to the ZTP server IP
#----------------------------------------------------------------

serverTftp="172.16.0.2"

#-----------------------------------------------------------
# File names to be transfered to Comware Switch during boot
#-----------------------------------------------------------
file2="ansible_template.txt"
file3="varMatrix.csv"



# Copies necessary files from the ZTP server, sets MGMT interface to DHCP
def copyFiles():
    try:
        comware.CLI("system ; interface m0/0/0 ; ip address dhcp")
    except SystemError:
        pass
    try:
        comware.CLI("tftp " + serverTftp + " get " + file2)
    except SystemError:
        pass
    try:
        comware.CLI("tftp " + serverTftp + " get " + file3)
    except SystemError:
        pass

def configureSwitch():

	# Set counter to track items

	count = 0

	# Open the template

	form = open('flash:/ansible_template.txt', 'r')
	src = Template( form.read() )


	# Open the csv file build Dictionary

	csvfile = open('flash:/varMatrix.csv', 'r')
	content = csv.DictReader(csvfile)
	switch = []

    # Build a list of rows for the CSV file
	for row in content:
		switch.append(row)

    print switch

	# How many switches do we have?

	check = len(switch)

	# Get system MAC address (Screen Scraping)

	switchMacAddress=comware.CLI("disp irf | i MAC").get_output()[1][-14:]


	while (count < check):

		# Substitute CSV variables in the template file if the MAC address is a match

		if switchMacAddress == switch[count]['mac']:
			result = src.substitute(switch[count])
			config = open('flash:/startup.cfg','w')
			config.write(result)
		count = count + 1

	# Be nice and close the files

	csvfile.close()
	form.close()

def cleanup():

	# Clean this mess up else we all wind up in jail

	comware.CLI('startup saved-configuration startup.cfg backup')
	comware.CLI('startup saved-configuration startup.cfg main')
	comware.CLI('delete /unreserved *.txt')
	comware.CLI('delete /unreserved *.csv')
	comware.CLI('sys ; public-key local create rsa')
	comware.CLI('ping 8.8.8.8')
	comware.CLI('reboot force')



copyFiles()
configureSwitch()
cleanup()
quit()
