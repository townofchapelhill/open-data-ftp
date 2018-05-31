import paramiko
import os
import sys

# Open a transport

host = ""
port = 222
transport = paramiko.Transport((host, port))

# Auth

password = ""
username = "chapelhill"
transport.connect(username = username, password = password)

# Go!

sftp = paramiko.SFTPClient.from_transport(transport)


# Upload

filepath = '/datasets/.csv'
localpath = '//CHFS/Shared Documents/OpenData/datasets/staging/.csv'
sftp.put(localpath, filepath)

# Close

sftp.close()
transport.close()
