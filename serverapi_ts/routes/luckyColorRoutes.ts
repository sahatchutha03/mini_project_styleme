import express, { Router } from 'express'
import * as luckyColorController from '../controllers/luckyColorController'

const router: Router = express.Router()

router.get('/today', luckyColorController.getToday)
router.get('/', luckyColorController.getAll)

export default router
