[cmdletbinding()]
param([string]$targetBinary, [string]$installedDir, [string]$tlogFile)

function resolve($targetBinary) {
    $targetBinaryPath = Resolve-Path $targetBinary
    $targetBinaryDir = Split-Path $targetBinaryPath -parent

    $a = $(link /dump /imports $targetBinary | ? { $_ -match "^    [^ ].*\.dll" } | % { $_ -replace "^    ","" })
    $a | % {
        if (Test-Path "$installedDir\$_") {
            if (Test-Path "$targetBinaryDir\$_") {
                Write-Verbose "$_ is already present"
            }
            else {
                Copy-Item $installedDir\$_ $targetBinaryDir
                Write-Verbose "Copying $installedDir\$_ -> $_"
            }
            "$targetBinaryDir\$_"
            if ($tlogFile) { Add-Content $tlogFile "$targetBinaryDir\$_" }
            resolve("$targetBinaryDir\$_")
        } else {
            Write-Verbose "$installedDir\$_ not found"
        }
    }
}

resolve($targetBinary)