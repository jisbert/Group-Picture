#Requires -Version 5

function Group-Picture {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        C:\PS> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>

    [CmdletBinding()]
    param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="Path",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateScript({Test-Path -Path $_ -Type Container})]
        [string]
        $InputPath,
        # Specifies a path to output location.
        [Parameter(Mandatory=$true,
                   Position=1,
                   ParameterSetName="Path",
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to output locations.")]
        [ValidateScript({!(Test-Path -Path $_)})]
        [string]
        $OutputPath
    )
    
    begin {
    }
    
    process {
        $Files = Get-ChildItem $InputPath -Recurse -File -Depth 5 -Include '*.jpg','*.JPG','*.jpeg','*.JPEG','*.png','*.PNG','*.tiff','*.TIFF'
        $Info = GetTakenDate $Files
        $Groups = $Info | Group-Object -Property {$_.Year},{$_.Month}
        $Groups | % {
            $Year = Join-Path $OutputPath $_.Values[0]
            $Month = Join-Path $Year $_.Values[1]
            New-Item -Path $Month -ItemType Directory > $null
            $Count = 0
            $_.Group | Sort-Object -Property {$_.Year},{$_.Month} | % {
                $Count++
                $Destination = Join-Path $Month ("{0:D6}" -f $Count + $_.Path.Extension)
                Copy-Item -Path $_.Path -Destination $Destination
            }
        }
    }
    
    end {
    }
}

$Shell = New-Object -ComObject Shell.Application

function GetTakenDate {
    param(
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="Path",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo[]]
        $Path
    )

    $Path | %{
        $p = Resolve-Path -Path $_
        $d = $Shell.namespace((Split-Path -Path $p -Parent))
        $f = $d.ParseName((Split-Path -Path $p -Leaf))
        $s = $d.GetDetailsOf($f, 12)

        if (!$s) {
            $s = $d.GetDetailsOf($f, 3)
        }

        if (!$s) {
            $s = $d.GetDetailsOf($f, 4)
        }

        $n = $s -replace '[\u200E-\u200F]', ''
        $d = [datetime]::ParseExact($n, 'dd/MM/yyyy H:mm', $null)
        [psobject]@{Year = $d.Year; Month = '{0:D2}' -f $d.Month; Path = $_}
    }
}
