import time
import urllib.request
import urllib.error

import jwt

URL = "http://localhost:5005/api/chatbot/auth-test"
SECRETS = [
    "test-secret-key-minimum-32-characters-required-for-jwt!!",
    "dev-only-change-me-please-32-chars",
    "test-secret-key-minimum-32-characters-required-for-jwt!! ",
]

for secret in SECRETS:
    payload = {
        "sub": "qa-admin",
        "role": "ADMIN",
        "token_type": "access",
        "exp": int(time.time()) + 3600,
    }
    token = jwt.encode(payload, secret, algorithm="HS256")
    req = urllib.request.Request(URL, headers={"Authorization": f"Bearer {token}"})

    try:
        with urllib.request.urlopen(req, timeout=8) as resp:
            body = resp.read().decode("utf-8", errors="ignore")
            print(f"secret={secret!r}")
            print(f"status={resp.status}")
            print(f"body={body[:220]}")
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="ignore")
        print(f"secret={secret!r}")
        print(f"status={exc.code}")
        print(f"body={body[:220]}")
