const { Client } = require("pg");

async function debugConnection() {
  const client = new Client({
    connectionString:
      "postgresql://postgres:YjxBJtgTwSlBxnSQ@db.kbeseafmtepfjatzvjnr.supabase.co:5432/postgres",
  });

  try {
    await client.connect();

    // Vérifier la connexion actuelle
    const currentDb = await client.query(
      "SELECT current_database(), current_user, version()",
    );
    console.log("🔗 Connexion actuelle:");
    console.log(`  Base de données: ${currentDb.rows[0].current_database}`);
    console.log(`  Utilisateur: ${currentDb.rows[0].current_user}`);
    console.log(`  Version: ${currentDb.rows[0].version.split(",")[0]}`);

    // Vérifier les permissions
    const permissions = await client.query(
      "SELECT has_database_privilege(current_database(), 'CREATE') as can_create",
    );
    console.log(
      `\n🔐 Permissions: ${permissions.rows[0].can_create ? "✅ Peut créer des tables" : "❌ Pas de permission CREATE"}`,
    );

    // Vérifier s'il y a eu des tentatives de création
    const recentTables = await client.query(`
      SELECT table_name, table_type 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `);

    console.log(`\n📋 Toutes les tables (${recentTables.rows.length}):`);
    recentTables.rows.forEach((row) =>
      console.log(`  - ${row.table_name} (${row.table_type})`),
    );
  } catch (error) {
    console.error("❌ Erreur:", error.message);
  } finally {
    await client.end();
  }
}

debugConnection().catch(console.error);
