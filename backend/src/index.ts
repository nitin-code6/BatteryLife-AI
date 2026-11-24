import express from "express";
import cors from "cors";
import mongoose from "mongoose";
import type { NextFunction, Request, Response } from "express";
import { config } from "./config.js";
import { authRouter } from "./routes/auth.js";
import { datasetsRouter } from "./routes/datasets.js";
import { modelRouter } from "./routes/model.js";
import { analysisRouter } from "./routes/analysis.js";

async function bootstrap(): Promise<void> {
  const app = express();
  app.use(cors());
  app.use(express.json({ limit: "10mb" }));

  app.get("/healthz", (_req: Request, res: Response) => {
    const isDbConnected = mongoose.connection.readyState === 1;
    res.json({
      status: "ok",
      database: isDbConnected ? "connected" : "disconnected"
    });
  });

  app.use("/auth", authRouter);
  app.use("/datasets", datasetsRouter);
  app.use("/model", modelRouter);
  app.use("/analysis", analysisRouter);

  app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
    const message = err instanceof Error ? err.message : "Internal server error";
    res.status(500).json({ message });
  });

  app.listen(config.port, () => {
    console.log(`Backend running on port ${config.port}`);
  });

  // Connect to MongoDB asynchronously so the API gateway boots without hard-blocking
  try {
    await mongoose.connect(config.mongoUri, {
      serverSelectionTimeoutMS: 5000,
      connectTimeoutMS: 10000,
      socketTimeoutMS: 30000,
      maxPoolSize: 50,
      minPoolSize: 10,
      maxIdleTimeMS: 300000
    } as any);
    console.log("Connected to MongoDB successfully");
  } catch (dbError: any) {
    console.warn("MongoDB not reachable yet (will reconnect when available):", dbError.message);
  }
}

bootstrap().catch((error) => {
  console.error("Failed to start backend", error);
  process.exit(1);
});
