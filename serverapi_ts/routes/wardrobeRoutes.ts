import express, { Router } from 'express'
import * as wardrobeController from '../controllers/wardrobeController'

const router: Router = express.Router()

router.get('/', wardrobeController.getWardrobe)
router.post('/', wardrobeController.saveToWardrobe)
router.delete('/:outfitId', wardrobeController.removeFromWardrobe)
router.get('/check/:outfitId', wardrobeController.checkIsSaved)

export default router
