<# Kronos Cell Phone Check by Christoher Durham
    Goal: Check Kronos for current cell numbers listed in Cannon.
#>
#csvPaths
cls
Write-Host "Kronos-System Cell Phone Checker by Christoher Durham" -ForegroundColor Cyan
$pathToKronosCsv = "G:\PS - ToolKit\KronosCellCompare\kronos_csv_files\KronosPhones.csv"
$pathTocannonCsv = "C:\Users\CDurham\OneDrive - Community Option\Desktop\cannon\cannon.csv"
$pathToLineCsv = "G:\PS - ToolKit\KronosCellCompare\kronos_csv_files\Lines.csv"
$PathToTempEmployeeFileCsv = 'G:\PS - ToolKit\KronosCellCompare\kronos_csv_files\tempemployeefile.csv'
$pathToTempCsv = $PathToTempEmployeeFileCsv
$myDesktop = "C:\Users\CDurham\OneDrive - Community Option\Desktop\KronosUpdate.csv"

# Kronos Import
$kronoscsv = Get-Content -Path $pathToKronosCsv |
Select-Object -skip 0 |
ConvertFrom-Csv -Header "ExtentionGroupName", "PhoneNumber", "Description"
foreach($extention in $kronoscsv){

    $kronosNumbers = $($kronoscsv.PhoneNumber)
}

# Cannon Import
$cannoncsv = Get-Content -Path $pathTocannonCsv |
ConvertFrom-Csv -Header "Company Code","EmployeeNumber", "FirstName", "LastName", "EmailAddress", "EmploymentStatus", "Department", "DepartmentCode", "JobTitle", "Location", "Cost Code", "SupervisorName", "Region", "ManagersEmail"
foreach($employee in $cannoncsv){

    $employeeID = $($cannoncsv.EmployeeNumber)
}
# CellPhone Import
$linecsv = Get-Content -Path $pathToLineCsv |
Select-Object -skip 0 |
ConvertFrom-Csv -Header "PhoneNumber", "User", "Carrier","Device","Plan","TotalCharge","LineStatus","CarrierLabel","Owner","CostCenter","Serial" 
foreach($cellNumber in $linecsv){
    $owners = $($linecsv.User)
    $cell = $($linecsv.PhoneNumber) 
    $cellfix = $cell.replace("+1","")
    $cellClean = $cellfix.replace("-","")

}

# Check cell phone numbers against Kronos Spreadsheet store in list
$KronosMatches = @()
foreach ($kronosNumber in $kronosNumbers){
    if ($cellClean -match $kronosNumber){
    $KronosMatches += $kronosNumber
    }
}

# formatted new list back to orginal state
$formattedNumbers = @()
foreach ($match in $KronosMatches){
    $add1 = $match.Insert(0,"+1")
    $addspace = $add1.Insert(2," ")
    $firstdash = $addspace.Insert(6,"-")
    $secdash = $firstdash.Insert(10,"-")
    $formattedNumbers += $secdash
}   


# Get user names from lines csv based on $formatedNumbers
$employees = @()
ForEach($num in $formattedNumbers){
    $employeeCatch = $linecsv | where {$_.PhoneNumber -eq $num} | Format-Table -AutoSize -HideTableHeaders -Property User, PhoneNumber
    $employees += $employeeCatch
}
$employees | Out-File -FilePath $PathToTempEmployeeFileCsv

# remove empty spaces from temp csv and split columns
$content = Get-Content -Path $pathToTempCsv
$content -notmatch '(^[\s,-]*$)|(rows\s*affected)' | Set-Content -Path $pathToTempCsv # found online to fix spaces.
$EmployeeNames = @()
$tempData = Get-Content -Path $pathToTempCsv
foreach($line in $tempData){
    $colum = $line -replace " ","," -split ","
    $obj = New-Object psobject -Property @{
        First  = $colum[0]
        Last   = $colum[1]
        #Various = $colum[2]
        Phone = $colum[3]
    }
    $person = $obj | select first,last,Phone
    $EmployeeNames += $person
} 
$EmployeeNames | Export-Csv $pathToTempCsv -NoTypeInformation -Encoding UTF8
$EmployeeNames
Copy-Item $pathToTempCsv -Destination $myDesktop
