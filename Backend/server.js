require("dotenv").config();
const express = require("express");
const { MongoClient } = require("mongodb");
const app = express();
const port = 3000;

app.get("/api/message", async (req, res) => {
  const client = new MongoClient(process.env.MONGO_URI, {
    tls: true,
    tlsCAFile: "/home/ubuntu/rds-combined-ca-bundle.pem",
  });
  try {
    await client.connect();
    const db = client.db("mydb");
    const message = await db.collection("messages").findOne({});
    res.send({ message: message?.text || "Hello from backend!" });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error connecting to DB");
  } finally {
    await client.close();
  }
});

app.get("/health", (req, res) => {
  res.status(200).send("OK");
});

app.listen(port, () => console.log(`Backend running on port ${port}`));
