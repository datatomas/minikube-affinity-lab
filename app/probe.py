import os
import time
import requests
import sys

URL           = os.getenv("PROBE_URL", "http://example.com")
INTERVAL      = int(os.getenv("PROBE_INTERVAL", "5"))
MAX_ATTEMPTS  = int(os.getenv("MAX_ATTEMPTS", "10"))   # 0 = infinite
FAIL_AFTER    = int(os.getenv("FAIL_AFTER", "0"))      # simulate failure at attempt N (0=never)

attempt = 0

while True:
    attempt += 1

    # Simulate forced failure at attempt N (for testing K8s restart behavior)
    if FAIL_AFTER > 0 and attempt == FAIL_AFTER:
        print(f"[SIMULATED FAIL] attempt={attempt} forcing exit code 1", flush=True)
        sys.exit(1)   # K8s sees this and restarts the pod

    try:
        r = requests.get(URL, timeout=3)

        if r.status_code >= 400:   # treat 4xx/5xx as failure too
            print(f"[FAIL] {URL} status={r.status_code} attempt={attempt}/{MAX_ATTEMPTS}", flush=True)
        else:
            print(f"[OK] {URL} status={r.status_code} attempt={attempt}/{MAX_ATTEMPTS}", flush=True)

    except Exception as e:
        print(f"[FAIL] {URL} error={e} attempt={attempt}/{MAX_ATTEMPTS}", flush=True)

    # Stop after MAX_ATTEMPTS if set
    if MAX_ATTEMPTS > 0 and attempt >= MAX_ATTEMPTS:
        print(f"[DONE] Reached max attempts ({MAX_ATTEMPTS}), exiting.", flush=True)
        sys.exit(0)

    time.sleep(INTERVAL)
