require('ts-node/register')
import dotenv from 'dotenv'
dotenv.config()

module.exports = {
  development: {
    client: 'mysql2',
    connection: {
      host: '127.0.0.1',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      port: process.env.DB_PORT ? parseInt(process.env.DB_PORT) : 3307,
      database: process.env.DB_DATABASE || 'styleme_app'
    },
    migrations: {
      tableName: 'migrations',
      extension: 'ts',
      directory: './migrations',
    },
    seeds: {
      extension: 'ts',
      directory: './seeds',
    },
  },
}
