$sqlFiles = get-childitem '..\..\Schema Objects'  *.sql -rec
$revDate = Get-Date
foreach ($file in $sqlFiles)
{
    IF ( (Get-Content($file.PSPath)) | Select-String '###DATE###' -quiet )
    { 
        write-host $file.PSPath
        (Get-Content($file.PSPath)) | 
        ForEach-Object {$_ -replace '###DATE###', $revDate.ToString("yyyy-MM-dd")} |
        Set-content ($file.PSPath) 
    }
        
}