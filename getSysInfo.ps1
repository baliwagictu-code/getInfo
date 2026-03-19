$FullName = Read-Host "Fullname"
$PropertyNumber = Read-Host "Property No."

# Device type
$choice = Read-Host "Select Device Type [1]Laptop [2]Desktop:"
if ($choice -eq "1") {
    $deviceType = "Laptop"
} elseif ($choice -eq "2") {
    $deviceType = "Desktop"
} else {
    $deviceType = "Unknown"
}

# =========================
# MOTHERBOARD (FIX BRAND)
# =========================
$mb = Get-CimInstance Win32_BaseBoard
$cs = Get-CimInstance Win32_ComputerSystem
$uuid = (Get-CimInstance Win32_ComputerSystemProduct).UUID

$mbModel = $mb.Product
$mbmodel = "$mbModel | $uuid"

$bios = Get-CimInstance Win32_BIOS
$deviceSerial = $bios.SerialNumber

# =========================
# CPU
# =========================
$cpuInfo = Get-CimInstance Win32_Processor
$cpu = $cpuInfo.Name


# =========================
# RAM (separate sticks)
# =========================
$ramList = Get-CimInstance Win32_PhysicalMemory | ForEach-Object {
    $brand = $_.Manufacturer
    $capacity = [math]::Round($_.Capacity / 1GB)
    $serial = $_.SerialNumber
    "$brand ${capacity}GB SN:$serial"
}
$ram = ($ramList -join " | ")


# =========================
# STORAGE (REAL TYPE FIX)
# =========================
$storageList = Get-PhysicalDisk | ForEach-Object {

    $brand = $_.Model
    $capacity = [math]::Round($_.Size / 1GB)
    $serial = $_.SerialNumber
    $type = $_.MediaType



    "$brand ${capacity}GB $type SN:$serial"
}
$storage = ($storageList -join " | ")


# =========================
# GPU
# =========================
$gpuList = Get-CimInstance Win32_VideoController | ForEach-Object {
    $name = $_.Name
    $vram = if ($_.AdapterRAM) { [math]::Round($_.AdapterRAM / 1GB) } else { "?" }
    "$name ${vram}GB"
}
$gpu = ($gpuList -join " | ")


# =========================
# OS
# =========================
$os = (Get-CimInstance Win32_OperatingSystem).Caption


# =========================
# SEND
# =========================
Invoke-RestMethod -Uri "https://script.google.com/a/macros/deped.gov.ph/s/AKfycbxIqOkQz6kjZdg6eFIoZSLN5Y9vHVxojEHebb2eOijuFFlUF3qb6aJzN5u2Sx8IXzzdRg/exec" -Method POST -Body @{
    fullname = $FullName
    propertynumber = $PropertyNumber
    devicetype = $deviceType
    pc = $env:COMPUTERNAME
    mbbrand = if ($deviceSerial -and $deviceSerial.Trim() -ne "") {
    "$($mb.Manufacturer) SN:$deviceSerial"
} else {
    $mb.Manufacturer
}
    mbmodel = $mbmodel
    cpu = $cpu
    ram = $ram
    storage = $storage
    gpu = $gpu
    windows = $os
}