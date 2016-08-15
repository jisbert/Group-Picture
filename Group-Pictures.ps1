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


function GetTakenDate ($Path) {
    if (!(Test-Path -Path $Path -PathType Leaf)) {
        throw $"El archivo $Path no existe o no es un fichero"
    }
    
    $TakenDate = 12
    $Shell = New-Object -ComObject Shell.Application
    $ResolvedPath = Resolve-Path -Path $Path
    $Directory = $Shell.namespace((Split-Path -Path $ResolvedPath -Parent))
    $File = $Directory.ParseName((Split-Path -Path $ResolvedPath -Leaf))
    $DateString = $Directory.GetDetailsOf($File, $TakenDate) -replace '[\u200E-\u200F]', ''
    [datetime]::ParseExact($DateString, 'dd/MM/yyyy HH:mm', $null)
}

Group-Pictures -Path "prueba.jpg"