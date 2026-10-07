import express, { Express } from 'express'
import bodyParser from 'body-parser'
import cors from 'cors'
import dotenv from 'dotenv'

// Initialize dotenv
dotenv.config()

// Initialize App
const app: Express = express()

// Parse incoming JSON requests
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))

// Use Cors
app.use(cors())

// Use Static Files
app.use('/uploads', express.static('uploads'))
app.use('/uploads/images', express.static('uploads/images'))

import authRoutes from './routes/authRoutes'
import luckyColorRoutes from './routes/luckyColorRoutes'
import outfitRoutes from './routes/outfitRoutes'
import wardrobeRoutes from './routes/wardrobeRoutes'
import adminRoutes from './routes/adminRoutes'

// Use Routes
app.use('/api/auth', authRoutes)
app.use('/api/lucky-colors', luckyColorRoutes)
app.use('/api/outfits', outfitRoutes)
app.use('/api/wardrobe', wardrobeRoutes)
app.use('/api/admin', adminRoutes)

// Welcome root
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    message: 'StyleMe REST API Server (The Perfect Fit)',
    version: '1.0.0',
    database: process.env.DB_DATABASE || 'styleme_app',
  })
})

// Listen Port
const port: string | number = process.env.PORT || 3000
const env: string = process.env.ENV || 'development'

app.listen(port, () => {
  console.log(`=========================================`)
  console.log(` StyleMe API Server running on port ${port}`)
  console.log(` Environment: ${env}`)
  console.log(` Database: ${process.env.DB_DATABASE || 'styleme_app'}`)
  console.log(` MySQL Port: ${process.env.DB_PORT || '3307'}`)
  console.log(` Press Ctrl+C to quit.`)
  console.log(`=========================================`)
})