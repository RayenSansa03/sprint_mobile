import json
import time
import urllib.error
import urllib.request

import jwt

CHATBOT_BASE = "http://localhost:5005"
JWT_SECRET = "test-secret-key-minimum-32-characters-required-for-jwt!!"


def http_json(url: str, method: str = "GET", headers=None, payload=None, timeout: int = 20):
    headers = headers or {}
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers = {**headers, "Content-Type": "application/json"}
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read().decode("utf-8", errors="ignore")
            parsed = json.loads(body) if body else None
            return {"ok": True, "status": resp.status, "data": parsed}
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="ignore")
        parsed = None
        try:
            parsed = json.loads(body)
        except Exception:
            parsed = body
        return {"ok": False, "status": exc.code, "error": parsed}


def http_binary(url: str, headers=None, payload=None, timeout: int = 30):
    headers = headers or {}
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers = {**headers, "Content-Type": "application/json"}
    req = urllib.request.Request(url, data=data, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            body = resp.read()
            return {
                "ok": True,
                "status": resp.status,
                "content_type": resp.headers.get("Content-Type", ""),
                "bytes": len(body),
                "body": body,
            }
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="ignore")
        parsed = None
        try:
            parsed = json.loads(body)
        except Exception:
            parsed = body
        return {"ok": False, "status": exc.code, "error": parsed}


def short(text: str, n: int = 220) -> str:
    if not text:
        return ""
    return text if len(text) <= n else text[:n] + "..."


payload = {
    "sub": "qa-admin",
    "role": "ADMIN",
    "token_type": "access",
    "exp": int(time.time()) + 3600,
}
token = jwt.encode(payload, JWT_SECRET, algorithm="HS256")
auth = {"Authorization": f"Bearer {token}"}

report = {}

report["auth_without_token"] = http_json(f"{CHATBOT_BASE}/api/chatbot/auth-test")
report["auth_with_token"] = http_json(
    f"{CHATBOT_BASE}/api/chatbot/auth-test", headers=auth
)

tests = [
    ("rag_tomates", "Quand planter les tomates ?", "agriculteur", "qa-rag-1"),
    (
        "rag_maladie_feuilles",
        "Comment traiter une maladie des feuilles ?",
        "agriculteur",
        "qa-rag-2",
    ),
    ("profile_agriculteur", "Je suis quel type d'utilisateur ?", "agriculteur", "qa-pa"),
    ("profile_admin", "Je suis quel type d'utilisateur ?", "admin", "qa-padmin"),
    ("profile_cooperative", "Je suis quel type d'utilisateur ?", "cooperative", "qa-pcoop"),
    ("profile_ong", "Je suis quel type d'utilisateur ?", "ong", "qa-pong"),
    ("tool_market", "Donne-moi les prix du marché", "agriculteur", "qa-tool"),
]

chat_results = {}
for key, message, profile, sid in tests:
    resp = http_json(
        f"{CHATBOT_BASE}/api/chatbot/message",
        method="POST",
        headers=auth,
        payload={
            "message": message,
            "profile": profile,
            "lang": "fr",
            "session_id": sid,
            "debug": True,
        },
    )
    if resp["ok"]:
        data = resp["data"] or {}
        chat_results[key] = {
            "ok": True,
            "status": resp["status"],
            "profile": data.get("profile"),
            "intent": data.get("intent"),
            "provider": data.get("provider"),
            "confidence": data.get("confidence"),
            "sources_count": len(data.get("sources", []) or []),
            "debug_retrieved_docs": len((data.get("debug") or {}).get("retrieved_docs", []) or []),
            "reply_preview": short(str(data.get("reply", ""))),
        }
    else:
        chat_results[key] = resp

report["chatbot"] = chat_results

mem1 = http_json(
    f"{CHATBOT_BASE}/api/chatbot/message",
    method="POST",
    headers=auth,
    payload={
        "message": "Je vends du maïs.",
        "profile": "agriculteur",
        "lang": "fr",
        "session_id": "qa-memory-1",
        "debug": True,
    },
)
mem2 = http_json(
    f"{CHATBOT_BASE}/api/chatbot/message",
    method="POST",
    headers=auth,
    payload={
        "message": "Donne-moi maintenant des conseils pour améliorer mes ventes.",
        "profile": "agriculteur",
        "lang": "fr",
        "session_id": "qa-memory-1",
        "debug": True,
    },
)
report["memory"] = {
    "step1_ok": mem1["ok"],
    "step2_ok": mem2["ok"],
    "step1_reply": short(str((mem1.get("data") or {}).get("reply", "")), 180),
    "step2_reply": short(str((mem2.get("data") or {}).get("reply", "")), 220),
    "step2_mentions_context": (
        "mais" in str((mem2.get("data") or {}).get("reply", "")).lower()
        or "vente" in str((mem2.get("data") or {}).get("reply", "")).lower()
        or "vendre" in str((mem2.get("data") or {}).get("reply", "")).lower()
    ),
}

tts = http_binary(
    f"{CHATBOT_BASE}/api/chatbot/tts",
    headers=auth,
    payload={"text": "Bonjour test audio AgriSmart", "lang": "fr"},
)
if tts["ok"]:
    with open("testing/qa_tts_test.mp3", "wb") as f:
        f.write(tts["body"])
    report["tts"] = {
        "ok": True,
        "status": tts["status"],
        "content_type": tts["content_type"],
        "bytes": tts["bytes"],
        "file": "testing/qa_tts_test.mp3",
    }
else:
    report["tts"] = tts

print(json.dumps(report, ensure_ascii=False, indent=2))
