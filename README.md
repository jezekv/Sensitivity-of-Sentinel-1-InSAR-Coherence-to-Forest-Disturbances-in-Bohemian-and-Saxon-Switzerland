# Sentinel-1 InSAR Coherence Processing Pipeline

This repository provides an automated workflow to download Sentinel-1 SLC image pairs from the Alaska Satellite Facility (ASF) and process them through the ESA SNAP Graph Processing Tool (`gpt`) to generate an InSAR coherence time series used in the paper: *Sensitivity of Sentinel-1 InSAR Coherence to Forest Disturbances in Bohemian and Saxon Switzerland*.

## Repository Contents

* **`run_coherence.ps1`** – Main PowerShell script that downloads image pairs via `aria2c`, invokes SNAP `gpt`, and cleans up temporary archives.
* **`coherence.xml`** – SNAP processing graph (Read -> Apply Orbit file -> TOPSAR-Split -> Back-Geocoding -> Enhanced Spectral Diversity -> TOPSAR Deburst -> Coherence -> Multilook -> Terrain Correction -> Write).
* **`urls.txt`** – Ordered list of Sentinel-1 SLC download URLs (every two consecutive lines define one interferometric pair).

## Requirements

* [ESA SNAP](https://step.esa.int/main/download/snap-download/) (`gpt` command line tool)
* [aria2](https://aria2.github.io/) (`aria2c.exe`)
* Windows PowerShell
* [NASA Earthdata](https://urs.earthdata.nasa.gov/) account (with ASF Data Search authorized)

## How to Run

1. **Configure credentials and paths:**  
   Open `run_coherence.ps1` and specify your workspace path, `aria2c.exe` path, and Earthdata login:
   ```powershell
   $Workspace = "C:\PATH\TO\YOUR\WORKSPACE"
   $Aria2Exe  = "C:\PATH\TO\aria2c.exe"

   --http-user="YOUR_USERNAME_HERE"
   --http-passwd="YOUR_PASSWORD_HERE"
   ```

2. **Execute the script:**  
   Open PowerShell, navigate to the repository directory, and run:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

   .\run_coherence.ps1
   ```

Outputs will be saved as GeoTIFF files in the `coherence_out/` directory.

---

For questions or issues regarding the scripts, please contact us at jezekv@fzp.czu.cz
