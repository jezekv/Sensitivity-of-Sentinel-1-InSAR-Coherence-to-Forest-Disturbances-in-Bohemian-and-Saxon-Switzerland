# ================================
# SNAP coherence batch
# ================================

# --- USER PATHS ---
$Workspace         = "C:\PATH\TO\YOUR\WORKSPACE"
$UrlsFile        = "$Workspace\urls.txt"
$CoherenceGraph  = "$Workspace\coherence.xml"

# FILL IN YOUR PATH TO ARIA2C.EXE:
$Aria2Exe        = "C:\PATH\TO\aria2c.exe"
# DEFAULT SNAP GPT PATH (UPDATE IF NEEDED):
$GptExe          = "C:\Program Files\esa-snap\bin\gpt.exe"

$DownloadDir     = "$Workspace\temp_download"
$OutputDir       = "$Workspace\coherence_out"

# --- PREPARE FOLDERS ---
New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null
New-Item -ItemType Directory -Path $OutputDir    -Force | Out-Null

# --- LOAD URL LIST (2 lines = 1 pair) ---
$urls = Get-Content $UrlsFile
$pairIndex = 1

for ($i = 0; $i -lt $urls.Count; $i += 2) {

    Write-Host "Processing pair $pairIndex..."

    # --------------------------------
    # STEP 1+2: Download pair
    # --------------------------------
    $pairUrls = $urls[$i..($i + 1)]
    $pairListFile = "$Workspace\urls_pair_tmp.txt"
    $pairUrls | Set-Content $pairListFile

# FILL IN YOUR USERNAME AND PASSWORD
    & $Aria2Exe `
        --http-auth-challenge=true `
        --http-user="YOUR_USERNAME_HERE" `
        --http-passwd="YOUR_PASSWORD_HERE" `
        --input-file="$pairListFile" `
        --dir="$DownloadDir" `
        -c -j1 -x4 -s4 `
        --max-tries=5 `
        --retry-wait=30

    # --------------------------------
    # STEP 3: Define master / slave
    # --------------------------------
    $pairFiles = Get-ChildItem $DownloadDir -File -Filter *.zip | Sort-Object LastWriteTime

    if ($pairFiles.Count -ne 2) {
        Write-Warning "Expect 2 .zip files. Found $($pairFiles.Count). Skipping pair."
        Remove-Item "$DownloadDir\*" -Force
        $pairIndex++
        continue
    }

    $masterPath = $pairFiles[0].FullName
    $slavePath  = $pairFiles[1].FullName

    $masterName = [System.IO.Path]::GetFileNameWithoutExtension($pairFiles[0].Name)
    $slaveName  = [System.IO.Path]::GetFileNameWithoutExtension($pairFiles[1].Name)

    # Extract acquisition dates for filename
    $masterDate = ([regex]::Match($masterName, '\d{8}T\d{6}')).Value
    $slaveDate  = ([regex]::Match($slaveName,  '\d{8}T\d{6}')).Value

    # --------------------------------
    # STEP 4: GPT Processing 
    # --------------------------------
    Write-Host "Running GPT processing..."
    
    $outputFile = "coh_VV_${masterDate}_${slaveDate}.tif"

    & $GptExe `
      -c 8G `
      -q 4 `
      $CoherenceGraph `
      -Pmaster="$masterPath" `
      -Pslave="$slavePath" `
      -Poutput="$OutputDir\$outputFile"

    # --------------------------------
    # STEP 5: Clean up
    # --------------------------------
    Remove-Item "$DownloadDir\*" -Force
    $pairIndex++
}