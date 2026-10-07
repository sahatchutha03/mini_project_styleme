import db from './knex'
import bcrypt from 'bcrypt'

async function run() {
  try {
    const hash = await bcrypt.hash('123456', 10)
    await db('users').where({ email: 'admin@styleme.com' }).update({ password: hash, role: 'admin' })
    await db('users').where({ email: 'style@me.com' }).update({ password: hash, role: 'admin' })
    await db('users').where({ email: 'test_user@gmail.com' }).update({ password: hash, role: 'user' })
    console.log('Successfully set demo accounts passwords to 123456')
    const users = await db('users').select('id', 'fullname', 'email', 'role')
    console.log('CURRENT USERS:', users)
    process.exit(0)
  } catch (err) {
    console.error(err)
    process.exit(1)
  }
}

run()
