$DeviceModel = Get-ComputerInfo -Property "CsModel" | Select-Object -ExpandProperty CsModel
$SystemType  = Get-ComputerInfo -Property "CsSystemType" | Select-Object -ExpandProperty CsSystemType
$BiosVersion = Get-ComputerInfo -Property "BiosSMBIOSBIOSVersion" | Select-Object -ExpandProperty BiosSMBIOSBIOSVersion
$CoreNumber  = Get-ComputerInfo -Property "CsNumberOfLogicalProcessors" | Select-Object -ExpandProperty CsNumberOfLogicalProcessors
write-output "DeviceMode : $DeviceModel"
write-output "SystemType : $SystemType"
write-output "BiosVersion: $BiosVersion"
write-output "CoreNumber : $CoreNumber"

$visualStudioPath = "C:\Program Files\Microsoft Visual Studio"
if ($SystemType -match "x64-based PC")
{
    $msbuildName = "vcvars64.bat"
    $architecture = "amd64"
} elseif ($SystemType -match "ARM64-based PC")
{
    $msbuildName = "vcvarsarm64.bat"
    $architecture = "arm64" 
}
else {
    return 0
}

$build = "C:\github\DirectX-Graphics-Samples\samples\build.cmd"
New-Item -ItemType File -Path $build -Force

# Search for files with the specified extension recursively
$files = Get-ChildItem -Path $visualStudioPath -Recurse -Filter "*$msbuildName" | Where-Object { !$_.PSIsContainer }

# Setup build environment
foreach ($file in $files) {
    Write-Host $file.FullName
    <# Run the batch file in new session:
       Start-Process -FilePath $file.FullName -Wait
       
       Run the batch file in same session:
       & $file.FullName
    #>
    
    # Add batch command into build script
    $buildEnvSetup = '"' + $file.FullName + '"' 
    $buildEnvSetup | Out-File -FilePath $build -Append -Encoding Ascii
    break
}

# Search for files with the specified extension recursively
$files = Get-ChildItem -Path $visualStudioPath -Recurse -Filter "MSBuild.exe" | Where-Object { !$_.PSIsContainer }

foreach ($file in $files) {
    Write-Host $file.FullName
    if ($file.FullName -match $architecture) {
        Write-Host "Architecture : $architecture found in the line."
        $buildCommand = $file.FullName
    } else {
        Write-Host "Architecture : $architecture not found in the line."
    }
}
# echo off
$echoOff = '@echo off'
$echoOff | Out-File -FilePath $build -Append -Encoding Ascii

# Start time
$startTime = 'set "startTime=%time: =0%"'
$startTime | Out-File -FilePath $build -Append -Encoding Ascii

# compile all projects
$folderPath = "C:\github\DirectX-Graphics-Samples\samples"
#$folderPath = "C:\github\DirectX-Graphics-Samples\Samples\Desktop\D3D12Bundles\src"
$extension = ".sln"  # Replace with your desired file extension, e.g., ".pdf", ".docx", etc.
$files = Get-ChildItem -Path $folderPath -Recurse -Filter "*$extension" | Where-Object { !$_.PSIsContainer }
foreach ($file in $files) {
    Write-Host $file
    $compileCommand = "MSBuild " + $file.FullName + " -t:REbuild -p:Configuration=Release;Platform=x64 -t:Clean -m:" + $CoreNumber
    $compileCommand | Out-File -FilePath $build -Append -Encoding Ascii
}
<#
set "endTime=%time: =0%"
rem Get elapsed time:
set "end=!endTime:%time:~8,1%=%%100)*100+1!"  &  set "start=!startTime:%time:~8,1%=%%100)*100+1!"
set /A "elap=((((10!end:%time:~2,1%=%%100)*60+1!%%100)-((((10!start:%time:~2,1%=%%100)*60+1!%%100), elap-=(elap>>31)*24*60*60*100"

rem Convert elapsed time to HH:MM:SS:CC format:
set /A "cc=elap%%100+100,elap/=100,ss=elap%%60+100,elap/=60,mm=elap%%60+100,hh=elap/60+100"

echo Start:    %startTime%
echo End:      %endTime%
echo Elapsed:  %hh:~1%%time:~2,1%%mm:~1%%time:~2,1%%ss:~1%%time:~8,1%%cc:~1%
#>

# End time
$endTime = 'set "endTime=%time: =0%"'
$endTime | Out-File -FilePath $build -Append -Encoding Ascii

# Get elapsed time
$elapsedTime = 'set "end=!endTime:%time:~8,1%=%%100)*100+1!"  &  set "start=!startTime:%time:~8,1%=%%100)*100+1!"'
$elapsedTime | Out-File -FilePath $build -Append -Encoding Ascii
$elapsedTime = 'set /A "elap=((((10!end:%time:~2,1%=%%100)*60+1!%%100)-((((10!start:%time:~2,1%=%%100)*60+1!%%100), elap-=(elap>>31)*24*60*60*100"'
$elapsedTime | Out-File -FilePath $build -Append -Encoding Ascii
$elapsedTime = 'set /A "cc=elap%%100+100,elap/=100,ss=elap%%60+100,elap/=60,mm=elap%%60+100,hh=elap/60+100"'
$elapsedTime | Out-File -FilePath $build -Append -Encoding Ascii

# Duration time
$echoDuration = 'echo Start:    %startTime%'
$echoDuration | Out-File -FilePath $build -Append -Encoding Ascii
$echoDuration = 'echo End:      %endTime%'
$echoDuration | Out-File -FilePath $build -Append -Encoding Ascii
$echoDuration = 'echo Elapsed:  %hh:~1%%time:~2,1%%mm:~1%%time:~2,1%%ss:~1%%time:~8,1%%cc:~1%'
$echoDuration | Out-File -FilePath $build -Append -Encoding Ascii
