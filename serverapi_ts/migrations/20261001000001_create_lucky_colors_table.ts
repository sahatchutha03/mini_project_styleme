exports.up = function (knex: any) {
  return knex.schema.createTable('lucky_colors', function (table: any) {
    table.increments('id').primary()
    table.integer('day_number').notNullable() // 1 = Monday, ..., 7 = Sunday
    table.string('day_of_week').notNullable() // Monday, Tuesday, ...
    table.string('day_title').notNullable() // วันจันทร์, วันอังคาร, ...
    table.string('thai_date').notNullable()
    table.string('work_color').notNullable()
    table.string('work_hex').notNullable()
    table.string('wealth_color').notNullable()
    table.string('wealth_hex').notNullable()
    table.string('love_color').notNullable()
    table.string('love_hex').notNullable()
    table.string('unlucky_color').notNullable()
    table.string('unlucky_hex').notNullable()
    table.text('advice').notNullable()
    table.timestamps(true, true)
  })
}

exports.down = function (knex: any) {
  return knex.schema.dropTable('lucky_colors')
}
