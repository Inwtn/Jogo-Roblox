$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$placePath = Join-Path $root 'Studio\IlhaDaAurora.rbxlx'
$packagePath = Join-Path $root 'Studio\ServerScriptService\AuroraPrototype.rbxmx'
$backupPath = Join-Path $root 'build\IlhaDaAurora.pre-visual.rbxlx'
$temporaryPath = Join-Path $root 'build\IlhaDaAurora.sync.tmp.rbxlx'

& (Join-Path $PSScriptRoot 'Build-Model.ps1') | Out-Null

$place = [System.Xml.XmlDocument]::new()
$place.PreserveWhitespace = $true
$place.Load($placePath)
$package = [System.Xml.XmlDocument]::new()
$package.Load($packagePath)

function ItemName($item) {
    $name = $item.SelectSingleNode('./Properties/string[@name="Name"]')
    if ($name) { return $name.InnerText }
    return $null
}

$server = @($place.DocumentElement.SelectNodes('./Item[@class="ServerScriptService"]'))
if ($server.Count -ne 1) { throw 'ServerScriptService ausente ou duplicado no lugar.' }
$gameFolders = @($server[0].SelectNodes('./Item[@class="Folder"]') | Where-Object { (ItemName $_) -eq 'AuroraGame' })
if ($gameFolders.Count -ne 1) { throw 'AuroraGame ausente ou duplicado no lugar.' }
$gameFolder = $gameFolders[0]
$sourceFolder = $package.DocumentElement.SelectSingleNode('./Item[@class="Folder"]')
if (-not $sourceFolder) { throw 'Pacote de scripts sem pasta raiz.' }

$added = 0
$updated = 0
foreach ($sourceItem in $sourceFolder.SelectNodes('./Item')) {
    $name = ItemName $sourceItem
    $matches = @($gameFolder.SelectNodes('./Item') | Where-Object { (ItemName $_) -eq $name })
    if ($matches.Count -gt 1) { throw "Script duplicado no lugar: $name" }
    if ($matches.Count -eq 0) {
        $imported = $place.ImportNode($sourceItem, $true)
        $imported.SetAttribute('referent', 'AURORA_VISUAL_' + $name.ToUpperInvariant())
        $gameFolder.AppendChild($imported) | Out-Null
        $added += 1
    } else {
        if ($matches[0].GetAttribute('class') -ne $sourceItem.GetAttribute('class')) {
            throw "Classe diferente para $name"
        }
        $source = $sourceItem.SelectSingleNode('./Properties/ProtectedString[@name="Source"]')
        $target = $matches[0].SelectSingleNode('./Properties/ProtectedString[@name="Source"]')
        if (-not $source -or -not $target) { throw "Source ausente: $name" }
        $target.RemoveAll()
        $target.SetAttribute('name', 'Source')
        $target.AppendChild($place.CreateCDataSection($source.InnerText)) | Out-Null
        $updated += 1
    }
}

Copy-Item -LiteralPath $placePath -Destination $backupPath -Force
$settings = [System.Xml.XmlWriterSettings]::new()
$settings.Encoding = [System.Text.UTF8Encoding]::new($false)
$settings.Indent = $false
$writer = [System.Xml.XmlWriter]::Create($temporaryPath, $settings)
try { $place.Save($writer) } finally { $writer.Close() }

$check = [System.Xml.XmlDocument]::new()
$check.Load($temporaryPath)
$checkServer = $check.DocumentElement.SelectSingleNode('./Item[@class="ServerScriptService"]')
$checkFolder = @($checkServer.SelectNodes('./Item[@class="Folder"]') | Where-Object { (ItemName $_) -eq 'AuroraGame' })
if ($checkFolder.Count -ne 1) { throw 'Verificação falhou: AuroraGame ausente.' }
foreach ($sourceItem in $sourceFolder.SelectNodes('./Item')) {
    $name = ItemName $sourceItem
    $matching = @($checkFolder[0].SelectNodes('./Item') | Where-Object { (ItemName $_) -eq $name })
    if ($matching.Count -ne 1) { throw "Verificação falhou: $name ausente ou duplicado." }
    $expected = $sourceItem.SelectSingleNode('./Properties/ProtectedString[@name="Source"]').InnerText
    $actual = $matching[0].SelectSingleNode('./Properties/ProtectedString[@name="Source"]').InnerText
    if ($expected -cne $actual) { throw "Verificação falhou: Source alterado para $name." }
}

Move-Item -LiteralPath $temporaryPath -Destination $placePath -Force
Write-Output "Scripts sincronizados: $updated atualizados, $added adicionados."
Write-Output "Cópia anterior: $backupPath"
