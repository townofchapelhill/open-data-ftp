# Open log file
log = open("//CHFS/Shared Documents/OpenData/datasets/logfiles/odftplog.txt", "a")


# Import necessary libraries and handle errors
try:
	import paramiko
	import os
	import sys
	import datetime
	import traceback
	import secrets
except: 
	log.write("Could not import libraries. \n")
	log.write(traceback.format_exc())
	
	
# Create the sftp connection with credentials from secrets file
def create_client(log):
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
		log.write("Could not connect. \n")
		log.write(traceback.format_exc())
	log.write("Connected successfully. \n")

	# Create sftp object
	sftp = paramiko.SFTPClient.from_transport(transport)
	
	# Return sftp and transport objects to main for further use
	return [sftp, transport]


# Move files from od server to ftp/datasets
def move_files(log, sftp):
	# Establish file paths
	filepath = '/datasets/'
	localpath = '//CHFS/Shared Documents/OpenData/datasets/staging/'
	
	# Move all csv and json files in staging
	print("Files to move: ")
	for file in os.listdir(localpath):
	
		# Move all csv files
		if (file.endswith(".csv")):
			# Print for understanding and testing
			print(file)
			# Attempt to move files to ftp and handle errors
			try:
				sftp.put(localpath+file, filepath+file)
			except:
				log.write("Could not move files. \n")
				log.write(traceback.format_exc)
				
		# Move all json files
		if (file.endswith(".json")):
			# Print for understanding and testing
			print(file)
			# Attempt to move files to ftp and handle errors
			try:
				sftp.put(localpath+file, filepath+file)
			except:
				log.write("Could not move files. \n")
				log.write(traceback.format_exc)
				
	# Log success
	log.write("Files moved successfully. \n")

	
# Create main function to create logs and call all functions
def main(log):
	
	# For readability: if the log file is empty, don't start with a blank line, if it's not empty add a blank line 
	if os.stat("//CHFS/Shared Documents/OpenData/datasets/logfiles/odftplog.txt").st_size == 0:
		log.write(str(datetime.date.today())+ str(datetime.time()) + "\n")
		log.write("Successfully imported all libraries. \n")
	else: 
		log.write("\n" + str(datetime.date.today()) + str(datetime.time()) + "\n")
		log.write("Successfully imported all libraries. \n")
		
	# Call functions and handle exceptions
	try:	
		client_list = create_client(log)
		# Hold sftp and transport returned by function in vars
		sftp = client_list[0]
		transport = client_list [1]
		move_files(log, sftp)
	except:
		log.write("Could not complete create_client and move_files functions. \n")
		log.write(traceback.format_exc())
	
	# Close connections
	sftp.close()
	transport.close()

# Call main
main(log)
