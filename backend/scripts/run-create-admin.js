const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

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
  const sqlPath = path.join(projectRoot, 'backend', 'scripts', 'create-admin.sql');

  if (!fs.existsSync(sqlPath)) {
    console.error('SQL file not found:', sqlPath);
    process.exit(1);
  }

  const env = parseEnv(envPath);
  const host = env.DB_HOST || 'localhost';
  const port = Number(env.DB_PORT || '5432');
  const user = env.DB_USERNAME || 'postgres';
  const password = env.DB_PASSWORD || '';
  const database = env.DB_NAME || 'postgres';

  const sql = fs.readFileSync(sqlPath, 'utf8');

  const client = new Client({ host, port, user, password, database });

  try {
    await client.connect();
    console.log('Connected to DB', host, database);
    await client.query('BEGIN');
    await client.query(sql);
    await client.query('COMMIT');
    console.log('Admin user inserted successfully.');
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    console.error('Failed to insert admin user:', err.message || err);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}

main();
