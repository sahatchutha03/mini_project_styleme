import express, { Router } from 'express'
import * as outfitController from '../controllers/outfitController'
import authenticateToken, { requireAdmin } from '../middleware/authMiddleware'

const router: Router = express.Router()

// Public Endpoints
router.get('/', outfitController.getMatchedOutfits)
router.get('/:id', outfitController.getOutfitDetail)

// Admin Protected Endpoints (เพิ่ม ลบ แก้ไข เสื้อผ้า)
router.post('/', authenticateToken, requireAdmin, outfitController.createOutfit)
router.put('/:id', authenticateToken, requireAdmin, outfitController.updateOutfit)
router.delete('/:id', authenticateToken, requireAdmin, outfitController.deleteOutfit)

export default router
