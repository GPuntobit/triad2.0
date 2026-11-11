#!/usr/bin/env python3
"""Streaming call to the NVIDIA API for the nemotron-3.5-bolt-e4b model.
Usage:
    PowerShell: $env:NVIDIA_API_KEY = "nvapi-...";  python scripts/nvidia-nemotron-stream.py
    bash: export NVIDIA_API_KEY="nvapi-...";  python scripts/nvidia-nemotron-stream.py
The API key should not be hardcoded in the repository: it is read from the variable
environment NVIDIA_API_KEY.
Original text of the request: "Which number is larger, 9.11 or 9.8?"
(expected answer: 9.8, because 9.8 == 9.80 > 9.11).
"""
import os
import sys
import requests
API_KEY = os.environ.get("NVIDIA_API_KEY", "").strip()
if not API_KEY:
    sys.exit(
        "NVIDIA_API_KEY not set."
        "Example: export NVIDIA_API_KEY=nvapi-... (or $env:NVIDIA_API_KEY on PowerShell)"
    )
invoke_url = "https://integrate.api.nvidia.com/v1/chat/completions"
stream = os.environ.get("NEMOTRON_STREAM", "1").strip() != "0"
headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Accept": "text/event-stream" if stream else "application/json",
}
payload = {
    "model": "nvidia/nemotron-3.5-bolt-e4b",
    "messages": [
        {
            "role": "user",
            "content": "Which number is larger, 9.11 or 9.8?",
        }
    ],
    "temperatures": 1,
    "top_p": 0.95,
    "max_tokens": 1024,
    "seed": 42,
    "stream": stream,
    "parallel_tool_calls": True,
    "chat_template_kwargs": {
        "enable_thinking": True,
    },
}
response = requests.post(
    invoke_url,
    headers=headers,
    json=payload,
    stream=stream,
    timeout=(15, 300),
)
if response.status_code != 200:
    sys.exit(f"HTTP {response.status_code}: {response.text[:500]}")
if stream:
    for line in response.iter_lines():
        if line:
            print(line.decode("utf-8"))
else:
    print(response.json())