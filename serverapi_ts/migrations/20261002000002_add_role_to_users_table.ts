exports.up = async function (knex: any) {
  const hasRole = await knex.schema.hasColumn('users', 'role')
  if (!hasRole) {
    await knex.schema.alterTable('users', function (table: any) {
      table.string('role', 20).defaultTo('user').notNullable()
    })
  }
}

exports.down = async function (knex: any) {
  const hasRole = await knex.schema.hasColumn('users', 'role')
  if (hasRole) {
    await knex.schema.alterTable('users', function (table: any) {
      table.dropColumn('role')
    })
  }
}
