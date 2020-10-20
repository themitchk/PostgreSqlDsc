<#
    .SYNOPSIS
        Returns the current state of what the Get-script returns.
    .PARAMETER DatabaseName
        Specifies the name of the PostgreSQL database.
    .PARAMETER SetFilePath
        Path to the T-SQL file that will perform Set action.
    .PARAMETER GetFilePath
        Path to the T-SQL file that will perform Get action.
        Any values returned by the T-SQL queries will also be returned by the cmdlet Get-DscConfiguration through the `GetResult` property.
    .PARAMETER TestFilePath
        Path to the T-SQL file that will perform Test action.
        Any script that does not throw an error or returns null is evaluated to true.
        The cmdlet Invoke-Sqlcmd treats T-SQL Print statements as verbose text, and will not cause the test to return false.
    .PARAMETER Credential
        The credentials to authenticate with, using PostgreSQL Authentication.
    .PARAMETER PsqlLocation
        Location of the psql executable.  Defaults to "C:\Program Files\PostgreSQL\12\bin\psql.exe"
    .OUTPUTS
        Hash table containing key 'GetResult' which holds the value of the result from the SQL script that was ran from the parameter 'GetFilePath'.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TestFilePath,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter]
        [System.String]
        $PsqlLocation = "C:\Program Files\PostgreSQL\12\bin\psql.exe"
    )

    $env:PGPASSWORD = $Credential.Password.ToString()
    $env:PGUSER = $Credential.UserName
    # Call psql w/ script file
    $getResult = & $PsqlLocation -d $DatabaseName -f $GetFilePath

    $returnValue = @{
        DatabaseName     = [System.String] $DatabaseName
        SetFilePath      = [System.String] $SetFilePath
        GetFilePath      = [System.String] $GetFilePath
        TestFilePath     = [System.String] $TestFilePath
        Credential       = [System.Object] $Credential
        GetResult        = [System.String[]] $getResult
    }

    return $returnValue
}


<#
    .SYNOPSIS
        Executes the set-script.
    .PARAMETER DatabaseName
        Specifies the name of the PostgreSQL database.
    .PARAMETER SetFilePath
        Path to the T-SQL file that will perform Set action.
    .PARAMETER GetFilePath
        Path to the T-SQL file that will perform Get action.
        Any values returned by the T-SQL queries will also be returned by the cmdlet Get-DscConfiguration through the `GetResult` property.
    .PARAMETER TestFilePath
        Path to the T-SQL file that will perform Test action.
        Any script that does not throw an error or returns null is evaluated to true.
        The cmdlet Invoke-Sqlcmd treats T-SQL Print statements as verbose text, and will not cause the test to return false.
    .PARAMETER Credential
        The credentials to authenticate with, using PostgreSQL Authentication.
    .PARAMETER PsqlLocation
        Location of the psql executable.  Defaults to "C:\Program Files\PostgreSQL\12\bin\psql.exe".
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TestFilePath,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter]
        [System.String]
        $PsqlLocation = "C:\Program Files\PostgreSQL\12\bin\psql.exe"
    )

    $env:PGPASSWORD = $Credential.Password.ToString()
    $env:PGUSER = $Credential.UserName
    # Call psql w/ script file
    $getResult = & $PsqlLocation -d $DatabaseName -f $SetFilePath
}

<#
    .SYNOPSIS
        Evaluates the value returned from the Test-script.
    .PARAMETER DatabaseName
        Specifies the name of the PostgreSQL database.
    .PARAMETER SetFilePath
        Path to the T-SQL file that will perform Set action.
    .PARAMETER GetFilePath
        Path to the T-SQL file that will perform Get action.
        Any values returned by the T-SQL queries will also be returned by the cmdlet Get-DscConfiguration through the `GetResult` property.
    .PARAMETER TestFilePath
        Path to the T-SQL file that will perform Test action.
        Any script that does not throw an error or returns null is evaluated to true.
        The cmdlet Invoke-Sqlcmd treats T-SQL Print statements as verbose text, and will not cause the test to return false.
    .PARAMETER Credential
        The credentials to authenticate with, using PostgreSQL Authentication.
    .PARAMETER PsqlLocation
        Location of the psql executable.  Defaults to "C:\Program Files\PostgreSQL\12\bin\psql.exe".
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GetFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TestFilePath,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter]
        [System.String]
        $PsqlLocation = "C:\Program Files\PostgreSQL\12\bin\psql.exe"
    )

    # Need to figure out how to parse for errors here.  Does psql have a return code
    [bool]$result = & $PsqlLocation -d $DatabaseName -f $TestFilePath
}
