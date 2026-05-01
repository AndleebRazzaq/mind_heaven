$body = @{
    text = "I feel like I’m going to fail tomorrow’s presentation. I always mess things up."
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/analyze" -Method Post -Body $body -ContentType "application/json" | ConvertTo-Json -Depth 5
