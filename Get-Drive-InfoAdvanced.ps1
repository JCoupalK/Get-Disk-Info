Get-PhysicalDisk | Select-Object MediaType | Out-File -FilePath $env:userprofile\Drive-Info.txt
    Get-WmiObject Win32_DiskDrive | ForEach-Object {
    $disk = $_
    function Get-Type-Info {
        Select-String -Path "$env:userprofile\Drive-Info.txt" -Quiet 'SSD'
    }

    if (Get-Type-Info true) {
        $DriveType = 'SSD'
    } else { $DriveType = 'HDD' }
$(
    $partitions = "ASSOCIATORS OF " +
                  "{Win32_DiskDrive.DeviceID='$($disk.DeviceID)'} " +
                  "WHERE AssocClass = Win32_DiskDriveToDiskPartition"
    Get-WmiObject -Query $partitions | ForEach-Object {
      $partition = $_
      $drives = "ASSOCIATORS OF " +
                "{Win32_DiskPartition.DeviceID='$($partition.DeviceID)'} " +
                "WHERE AssocClass = Win32_LogicalDiskToPartition"
      Get-WmiObject -Query $drives | ForEach-Object {
        New-Object -Type PSCustomObject -Property @{
          Disk        = $disk.DeviceID
          DiskSize    = $disk.Size
          DiskModel   = $disk.Model
          Partition   = $partition.Name
          RawSize     = $partition.Size
          DriveLetter = $_.DeviceID
          VolumeName  = $_.VolumeName
          Size        = $_.Size
          FreeSpace   = $_.FreeSpace
          DriveType   = $DriveType
        }
      }
    }
  ) *>&1 > $env:userprofile\Drive-Info.txt
}