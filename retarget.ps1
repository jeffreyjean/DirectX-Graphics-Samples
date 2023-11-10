# Specify the folder path and extension
$folderPath = "C:\github\DirectX-Graphics-Samples"
# $folderPath = "C:\github\DirectX-Graphics-Samples\Samples\Desktop\D3D12Bundles\src"
$extension = ".vcxproj"  # Replace with your desired file extension, e.g., ".pdf", ".docx", etc.

# Search for files with the specified extension recursively
$files = Get-ChildItem -Path $folderPath -Recurse -Filter "*$extension" | Where-Object { !$_.PSIsContainer }
# $files = Get-ChildItem -Path $folderPath -Recurse -Filter "*$extension"
# Display the results
foreach ($file in $files) {
    Write-Host $file.FullName
    <#
    For each vcxproj file, I want to retarget solution automatically with the following string swap as below:
    -    <WindowsTargetPlatformVersion>10.0.19041.0</WindowsTargetPlatformVersion>
    +    <WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>
    -    <PlatformToolset>v142</PlatformToolset>
    +    <PlatformToolset>v<PlatformToolset>143</PlatformToolset>
    #>

    <#
    Step 1: look for line start with <WindowsTargetPlatformVersion>
    Step 2: search version string in it, like 10.0.19041.0
    Step 3: replace with 10.0 

    Step 1.1: look for line start with <PlatformToolset>
    Step 2.1: search version string in it, like v142
    Step 3.1: replace with v143
    #>
    # Specify the patterns you want to search for
    $pattern1 = "<WindowsTargetPlatformVersion>"
    $pattern2 = "<PlatformToolset>"
    $patterns = @($pattern1, $pattern2)
    $patternCompile = "<ClCompile>"

    <#
    Phase 1: retarget the soution
    #>
    # Read the content of the file
    $file_content = Get-Content -Path $file.FullName

    # Search for the pattern and get line numbers
    $matching_lines = $file_content | Select-String -Pattern $patterns

    # Display the line numbers and content of matching lines
    foreach ($line in $matching_lines) {
        $line_number = $line.LineNumber
        $line_content = $line.Line
        Write-Host "Pattern found at line $line_number : $line_content"
        if ($line -match $pattern1) {
            # search version string and replace with new version
            # Define the start and end tokens
            $startToken = ">"
            $endToken   = "<"
            # Use regular expression to find the string between tokens
            $match = [regex]::Match($line, "$startToken(.*?)$endToken")

            # Check if a match is found
            if ($match.Success) {
                # Extract the captured group (string between tokens)
                $stringBetweenTokens = $match.Groups[1].Value
                Write-Host "String between tokens: $stringBetweenTokens"
                $newWindowsTargetPlatformVersion = "10.0"
                $line = $line -replace $stringBetweenTokens, $newWindowsTargetPlatformVersion 
                Write-Host $line
                $file_content[$line_number - 1] = $line
            } else {
                Write-Host "No match found."
            }
        } elseif ($line -match $pattern2) {
            # search version string and replace with new version
            # Define the start and end tokens
            $startToken = ">"
            $endToken   = "<"

            # Use regular expression to find the string between tokens
            $match = [regex]::Match($line, "$startToken(.*?)$endToken")

            # Check if a match is found
            if ($match.Success) {
                # Extract the captured group (string between tokens)
                $stringBetweenTokens = $match.Groups[1].Value
                Write-Host "String between tokens: $stringBetweenTokens"
                $newPlatformToolsetversion = "v143"
                $line = $line -replace $stringBetweenTokens, $newPlatformToolsetversion 
                Write-Host $line
                $file_content[$line_number - 1] = $line
            } else {
                Write-Host "No match found."
            }
        }
    }
    $file_content | Set-Content -Path $file.FullName

    <#
    Phase 2: update the compile option for Code Generation Runtime Library to static linked /MT and /MTd 
    #>
    # Read the content of the file
    $file_content = Get-Content -Path $file.FullName

    # Search for the pattern and get line numbers
    $matching_lines = $file_content | Select-String -Pattern $patternCompile
    # Display the line numbers and content of matching lines
    foreach ($line in $matching_lines) {
        $line_number = $line.LineNumber
        $line_content = $line.Line
        Write-Host "Pattern found at line $line_number : $line_content"
    }
}

