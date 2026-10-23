import urllib.request
import urllib.error
import json
import time

BASE_URL = "https://kuta-learning.onrender.com/api"

def check_server():
    print(f"🔍 Checking Kuta Learning Server at: {BASE_URL}")
    print("-" * 55)

    # 1. Check Root Endpoint
    start_time = time.time()
    try:
        req = urllib.request.Request(
            f"{BASE_URL}",
            headers={"User-Agent": "KutaHealthCheck/1.0", "Accept": "application/json"}
        )
        with urllib.request.urlopen(req, timeout=30) as response:
            latency = (time.time() - start_time) * 1000
            print(f"✅ Root API Status: {response.status} OK (Response Time: {latency:.0f} ms)")
    except urllib.error.HTTPError as e:
        latency = (time.time() - start_time) * 1000
        # Express returns 404 for GET /api when no index route is defined, which proves the server is ALIVE!
        if e.code in (404, 200):
            print(f"✅ Server is ONLINE (Express on Render is awake) — Latency: {latency:.0f} ms")
        else:
            print(f"⚠️ Server returned HTTP {e.code} ({e.reason}) — Latency: {latency:.0f} ms")
    except urllib.error.URLError as e:
        print(f"❌ Server is UNREACHABLE: {e.reason}")
        print("💡 Note: Render free-tier instances sleep after 15 mins of inactivity. It may take 30-50s to wake up.")
        return False
    except TimeoutError:
        print("❌ Request TIMED OUT (Server is likely waking up from sleep, retry in 30 seconds)")
        return False

    # 2. Check Auth Endpoint with a sample POST probe
    print("\n🔐 Probing Auth API (POST /auth/login)...")
    auth_url = f"{BASE_URL}/auth/login"
    payload = json.dumps({"email": "ping_check@kuta.com", "password": "dummy_password"}).encode("utf-8")
    
    start_auth = time.time()
    try:
        req = urllib.request.Request(
            auth_url,
            data=payload,
            headers={
                "Content-Type": "application/json",
                "Accept": "application/json",
                "User-Agent": "KutaHealthCheck/1.0"
            },
            method="POST"
        )
        with urllib.request.urlopen(req, timeout=30) as response:
            auth_latency = (time.time() - start_auth) * 1000
            print(f"✅ Auth API Status: HTTP {response.status} (Latency: {auth_latency:.0f} ms)")
    except urllib.error.HTTPError as e:
        auth_latency = (time.time() - start_auth) * 1000
        # A 401 response with 'Invalid credentials' proves the database & auth logic are fully running!
        error_body = e.read().decode("utf-8", errors="ignore")
        if e.code == 401:
            print(f"✅ Auth API is FULLY OPERATIONAL! (HTTP 401 expected for dummy test, Latency: {auth_latency:.0f} ms)")
            print(f"   Server Response: {error_body}")
        else:
            print(f"⚠️ Auth API returned HTTP {e.code}: {error_body}")
    except Exception as e:
        print(f"❌ Auth API probe failed: {e}")

    print("-" * 55)
    print("🚀 All systems checked!")
    return True

if __name__ == "__main__":
    check_server()
