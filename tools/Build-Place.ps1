$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'Build-Model.ps1') | Out-Null
$document = [System.Xml.XmlDocument]::new()
$document.Load((Join-Path $root 'build/AuroraPrototype.rbxmx'))
$gameCode = $document.DocumentElement.SelectSingleNode('./Item')
$gameCode.SelectSingleNode('./Properties/string[@name="Name"]').InnerText = 'AuroraGame'

function Service([string]$class) {
    $item = $document.CreateElement('Item')
    $item.SetAttribute('class', $class)
    $item.SetAttribute('referent', 'SERVICE_' + $class)
    $properties = $document.CreateElement('Properties')
    $item.AppendChild($properties) | Out-Null
    $name = $document.CreateElement('string')
    $name.SetAttribute('name', 'Name')
    $name.InnerText = $class
    $properties.AppendChild($name) | Out-Null
    $document.DocumentElement.AppendChild($item) | Out-Null
    return $item
}
function Property($item, [string]$type, [string]$name, [string]$value) {
    $prop = $document.CreateElement($type)
    $prop.SetAttribute('name', $name)
    $prop.InnerText = $value
    $item.SelectSingleNode('./Properties').AppendChild($prop) | Out-Null
}
$workspace = Service 'Workspace'
$terrain = $document.CreateElement('Item')
$terrain.SetAttribute('class', 'Terrain')
$terrain.SetAttribute('referent', 'TERRAIN_AURORA')
$terrain.InnerXml = '<Properties><string name="Name">Terrain</string><bool name="Decoration">true</bool><float name="GrassLength">0.7</float></Properties>'
$workspace.AppendChild($terrain) | Out-Null
$server = Service 'ServerScriptService'
$server.AppendChild($gameCode) | Out-Null
$lighting = Service 'Lighting'
Property $lighting 'bool' 'GlobalShadows' 'true'
Property $lighting 'float' 'Brightness' '2.6'
Property $lighting 'float' 'ClockTime' '15.2'
Property $lighting 'token' 'Technology' '4'
$starterPlayer = Service 'StarterPlayer'
Property $starterPlayer 'float' 'CameraMinZoomDistance' '7'
Property $starterPlayer 'float' 'CameraMaxZoomDistance' '22'
Service 'ReplicatedStorage' | Out-Null
Service 'StarterGui' | Out-Null
Service 'SoundService' | Out-Null
$output = Join-Path $root 'build/IlhaDaAurora.source.rbxlx'
$settings = [System.Xml.XmlWriterSettings]::new()
$settings.Encoding = [System.Text.UTF8Encoding]::new($false)
$settings.Indent = $true
$writer = [System.Xml.XmlWriter]::Create($output, $settings)
try { $document.Save($writer) } finally { $writer.Close() }
Write-Output $output
Write-Output 'No Studio, antes de Play: require(game.ServerScriptService.AuroraGame.WorldBuilder).Build()'
Write-Output 'Salve como Studio/IlhaDaAurora.rbxl para manter o mapa editável.'
