#Requires -Version 5

function Group-Pictures {
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
        # Path to directory to scan for files.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ParameterSetName="Path",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to directory to scan for files.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$true,
                   Position=1,
                   ParameterSetName="Output",
                   HelpMessage="Path to destination directory.")]
        [Alias("PSDest")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Output
    )
    
    begin {
    }
    
    process {
        $TakenDate = GetTakenDate($Path)
        $TakenDate
    }
    
    end {
    }
}

$Shell = New-Object -ComObject Shell.Application

function GetTakenDate {
    # Directory
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
        [string[]]
        $Path
    )

    $Path | %{
        $p = Resolve-Path -Path $Path
        $d = $Shell.namespace((Split-Path -Path $p -Parent))
        $f = $d.ParseName((Split-Path -Path $p -Leaf))
        $s = $d.GetDetailsOf($f, 12) -replace '[\u200E-\u200F]', ''
        $d = [datetime]::ParseExact($s, 'dd/MM/yyyy HH:mm', $null)
        [psobject]@{Year = $d.Year; Month = $d.Month; Path = $p}
    }
}

Group-Pictures -Path "prueba.jpg"