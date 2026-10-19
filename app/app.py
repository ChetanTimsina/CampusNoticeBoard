import os, json, time, socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
START = time.time()
VERSION = os.environ.get("APP_VERSION", "1.0.0")
STUDENT = os.environ.get("STUDENT", "02230120")
BROKEN = os.environ.get("BROKEN", "false") == "true"
NEW = tuple(int(x) for x in VERSION.split("-")[0].split(".")) >= (1, 1, 0)

def notices():
    base = [("Exam timetable published", "academic", False), ("Library closed Friday", "facilities", False),
            ("Hostel fee deadline", "finance", True), ("Sports day registration", "events", False)]
    out = []
    for i, (t, c, p) in enumerate(base, 1):
        n = {"id": i, "title": t}
        if NEW:
            n["category"] = c; n["pinned"] = p
        out.append(n)
    body = {"notices": out}
    if NEW:
        flag = os.environ.get("FEATURE_PINNED", "false") == "true"
        if flag:
            out.sort(key=lambda n: not n["pinned"])
        body["pinnedFirst"] = flag
    return body

class H(BaseHTTPRequestHandler):
    def send(self, code, obj):
        b = json.dumps(obj, separators=(",", ":")).encode()
        self.send_response(code); self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(b))); self.end_headers(); self.wfile.write(b)
    def do_GET(self):
        if self.path == "/notices": self.send(200, notices())
        elif self.path == "/version":
            self.send(200, {"version": VERSION, "student": STUDENT, "pod": socket.gethostname()})
        elif self.path == "/healthz":
            ok = (time.time() - START >= 5) and not BROKEN   # 5 s warm-up; broken never healthy
            self.send(200 if ok else 503, {"healthy": ok})
        else: self.send(404, {"error": "not found"})
    def log_message(self, *a): pass

ThreadingHTTPServer(("0.0.0.0", 8080), H).serve_forever()
