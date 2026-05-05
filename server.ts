import express from "express";
import { createServer as createViteServer } from "vite";
import path from "path";
import { fileURLToPath } from "url";
import { initDb } from "./src/db.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json());

  // Initialize DB
  const db = await initDb();

  // API Routes
  app.get("/api/noticias", async (req, res) => {
    const noticias = await db.all("SELECT * FROM noticias ORDER BY id DESC");
    res.json(noticias);
  });

  app.post("/api/noticias", async (req, res) => {
    const { titulo, categoria, autor, data_pub, status, resumo, conteudo, img_url } = req.body;
    const result = await db.run(
      "INSERT INTO noticias (titulo, categoria, autor, data_pub, status, resumo, conteudo, img_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
      [titulo, categoria, autor, data_pub, status, resumo, conteudo, img_url]
    );
    res.json({ id: result.lastID });
  });

  app.delete("/api/noticias/:id", async (req, res) => {
    await db.run("DELETE FROM noticias WHERE id = ?", [req.params.id]);
    res.json({ success: true });
  });

  app.get("/api/obras", async (req, res) => {
    const obras = await db.all("SELECT * FROM obras ORDER BY id DESC");
    res.json(obras);
  });

  app.get("/api/licencas", async (req, res) => {
    const licencas = await db.all("SELECT * FROM licencas ORDER BY id DESC");
    res.json(licencas);
  });

  // Vite middleware for development
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(\`Server running on http://localhost:\${PORT}\`);
  });
}

startServer();
