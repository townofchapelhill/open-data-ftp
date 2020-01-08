# open_data_ftp
## Purpose 
Python scripts that establish a connection to the Open Data Soft FTP server to move files to/from our Open Data Site via SFTP.

## Open_data_ftp_download
Download a file, specified as a command line argument, from the ODS SFTP site to a local file system

## Open_data_ftp_upload
Upload CSV and JSON files from a local source to the ODS SFTP site

### Methodology
Uses Paramiko library for connection and transport

### Constraints
Must install paramiko via 'pip install paramiko'