const { Client } = require("pg");

async function testN8nDb() {
  const client = new Client({
    connectionString:
      "postgresql://postgres:YjxBJtgTwSlBxnSQ@db.kbeseafmtepfjatzvjnr.supabase.co:5432/postgres",
  });

  try {
    await client.connect();

    // Créer une table de test pour vérifier que nous sommes sur la bonne BDD
    await client.query(`
      CREATE TABLE IF NOT EXISTS n8n_test_connection (
        id SERIAL PRIMARY KEY,
        test_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        message TEXT
      )
    `);

    // Insérer une donnée de test
    await client.query(
      `
      INSERT INTO n8n_test_connection (message) 
      VALUES ($1)
    `,
      ["Test de connexion pour n8n - " + new Date().toISOString()],
    );

    // Vérifier
    const result = await client.query(
      "SELECT * FROM n8n_test_connection ORDER BY id DESC LIMIT 1",
    );

    console.log("✅ Table de test n8n créée avec succès:");
    console.log(`  ID: ${result.rows[0].id}`);
    console.log(`  Message: ${result.rows[0].message}`);
    console.log(`  Heure: ${result.rows[0].test_time}`);

    console.log(
      "\n🎯 Si n8n utilisait cette base de données, nous verrions des tables n8n ici !",
    );
  } catch (error) {
    console.error("❌ Erreur:", error.message);
  } finally {
    await client.end();
  }
}

testN8nDb().catch(console.error);
