exports.up = function (knex: any) {
  return knex.schema.createTable('users', function (table: any) {
    table.increments('id').primary()
    table.string('fullname').notNullable()
    table.string('email').notNullable().unique()
    table.string('password').notNullable()
    table.string('body_shape').defaultTo('Pear')
    table.string('avatar').nullable()
    table.timestamps(true, true)
  })
}

exports.down = function (knex: any) {
  return knex.schema.dropTable('users')
}