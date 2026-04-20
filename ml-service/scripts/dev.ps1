param(
    [string]$HostName = "0.0.0.0",
    [int]$Port = 8001
)

python -m uvicorn app.main:app --reload --host $HostName --port $Port
