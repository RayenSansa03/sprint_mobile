import json
import sys

import requests

GATEWAY = "http://localhost:8081"


def fail(step: str, details: str) -> None:
    print(f"[FAIL] {step}: {details}")
    sys.exit(1)


def ok(step: str, details: str = "") -> None:
    suffix = f" -> {details}" if details else ""
    print(f"[OK] {step}{suffix}")


def get_token(payload: dict) -> str:
    return payload.get("token") or payload.get("accessToken") or payload.get("access_token") or ""


def main() -> None:
    print("=== AgriSmart E2E Gateway + Chatbot ===")

    # 1) Login -> JWT
    r = requests.post(
        f"{GATEWAY}/api/auth/login",
        json={"email": "admin@agrismart.gn", "password": "admin123"},
        timeout=12,
    )
    if r.status_code != 200:
        fail("login", f"status={r.status_code} body={r.text[:300]}")

    token = get_token(r.json())
    if not token:
        fail("login", "token absent")
    ok("login", "JWT received")

    headers = {"Authorization": f"Bearer {token}"}

    # 2) Gateway -> Backend
    r = requests.get(f"{GATEWAY}/api/users/me/debug", headers=headers, timeout=12)
    if r.status_code != 200:
        fail("gateway->backend debug", f"status={r.status_code} body={r.text[:300]}")
    ok("gateway->backend debug", "200")

    # 3) Gateway -> Chatbot auth
    r = requests.get(f"{GATEWAY}/chatbot/auth-test", headers=headers, timeout=12)
    if r.status_code != 200:
        fail("gateway->chatbot auth-test", f"status={r.status_code} body={r.text[:300]}")
    ok("gateway->chatbot auth-test", "200")

    # 4) Gateway -> Chatbot message
    body = {
        "message": "Donne-moi les prix du marche",
        "profile": "agriculteur",
        "lang": "fr",
        "session_id": "e2e-gateway-chatbot",
        "debug": True,
    }
    r = requests.post(f"{GATEWAY}/chatbot/message", headers=headers, json=body, timeout=25)
    if r.status_code != 200:
        fail("gateway->chatbot message", f"status={r.status_code} body={r.text[:300]}")

    payload = r.json()
    reply = str(payload.get("reply", "")).strip()
    if not reply:
        fail("chatbot response", "reply empty")

    intent = str(payload.get("intent", ""))
    provider = str(payload.get("provider", ""))
    ok("gateway->chatbot message", f"intent={intent} provider={provider}")

    print("=== E2E PASSED ===")
    print(json.dumps({"intent": intent, "provider": provider, "reply_preview": reply[:220]}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
