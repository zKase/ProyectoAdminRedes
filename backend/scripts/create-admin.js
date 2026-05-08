const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');

async function main() {
  const id = uuidv4();
  const firstName = 'Admin';
  const lastName = 'User';
  const email = 'admin@example.com';
  const passwordPlain = 'Password123!';
  const role = 'ADMIN';
  const isActive = true;

  const hashed = await bcrypt.hash(passwordPlain, 10);

  const sql = `-- Generated INSERT for admin user\nINSERT INTO users (id, \"firstName\", \"lastName\", email, password, role, \"isActive\", \"createdAt\", \"updatedAt\") VALUES ('${id}', '${firstName}', '${lastName}', '${email}', '${hashed}', '${role}', ${isActive}, now(), now());\n`;

  fs.writeFileSync('backend/scripts/create-admin.sql', sql);
  console.log('Wrote backend/scripts/create-admin.sql');
  console.log('Credentials:');
  console.log(`  email: ${email}`);
  console.log(`  password: ${passwordPlain}`);
  console.log('Run the SQL against your Postgres database.');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
