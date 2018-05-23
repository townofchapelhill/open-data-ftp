# Locate path to config file containing FTP connection info
param([string]$configPath)
$configPath = "\\CHFS\Shared Documents\OpenData\config\opendata_config.ps1"

# Load WinSCP .NET assembly
Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

#load the config file from the commandline argument
. ($configPath)

# Function to remove backup files
function purgeBackups($src_tgt) {
	# DAYS_TO_SAVE is from config file (30)
	$d = 0 - $DAYS_TO_SAVE
	# Add days to current date for cutoff
	$cutoff = (Get-Date).AddDays($d)
	
	# Gets file paths for files in stagingbackup folder
	# The "backup" is why it goes to stagingbackup I think
	Get-ChildItem ($src_tgt.src + "backup") |
	Foreach-Object {
	# Print for testing 
	# Write-Output "purgeBackups: "
	# Write-Output $_.FullName
        $fd = (Get-Date -date (($_.Name).split("_")[0]))
		if ($fd -le $cutoff) {
            		Write-Host ("Purging {0}" -f $_.FullName)
			Write-Log ("Purging {0}" -f $_.FullName)
            		Remove-Item $_.FullName -recurse -force -Verbose
        	}
		else {
			# Print for testing
			# ---- THIS IS WHERE AN ERROR IS HAPPENING ----
			Write-Output "Nothing is Purging"
		}		
	}
}

# this requires WinSCP .NET assembly. See https://winscp.net/eng/docs/library
function upload($src_tgt) {
	try
	{
        	# Setup session options
		# Used session properties from config file
        	$sessionOptions = New-Object WinSCP.SessionOptions -Property $SESSION_PROPERTIES
       		$session = New-Object WinSCP.Session
        try
        {
		# Connect using config credentials
            	$session.Open($sessionOptions)
            	# Upload files
		# Transfer options set up from WinSCP library
            	$transferOptions = New-Object WinSCP.TransferOptions
            	$transferOptions.TransferMode = [WinSCP.TransferMode]::Ascii
		# PutFiles is a WinSCP method that uploads files from local to remote directory 
		# $FILE_FILTER, src, and tgt are from config file
		# $FALSE is from PutFiles method, setting to true deletes local files, false is default
            	$transferResult = $session.PutFiles($src_tgt.src + $FILE_FILTER, $src_tgt.tgt, $False, $transferOptions)

            	# Throw on any error
		# This is a method from TransferOperationResultClass within WinSCP.net that deals with errors
            	$transferResult.Check()
 
            	# Print results
		# Transfers is a property of TransferOperationResultClass, but no details on what it does
            	foreach ($transfer in $transferResult.Transfers)
			{
				# Print for testing
				Write-Output "File to be transferred: "
				Write-Output $transfer.FileName
				
				# Inserts filename into string
                		Write-Host ("Upload of {0} succeeded" -f $transfer.FileName) -Verbose
				Write-Log ("Upload of {0} succeeded" -f $transfer.FileName)
				Write-Output "`n"
           		 }
        }
		
	# Finally block runs every time the script is run, with or without errors
        finally
        {
            # Disconnect, clean up
            $session.Dispose()
        }
 
        #exit 0
    }
	# Catch exception errors and print message
    	catch [Exception]
    	{
       		Write-Host ("Error: {0}" -f $_.Exception.Message)
        	#exit 1
    	}
}


function processFiles() {
# loop through SRC_AND_TGT, which is located in the config file
    ForEach ($obj in $SRC_AND_TGT) {
        # make sure backup directory exists
        $backPath = $obj.src + "backup\$((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss'))"
		
		# Print obj for testing
		Write-Output $obj
		Write-Output "`n"
		
		# Print backPath for testing
		Write-Output "backPath is: "
		Write-Output $backPath
		Write-Output "`n"
		
		# Creates new item: director with path being $backPath
		# -Force should allow overwriting for existing items
        New-Item -Force -ItemType Directory -Path -Verbose $backPath | Out-Null
		
		# Calls upload function from above
        upload $obj

        try {
			# Gets items from CHFS staging source filtered by type
            Get-ChildItem $obj.src -Filter $FILE_FILTER | 
            Foreach-Object {
				# Print for testing 
				Write-Output $_.FullName
				# For each, move the item 
				# ---- I THINK THIS IS WHERE THE ERRORS HAPPEN ----
                Move-Item -Path $_.FullName $backPath
            }
        }  
        catch [Exception]
        {
			# Print exception errors
            Write-Host ("Error: {0}" -f $_.Exception.Message)        
        }
		
		# Calls purgeBackups function from above
        purgeBackups $obj
    }
}

# Call process files function 
processFiles

