import express, { Router } from 'express'
import * as authController from '../controllers/authController'

const router: Router = express.Router()

router.post('/register', authController.register)
router.post('/login', authController.login)
router.get('/profile', authController.profile)
router.put('/profile', authController.updateProfile)

export default router
