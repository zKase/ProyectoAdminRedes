const fs = require('fs');
const path = require('path');
const { Client } = require('pg');
const bcrypt = require('bcrypt');

function parseEnv(envPath) {
  const content = fs.readFileSync(envPath, 'utf8');
  const lines = content.split(/\r?\n/);
  const env = {};
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const idx = trimmed.indexOf('=');
    if (idx === -1) continue;
    const key = trimmed.slice(0, idx);
    const val = trimmed.slice(idx + 1);
    env[key] = val;
  }
  return env;
}

async function main() {
  const projectRoot = path.resolve(__dirname, '..', '..');
  const envPath = path.join(projectRoot, 'backend', '.env');
  const env = parseEnv(envPath);

  const client = new Client({
    host: env.DB_HOST || 'localhost',
    port: Number(env.DB_PORT || '5432'),
    user: env.DB_USERNAME || 'postgres',
    password: env.DB_PASSWORD || '',
    database: env.DB_NAME || 'postgres',
  });

  await client.connect();
  const res = await client.query("SELECT id, email, password, role, \"isActive\" as isActive FROM users WHERE email='admin@example.com'");
  if (res.rows.length === 0) {
    console.log('User not found');
    process.exit(1);
  }
  const u = res.rows[0];
  console.log('Found user:', { id: u.id, email: u.email, role: u.role, isActive: u.isactive });

  const passwordToCheck = 'Password123!';
  const match = await bcrypt.compare(passwordToCheck, u.password);
  console.log('Password matches:', match);

  await client.end();
}

main().catch(err => { console.error(err); process.exit(1); });
