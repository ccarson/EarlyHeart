# set "Option Explicit" to catch subtle errors
set-psdebug -strict
$DirectoryToSaveTo='C:\Users\ccarson\Documents\Visual Studio 2010\Projects\Ehlers_Conversion\Ehlers_Conversion\Scripts\Post-Deployment'; # local directory to save build-scripts to
$servername='EHLERS-SS2'; # server name and instance
$Database='Ehlers_Dev'; # the database to copy from (Adventureworks here)
$Filename='StaticListLoads.sql';
$TableList='dbo.AddressType
, dbo.ArbitrageCategory
, dbo.ArbitrageComputationType
, dbo.ArbitrageException
, dbo.ArbitrageRecordStatus
, dbo.ArbitrageRecordType
, dbo.ArbitrageStatus
, dbo.ARRAType
, dbo.AuditorFeeType
, dbo.BidSource
, dbo.BondFormType
, dbo.CallFrequency
, dbo.CallType
, dbo.ClientDocumentName
, dbo.ClientDocumentType
, dbo.ClientPrefix
, dbo.ClientService
, dbo.ClientStatus
, dbo.CommissionType
, dbo.ContractStatus
, dbo.County
, dbo.CreditEnhancementType
, dbo.DeliveryMethod
, dbo.DisclosureReportType
, dbo.DisclosureType
, dbo.DocumentType
, dbo.EhlersEmployee
, dbo.EhlersEmployeeJobGroups
, dbo.EhlersEmployeeJobTeams
, dbo.EhlersJobGroup
, dbo.EhlersJobTeam
, dbo.EhlersOffice
, dbo.ElectionType
, dbo.FeeBasis
, dbo.FeeType
, dbo.FinanceType
, dbo.FirmCategory
, dbo.FirmSpeciality
, dbo.FormOfGovernment
, dbo.FundingSourceType
, dbo.GoverningBoard
, dbo.InitialOfferingDocument
, dbo.InterestCalcMethod
, dbo.InterestPaymentFreq
, dbo.InterestType
, dbo.InternetBiddingType
, dbo.IssueShortName
, dbo.IssueStatus
, dbo.IssueType
, dbo.JobFunction
, dbo.JurisdictionType
, dbo.ListCategory
, dbo.MailingType
, dbo.MaterialEventType
, dbo.MeetingPurpose
, dbo.MeetingType
, dbo.MethodOfSale
, dbo.MSA
, dbo.OverlapType
, dbo.PaymentMethod
, dbo.PaymentType
, dbo.PotentialRefundType
, dbo.ProjectService
, dbo.ProjectServiceJobTeams
, dbo.Rating
, dbo.RatingType
, dbo.RefundType
, dbo.SecurityType
, dbo.ServiceCategory
, dbo.StatAuthorityGroup
, dbo.StatAuthorityGroupTypes
, dbo.StatAuthorityType
, dbo.States
, dbo.StatesCounties
, dbo.StaticList
, dbo.UnusedChoice
, dbo.UseProceed';
# a list of tables with possible schema or database qualifications
# Adventureworks used for this example
$ErrorActionPreference = "stop" # you can opt to stagger on, bleeding, if an error occurs
# Load SMO assembly, and if we're running SQL 2008 DLLs load the SMOExtended and SQLWMIManagement libraries
$v = [System.Reflection.Assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SMO')
if ((($v.FullName.Split(','))[1].Split('='))[1].Split('.')[0] -ne '9') {
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended') | out-null
  }
# Handle any errors that occur
Trap {
  # Handle the error
  $err = $_.Exception
  write-host $err.Message
  while( $err.InnerException ) {
   $err = $err.InnerException
   write-host $err.Message
   };
  # End the script.
  break
  }
# Connect to the specified instance
$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ServerName
# Create the Database root directory if it doesn't exist
$homedir = "$DirectoryToSaveTo\"
if (!(Test-Path -path $homedir))
  {Try { New-Item $homedir -type directory | out-null }
     Catch [system.exception]{
        Write-Error "error while creating '$homedir'  $_"
        return
        }
  }
$scripter = new-object ('Microsoft.SqlServer.Management.Smo.Scripter') $s
$scripter.Options.ScriptSchema = $False; #no we're not scripting the schema
$scripter.Options.ScriptData = $True; #but we're scripting the data
$scripter.Options.ScriptDrops = $False; #but we're scripting the data
$scripter.Options.NoCommandTerminator = $true;
$scripter.Options.FileName = $homedir+$Filename #writing out the data to file
$scripter.Options.ToFileOnly = $true #who wants it on the screen?
$scripter.Options.AppendToFile = $false #who wants it on the screen?
$ServerUrn=$s.Urn #we need this to construct our URNs.
$UrnsToScript = New-Object Microsoft.SqlServer.Management.Smo.UrnCollection
#so we just construct the URNs of the objects we want to script
$Table=@()
foreach ($tablepath in $TableList -split ',')
  {
  $Tuple = "" | Select Database, Schema, Table
  $TableName=$tablepath.Trim() -split '.',0,'SimpleMatch'
   switch ($TableName.count)
    {
      1 { $Tuple.database=$database; $Tuple.Schema='dbo'; $Tuple.Table=$tablename[0];  break}
      2 { $Tuple.database=$database; $Tuple.Schema=$tablename[0]; $Tuple.Table=$tablename[1];  break}
      3 { $Tuple.database=$tablename[0]; $Tuple.Schema=$tablename[1]; $Tuple.Table=$tablename[2];  break}
      default {throw 'too many dots in the tablename'}
    }
     $Table += $Tuple
   }
foreach ($tuple in $Table)
  {
   $Urn="$ServerUrn/Database[@Name='$($tuple.database)']/Table[@Name='$($tuple.table)' and @Schema='$($tuple.schema)']";
  $urn
   $UrnsToScript.Add($Urn)
  }
#and script them
$scripter.EnumScript($UrnsToScript) #Simple eh?
"Saved to $homedir"+$Filename+', wondrous carbon-based life form!'
"done!"