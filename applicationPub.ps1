<#
						
			Author  :  Harinderpal Singh
			Date	: 28-October-2014
			Version : 1


#>

# Load the snapins
 
Add-PSSnapin citrix* -ErrorAction SilentlyContinue
 
#import the csv file
 
$apps = Import-Csv .\apps.csv
$ver = Get-XAFarm
$ver = $ver.ServerVersion.Major

$ICON = Read-Host "Do you want to set Icons, Please type Y/N"
 
 
#each line in the csv
 
foreach($app in $apps)
 
{
 
  	
 if ($ICON -eq "Y")
	{
	
    try{
 
        ##$EncodedIconData = Get-CtxIcon $app.CommandLineExecutable -index 0
		if ($ver -eq "4") 
			{
			$EncodedIconData = Get-XAIconStream $app.IconPath -index 0
			$EncodedIconData=$EncodedIconData.EncodedIconData
			}
		else 
			{if ($app.IconPath.contains('.exe')){$EncodedIconData = Get-CtxIcon $app.IconPath -index 0}
			else {$EncodedIconData = Get-CtxIcon $app.IconPath}
			}
		##$EncodedIconData = $app.IconPath
		$EncodedIconData = '"' + $EncodedIconData + '"'
 
    } catch [Exception] {
 
        Write-Host "Error: Obtaining the icon failed: " $_.Exception.Message
 
    }
	}
 
 
    #checking browsername length, found out it has a limit
 
    if($app.BrowserName.length -gt 36)
 
    {
 
        Write-Host "Error: BrowserName for " $app.BrowserName " length is to long, must be less than 36 characters, please correct" 											-foregroundcolor "Red"
 
    }
	if ($app.BrowserName.contains(“.”) -or $app.FolderPath.contains(“.”) -or $app.ClientFolder.contains(“.”) -or $app.DisplayName.contains(“.”) -or $app.Description.contains(“.”))
	{
	Write-Host "Unacceptable character '.' found kindly revalidate the inputs" 											-foregroundcolor "Red"
	break
	}
 
    else
 
    {
		$app.BrowserName = '"' + $app.BrowserName + '"'
		#if ($app.CommandLineExecutable.contains(“ ”))
		if ($app.CommandLineExecutable.contains(' ')){
		if ($app.CommandLineExecutable.contains('"')){}
		else 
			{
			Write-Host "Uff you missed to add quotes in Command line Executable I'm adding it for you " -foregroundcolor "magenta"
			$app.CommandLineExecutable = '"' + $app.CommandLineExecutable + '"'
			}
		}
		$app.CommandLineExecutable = "'" + $app.CommandLineExecutable + "'"
		$app.FolderPath = '"' + $app.FolderPath + '"'
		$app.ClientFolder = '"' + $app.ClientFolder + '"'
		$app.DisplayName = '"' + $app.DisplayName + '"'
		$app.Description = '"' + $app.Description + '"'
		$app.WorkingDirectory = '"' + $app.WorkingDirectory + '"'
      
 
        $success = $FALSE
 		##$NewApp = "New-XAApplication -ApplicationType ServerInstalled " + " -EncodedIconData " + $EncodedIconData + " -ServerNames " + $app.WorkerGroupNames + " -BrowserName " + $app.BrowserName + " -Enabled " + "TRUE" + " -Accounts " + $app.Accounts + $newapp2
		##$newapp2 = " -WorkingDirectory " + $app.WorkingDirectory + " -CommandLineExecutable " + $app.CommandLineExecutable + " -FolderPath " +  $app.FolderPath + " -ClientFolder " + $app.ClientFolder + " -WindowType " + $app.WindowType + " -ColorDepth " + $app.ColorDepth + " -InstanceLimit " + $app.InstanceLimit + " -AddToClientStartMenu " + "0" + " -AnonymousConnectionsAllowed " + "0"  + " -EncryptionLevel " + "Bits128" + " -AudioRequired " + $app.AudioRequired + " -ErrorAction Stop "
		if ($ICON -eq "Y")
		{
		$newapp2 = " -WorkingDirectory " + $app.WorkingDirectory + " -CommandLineExecutable " + $app.CommandLineExecutable + " -FolderPath " +  $app.FolderPath + " -ClientFolder " + $app.ClientFolder + " -WindowType " + $app.WindowType + " -ColorDepth " + $app.ColorDepth + " -MultipleInstancesPerUserAllowed " + $app.InstanceLimit + " -AddToClientStartMenu " + "0" + " -AnonymousConnectionsAllowed " + "0"  + " -EncryptionLevel " + "Bits128" + " -AudioRequired " + $app.AudioRequired + " -EncodedIconData " + $EncodedIconData + " -ErrorAction Stop "
		}

		else
		{
		$newapp2 = " -WorkingDirectory " + $app.WorkingDirectory + " -CommandLineExecutable " + $app.CommandLineExecutable + " -FolderPath " +  $app.FolderPath + " -ClientFolder " + $app.ClientFolder + " -WindowType " + $app.WindowType + " -ColorDepth " + $app.ColorDepth + " -MultipleInstancesPerUserAllowed " + $app.InstanceLimit + " -AddToClientStartMenu " + "0" + " -AnonymousConnectionsAllowed " + "0"  + " -EncryptionLevel " + "Bits128" + " -AudioRequired " + $app.AudioRequired + " -ErrorAction Stop "
		}
		##$newapp2 = " -WorkingDirectory " + $app.WorkingDirectory + " -CommandLineExecutable " + $app.CommandLineExecutable + " -FolderPath " +  $app.FolderPath + " -ClientFolder " + $app.ClientFolder + " -WindowType " + $app.WindowType + " -ColorDepth " + $app.ColorDepth + " -MultipleInstancesPerUserAllowed " + $app.InstanceLimit + " -AddToClientStartMenu " + "0" + " -AnonymousConnectionsAllowed " + "0"  + " -EncryptionLevel " + "Bits128" + " -AudioRequired " + $app.AudioRequired + " -EncodedIconData " + $app.IconData + " -ErrorAction Stop "
		$NewApp = "New-XAApplication -ApplicationType ServerInstalled " + " -ServerNames " + $app.WorkerGroupNames + " -BrowserName " + $app.BrowserName + " -DisplayName " + $app.DisplayName+ " -Description " + $app.Description + " -Enabled " + "1" + " -Accounts " + $app.Accounts + $newapp2
        ##$NewApp     
             
            
 			
 
        #try to publish new app
		
 
        try {
 		##	$NewApp
         	iex $NewApp
 
                        
            $success = $TRUE
 
        } catch {
 
             Write-Host "Error: " $_.Exception.Message -foregroundcolor "Red"
 
        } finally {
 
            if($success)
 
            {
 
                Write-Host $app.BrowserName "added successfully." -foregroundcolor "green"
 
            }
 
        }
 
         
 
         
 
    }
 
 
 
     
 
}