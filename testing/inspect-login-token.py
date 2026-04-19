import json
import urllib.request

import jwt

LOGIN_URL = "http://localhost:8081/api/auth/login"
CANDIDATE_SECRETS = [
    "test-secret-key-minimum-32-characters-required-for-jwt!!",
    "dev-only-change-me-please-32-chars",
    "test-secret-key-minimum-32-characters-required-for-jwt",
]

payload = json.dumps({"email": "admin@agrismart.gn", "password": "admin123"}).encode("utf-8")
req = urllib.request.Request(
    LOGIN_URL,
    data=payload,
    method="POST",
    headers={"Content-Type": "application/json"},
)
with urllib.request.urlopen(req, timeout=10) as resp:
    data = json.loads(resp.read().decode("utf-8"))

raw_token = data.get("token") or data.get("accessToken") or data.get("access_token")
print("token_len", len(raw_token or ""))

for s in CANDIDATE_SECRETS:
    try:
        claims = jwt.decode(raw_token, s, algorithms=["HS256"])
        print("secret_ok", repr(s), claims)
    except Exception as exc:
        print("secret_fail", repr(s), str(exc))
