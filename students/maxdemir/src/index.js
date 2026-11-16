const http = require("http");
const { Pool } = require("pg");

const PORT = process.env.PORT || 3000;
const pool = process.env.DATABASE_URL
  ? new Pool({ connectionString: process.env.DATABASE_URL })
  : null;

const server = http.createServer(async (req, res) => {
  res.setHeader("Content-Type", "application/json");
  if (req.url === "/health") {
    return res.end(JSON.stringify({ status: "ok" }));
  }
  if (req.url === "/db") {
    if (!pool) return res.end(JSON.stringify({ db: "not configured" }));
    try {
      await pool.query("SELECT 1");
      return res.end(JSON.stringify({ db: "ok" }));
    } catch (e) {
      res.statusCode = 500;
      return res.end(JSON.stringify({ db: "error", message: e.message }));
    }
  }
  res.end(JSON.stringify({ message: "Hello from nodeapp", env: process.env.NODE_ENV || "dev" }));
});

server.listen(PORT, () => console.log(`Listening on ${PORT}`));
