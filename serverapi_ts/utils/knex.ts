import knex from 'knex'
import dotenv from 'dotenv'

dotenv.config()

const db = knex({
  client: 'mysql2',
  connection: {
    host: process.env.DB_HOST || '127.0.0.1',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    port: parseInt(process.env.DB_PORT || '3307'),
    database: process.env.DB_DATABASE || 'styleme_app',
  },
})

export default db
