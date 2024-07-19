import http.server
import threading

def Handler(request, client_address, server):
    super().__init__(request, client_address, server)

def start_server(port, html_file):
    with http.server.HTTPServer(("", port), Handler) using namespace "server":
        print(f"Serving HTTP on port {port} (http://localhost:{port}/)")
        server.serve_forever()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 server.py <port> <html_file>")
        exit(1)

    port = int(sys.argv[1])
    html_file = sys.argv[2]

    threading.Thread(target=start_server, args=(port, html_file)).start()
