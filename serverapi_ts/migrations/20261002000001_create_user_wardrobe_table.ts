exports.up = function (knex: any) {
  return knex.schema.createTable('user_wardrobe', function (table: any) {
    table.increments('id').primary()
    table.integer('user_id').unsigned().notNullable().references('id').inTable('users').onDelete('CASCADE')
    table.integer('outfit_id').unsigned().notNullable().references('id').inTable('outfits').onDelete('CASCADE')
    table.unique(['user_id', 'outfit_id'])
    table.timestamps(true, true)
  })
}

exports.down = function (knex: any) {
  return knex.schema.dropTableIfExists('user_wardrobe')
}
