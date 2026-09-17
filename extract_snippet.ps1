$content = Get-Content 'predicd_raw.html' -Raw
$idx = $content.IndexOf('matches-table')
if ($idx -ge 0) {
    $snippet = $content.Substring($idx, 5000)
    $snippet | Out-File -FilePath 'snippet.txt' -Encoding utf8
    Write-Host "Snippet saved at index $idx"
} else {
    Write-Host "matches-table NOT FOUND"
    $snippet = "NOT FOUND"
    $snippet | Out-File -FilePath 'snippet.txt' -Encoding utf8
}
