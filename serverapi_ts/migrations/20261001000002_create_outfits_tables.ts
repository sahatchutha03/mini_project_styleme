exports.up = async function (knex: any) {
  // 1. Outfits Table
  await knex.schema.createTable('outfits', function (table: any) {
    table.increments('id').primary()
    table.string('title').notNullable()
    table.text('description').nullable()
    table.string('image_url', 1000).notNullable()
    table.string('occasion').notNullable() // Cafe, Office, Dinner, Street, Beach
    table.string('body_shapes').notNullable() // e.g. "Pear,Hourglass,Rectangle"
    table.string('color_category').notNullable() // work, wealth, love
    table.string('color_name').notNullable()
    table.string('color_hex').notNullable()
    table.integer('match_score').defaultTo(90)
    table.timestamps(true, true)
  })

  // 2. Outfit Items Table
  await knex.schema.createTable('outfit_items', function (table: any) {
    table.increments('id').primary()
    table.integer('outfit_id').unsigned().notNullable().references('id').inTable('outfits').onDelete('CASCADE')
    table.string('category').notNullable() // Top, Bottom, Shoes, Accessory
    table.string('name').notNullable()
    table.string('color_name').notNullable()
    table.string('color_hex').notNullable()
    table.timestamps(true, true)
  })

  // 3. Styling Tips Table (Personalized Tips)
  await knex.schema.createTable('styling_tips', function (table: any) {
    table.increments('id').primary()
    table.integer('outfit_id').unsigned().notNullable().references('id').inTable('outfits').onDelete('CASCADE')
    table.string('body_shape').notNullable() // Pear, Hourglass, Apple, Rectangle, Inverted Triangle
    table.string('tip_title').notNullable()
    table.text('tip_content').notNullable()
    table.string('highlight_feature').notNullable()
    table.text('lucky_color_synergy').nullable()
    table.timestamps(true, true)
  })
}

exports.down = async function (knex: any) {
  await knex.schema.dropTableIfExists('styling_tips')
  await knex.schema.dropTableIfExists('outfit_items')
  await knex.schema.dropTableIfExists('outfits')
}
