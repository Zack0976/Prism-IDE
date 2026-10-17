const Map<String, String> codeFiles = {
  'main.ts': '''// Prism IDE — Example Project
// TypeScript · Entry Point

import { createServer } from "http";
import { AuthService } from "./auth/service";
import { Database } from "./db/connection";

const PORT = process.env.PORT ?? 3000;

async function bootstrap() {
  const db = await Database.connect({
    host: "localhost",
    port: 5432,
    name: "prism_db",
  });

  const auth = new AuthService(db);
  const server = createServer(auth.handler());

  server.listen(PORT, () => {
    console.log(\`🚀 Server on port \${PORT}\`);
  });
}

bootstrap().catch(console.error);''',

  'auth/service.ts': '''import { sign, verify } from "jsonwebtoken";
import type { User, TokenPayload } from "./types";

const SECRET = process.env.JWT_SECRET!;
const EXPIRES = "7d";

export class AuthService {
  constructor(private db: Database) {}

  async login(
    email: string,
    password: string
  ): Promise<string> {
    const user = await this.db.users
      .findByEmail(email);

    if (!user || !await user.verify(password)) {
      throw new Error("Invalid credentials");
    }

    return this.issueToken(user);
  }

  async validateToken(token: string) {
    try {
      return verify(token, SECRET) as TokenPayload;
    } catch {
      throw new Error("Token expired or invalid");
    }
  }

  private issueToken(user: User): string {
    const payload: TokenPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      iat: Date.now(),
    };
    return sign(payload, SECRET, {
      expiresIn: EXPIRES,
    });
  }
}''',

  'db/connection.ts': '''import { Pool } from "pg";

interface DBConfig {
  host: string;
  port: number;
  name: string;
}

export class Database {
  private pool: Pool;

  private constructor(config: DBConfig) {
    this.pool = new Pool({
      host: config.host,
      port: config.port,
      database: config.name,
      max: 20,
    });
  }

  static async connect(
    config: DBConfig
  ): Promise<Database> {
    const db = new Database(config);
    await db.pool.query("SELECT 1");
    console.log("✅ Database connected");
    return db;
  }

  get users() {
    return new UserRepository(this.pool);
  }

  async close() {
    await this.pool.end();
  }
}''',

  'README.md': '''# Prism IDE — Demo Project

Editor de código minimalista e rápido.
Construído com Rust + Flutter.

## Stack

- Runtime: Node.js 20+
- Language: TypeScript 5.x
- Database: PostgreSQL 15
- Auth: JWT

## Iniciar

  npm install
  npm run dev

## Licença

Apache 2.0''',
};
