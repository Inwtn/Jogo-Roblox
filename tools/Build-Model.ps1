$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root 'src'
$output = Join-Path $root 'Studio\ServerScriptService\AuroraPrototype.rbxmx'
$compatibilityOutput = Join-Path $root 'build\AuroraPrototype.rbxmx'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $output) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $compatibilityOutput) | Out-Null

$document = [System.Xml.XmlDocument]::new()
$document.PreserveWhitespace = $true
$declaration = $document.CreateXmlDeclaration('1.0', 'utf-8', $null)
$document.AppendChild($declaration) | Out-Null
$roblox = $document.CreateElement('roblox')
$roblox.SetAttribute('version', '4')
$roblox.SetAttribute('xmlns:xmime', 'http://www.w3.org/2005/05/xmlmime')
$roblox.SetAttribute('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
$roblox.SetAttribute('noNamespaceSchemaLocation', 'http://www.w3.org/2001/XMLSchema-instance', 'http://www.roblox.com/roblox.xsd') | Out-Null
$document.AppendChild($roblox) | Out-Null
$script:itemNumber = 0
foreach ($externalValue in @('null', 'nil')) {
    $external = $document.CreateElement('External')
    $external.InnerText = $externalValue
    $roblox.AppendChild($external) | Out-Null
}

function Add-TextElement($parent, [string]$tag, [string]$name, [string]$value) {
    $element = $document.CreateElement($tag)
    $element.SetAttribute('name', $name)
    if ($tag -eq 'ProtectedString') {
        $element.AppendChild($document.CreateCDataSection($value)) | Out-Null
    } else {
        $element.InnerText = $value
    }
    $parent.AppendChild($element) | Out-Null
}

function Add-Item($parent, [string]$class, [string]$name, [string]$file) {
    $item = $document.CreateElement('Item')
    $item.SetAttribute('class', $class)
    $item.SetAttribute('referent', 'RBX' + $script:itemNumber)
    $script:itemNumber += 1
    $parent.AppendChild($item) | Out-Null
    $properties = $document.CreateElement('Properties')
    $item.AppendChild($properties) | Out-Null
    Add-TextElement $properties 'string' 'Name' $name
    if ($file) {
        if ($class -eq 'Script' -or $class -eq 'LocalScript') {
            Add-TextElement $properties 'bool' 'Disabled' 'false'
        }
        $path = Join-Path $root $file
        $content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
        Add-TextElement $properties 'ProtectedString' 'Source' $content
    }
    return $item
}

$sources = @(
    @{ Class = 'ModuleScript'; Name = 'Config'; Path = 'src/ServerScriptService/AuroraPrototype/Config.luau' },
    @{ Class = 'ModuleScript'; Name = 'Art'; Path = 'src/ServerScriptService/AuroraPrototype/Art.luau' },
    @{ Class = 'ModuleScript'; Name = 'WorldBuilder'; Path = 'src/ServerScriptService/AuroraPrototype/WorldBuilder.luau' },
    @{ Class = 'ModuleScript'; Name = 'PaladinVisual'; Path = 'src/ServerScriptService/AuroraPrototype/PaladinVisual.luau' },
    @{ Class = 'ModuleScript'; Name = 'DataService'; Path = 'src/ServerScriptService/AuroraPrototype/DataService.luau' },
    @{ Class = 'ModuleScript'; Name = 'QuestService'; Path = 'src/ServerScriptService/AuroraPrototype/QuestService.luau' },
    @{ Class = 'ModuleScript'; Name = 'TestArena'; Path = 'src/ServerScriptService/AuroraPrototype/TestArena.luau' },
    @{ Class = 'ModuleScript'; Name = 'EnemyService'; Path = 'src/ServerScriptService/AuroraPrototype/EnemyService.luau' },
    @{ Class = 'LocalScript'; Name = 'Client'; Path = 'src/ServerScriptService/AuroraPrototype/Client.client.luau' },
    @{ Class = 'Script'; Name = 'Bootstrap'; Path = 'src/ServerScriptService/AuroraPrototype/Bootstrap.server.luau' }
)
$folder = Add-Item $roblox 'Folder' 'AuroraPrototype' ''
foreach ($sourceItem in $sources) {
    Add-Item $folder $sourceItem.Class $sourceItem.Name $sourceItem.Path | Out-Null
}

$settings = [System.Xml.XmlWriterSettings]::new()
$settings.Encoding = [System.Text.UTF8Encoding]::new($false)
$settings.Indent = $true
$settings.NewLineChars = "`n"
$writer = [System.Xml.XmlWriter]::Create($output, $settings)
try { $document.Save($writer) } finally { $writer.Close() }

$roundTrip = [System.Xml.XmlDocument]::new()
$roundTrip.Load($output)
$items = $roundTrip.DocumentElement.SelectNodes('./Item/Item')
if ($items.Count -ne $sources.Count) { throw 'Quantidade de scripts incorreta no pacote.' }
foreach ($sourceItem in $sources) {
    $matched = @($items | Where-Object { $_.GetAttribute('class') -eq $sourceItem.Class -and $_.SelectSingleNode('./Properties/string[@name="Name"]').InnerText -eq $sourceItem.Name })
    if ($matched.Count -ne 1) { throw "Script ausente ou duplicado: $($sourceItem.Name)" }
    $expected = [System.IO.File]::ReadAllText((Join-Path $root $sourceItem.Path), [System.Text.Encoding]::UTF8).Replace("`r`n", "`n")
    $actual = $matched[0].SelectSingleNode('./Properties/ProtectedString[@name="Source"]').InnerText
    if ($expected -cne $actual) { throw "Fonte alterada na serialização: $($sourceItem.Name)" }
}
Copy-Item -LiteralPath $output -Destination $compatibilityOutput -Force
Write-Output $output
