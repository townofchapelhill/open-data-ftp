"""
Download the permits file from the ODS sftp site for further processing
"""

import paramiko
from pathlib import Path
import sys
import datetime
import traceback
import secrets, filename_secrets
	
# Create the sftp connection with credentials from secrets file
def create_client():
	# Open a transport via paramiko
	host = secrets.odftphost
	port = 222
	transport = paramiko.Transport((host, port))

	# Authorization with login credentials
	password = secrets.odftppass
	username = secrets.odftpuser
	
	# Attempt connection and handle errors
	try: 
		transport.connect(username = username, password = password)
	except:
		print(f'Could not connect to {host}')
		print(traceback.format_exc())
	# Create sftp object
	sftp = paramiko.SFTPClient.from_transport(transport)
	# Return sftp and transport objects to main for further use
	return [sftp, transport]

if __name__ == '__main__':
	# Establish file paths
	ftp_file = "/permits.csv"
	remote_file = '/datasets' + ftp_file
	local_file = filename_secrets.productionStaging + ftp_file

	# Call functions and handle exceptions
	try:	
		sftp, transport = create_client()
		sftp.get(remote_file, local_file)	
	except:
		print(f'Could not retrieve {remote_file}')
		print(traceback.format_exc())
	
	# Close connections
	sftp.close()
	transport.close()
