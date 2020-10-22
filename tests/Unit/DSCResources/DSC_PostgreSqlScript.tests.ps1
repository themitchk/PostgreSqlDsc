[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param()

$script:dscModuleName   = 'PostgreSqlDsc'
$script:dscResourceName = 'DSC_PostgreSqlScript'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        $moduleResourceName = 'PostgreSqlDsc - DSC_PostgreSqlScript'

        $serviceCredeDomain = New-Object `
        -TypeName System.Management.Automation.PSCredential `
            -ArgumentList 'contoso\testaccount', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force)

        $serviceCredBuiltin = New-Object `
        -TypeName System.Management.Automation.PSCredential `
        -ArgumentList 'NT AUTHORITY\NetworkService', (ConvertTo-SecureString 'doesntmatter' -AsPlainText -Force)

        $superAccountCred = New-Object `
        -TypeName System.Management.Automation.PSCredential `
        -ArgumentList 'postgresqlAdmin', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force)

        $scriptParams = @{
            DatabaseName     = 'testdb'
            SetFilePath      = "C:\test.sql"
            GetFilePath      = "C:\test.sql"
            TestFilePath     = "C:\test.sql"
            Credential       = $superAccountCred
            PsqlLocation     = "C:\Program Files\PostgreSQL\12\bin\psql.exe"
        }

        Describe "$moduleResourceName\Get-TargetResource" {
            Context 'When Get-TargetResource runs successfully' {
                It 'Should invoke psql and return expected results' {
                    Mock Invoke-Command {return "<Script Output Sample>"}

                    $dscResult = Get-TargetResource @scriptParams

                    Assert-MockCalled Invoke-Command -Exactly -Times 1 -Scope It

                    $dscResult.DatabaseName | Should -Be $scriptParams.DatabaseName
                    $dscResult.SetFilePath | Should -Be "C:\test.sql"
                    $dscResult.GetFilePath | Should -Be "C:\test.sql"
                    $dscResult.TestFilePath | Should -Be "C:\test.sql"
                    $dscResult.GetResult | Should -Be "<Script Output Sample>"
                }
            }

            Context 'When Get-TargetResource fails' {
                It 'Should return a null result when psql is not found' {
                    $invalidParams = $scriptParams.Clone()
                    $invalidParams.PsqlLocation = "does-not-exist.exe"

                    $dscResult = Get-TargetResource @invalidParams
                    $dscResult.DatabaseName | Should -Be $invalidParams.DatabaseName
                    $dscResult.GetResult | Should -Be $null
                }
            }
        }


        Describe "$moduleResourceName\Set-TargetResource" -Tag 'Set'{
            Context 'When Set-TargetResource runs successfully' {
                It 'Should invoke psql ' {
                    Mock -CommandName Invoke-Command -MockWith {}

                    Set-TargetResource @scriptParams
                    Assert-MockCalled Invoke-Command -Exactly -Times 1 -Scope It
                }

                It 'Should call default psql directory' {
                    $noPsqlParam = $scriptParams.Clone()
                    $noPsqlParam.PsqlLocation = $null
                    Mock -CommandName Invoke-Command -MockWith {}

                    Set-TargetResource @scriptParams
                    Assert-MockCalled Invoke-Command -Exactly -Times 1 -Scope It
                }
            }

            Context 'When Set-TargetResource fails' {
                BeforeEach {
                    $invalidParams = $scriptParams.Clone()
                }
                It 'Should throw when psql is not found' {
                    $invalidParams.PsqlLocation = "Z:\does-not-exist.exe"

                    {Set-TargetResource @invalidParams } | Should throw
                }

                It 'Should throw when database does not exist' {
                    $invalidParams.DatabaseName = "Z:\does-not-exist.exe"

                    {Set-TargetResource @invalidParams } | Should throw
                }

                It 'Should throw when SetScript is not found' {
                    $invalidParams.SetScript = "Z:\does-not-exist.sql"

                    {Set-TargetResource @invalidParams } | Should throw
                }
            }
        }

        Describe "$moduleResourceName\Test-TargetResource" {
            Context 'When running Test-TargetResource successfully' {
                It 'Should return True when script returns "true"' {
                    Mock Invoke-Command {return "true"}

                    Test-TargetResource @scriptParams | Should -Be $true
                    Assert-MockCalled Invoke-Command -Exactly -Times 1 -Scope It
                }

                It 'Should return False when script returns ""' {
                    Mock Invoke-Command {return ""}

                    Test-TargetResource @scriptParams | Should -Be $false
                    Assert-MockCalled Invoke-Command -Exactly -Times 1 -Scope It
                }

                it 'Should return False when script returns $null' {
                    Mock Invoke-Command {return $null}

                    Test-TargetResource @scriptParams | Should -Be $false
                    Assert-MockCalled Invoke-Command -Exactly -Times 1 -Scope It
                }

                it 'Should return False when script returns "False"' {
                    Mock Invoke-Command {return "False"}

                    Test-TargetResource @scriptParams | Should -Be $false
                    Assert-MockCalled Invoke-Command -Exactly -Times 1 -Scope It
                }
            }

            Context 'When running Test-TargetResource fails' {
                BeforeEach {
                    $invalidParams = $scriptParams.Clone()
                }

                It 'Should return false when psql is not found' {
                    $invalidParams.PsqlLocation = "Z:\does-not-exist.exe"

                    Test-TargetResource @invalidParams | Should -Be $false
                }

                It 'Should return false when invalid scirpt path is passed' {
                    $invalidParams.TestFilePath = "Z:\does-not-exist.sql"

                    Test-TargetResource @invalidParams | Should -Be $false
                }
            }
        }
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
