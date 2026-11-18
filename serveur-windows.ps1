# Charting Craft - petit serveur local pour Windows (aucune installation requise).
$port = 8765
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$url  = "http://localhost:$port/"
$page = $url + "charting.html"

function Open-Browser {
  try { Start-Process "chrome" $page -ErrorAction Stop; return } catch {}
  try { Start-Process "msedge" $page -ErrorAction Stop; return } catch {}
  Start-Process $page
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
try { $listener.Start() } catch {
  # Le port est deja utilise : Charting Craft tourne probablement deja.
  Open-Browser
  exit
}

Open-Browser
Write-Host ""
Write-Host "  Charting Craft est ouvert dans le navigateur : $page"
Write-Host "  Laissez cette fenetre ouverte pendant l'utilisation."
Write-Host "  Fermez-la pour arreter."
Write-Host ""

$types = @{ ".html"="text/html; charset=utf-8"; ".js"="text/javascript"; ".css"="text/css"; ".json"="application/json"; ".webmanifest"="application/manifest+json"; ".png"="image/png"; ".svg"="image/svg+xml"; ".ico"="image/x-icon" }
$rootFull = [IO.Path]::GetFullPath($root)

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if ([string]::IsNullOrEmpty($rel)) { $rel = "charting.html" }
    $file = [IO.Path]::GetFullPath((Join-Path $rootFull $rel))
    $res = $ctx.Response
    if ($file.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $file -PathType Leaf)) {
      $bytes = [IO.File]::ReadAllBytes($file)
      $ext = [IO.Path]::GetExtension($file).ToLower()
      if ($types.ContainsKey($ext)) { $res.ContentType = $types[$ext] } else { $res.ContentType = "application/octet-stream" }
      $res.Headers.Add("Cache-Control", "no-store")
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
    }
    $res.Close()
  } catch { }
}
