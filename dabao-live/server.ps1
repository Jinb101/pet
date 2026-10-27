$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://127.0.0.1:8642/')
$listener.Start()
$root = 'D:\IDEA\dsh\dabao-live'
$mime = @{ '.html'='text/html; charset=utf-8'; '.png'='image/png'; '.jpg'='image/jpeg'; '.js'='text/javascript'; '.css'='text/css' }
Write-Output 'serving at http://127.0.0.1:8642'
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $p = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
  if ($p -eq '/') { $p = '/index.html' }
  $file = Join-Path $root $p
  if (Test-Path $file -PathType Leaf) {
    $ext = [System.IO.Path]::GetExtension($file).ToLower()
    $type = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
    $data = [System.IO.File]::ReadAllBytes($file)
    $ctx.Response.ContentType = $type
    $ctx.Response.ContentLength64 = $data.Length
    $ctx.Response.OutputStream.Write($data, 0, $data.Length)
  } else {
    $ctx.Response.StatusCode = 404
  }
  $ctx.Response.Close()
}
