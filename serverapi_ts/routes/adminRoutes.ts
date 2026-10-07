import express, { Router } from 'express'
import * as adminController from '../controllers/adminController'
import authenticateToken, { requireAdmin } from '../middleware/authMiddleware'

const router: Router = express.Router()

// All routes in adminRoutes require JWT Auth and Admin role
router.use(authenticateToken)
router.use(requireAdmin)

// Dashboard Stats & System Health
router.get('/stats', adminController.getDashboardStats)

// User Management
router.get('/users', adminController.getAllUsers)
router.put('/users/:id/role', adminController.updateUserRole)
router.delete('/users/:id', adminController.deleteUser)

// Lucky Colors Management
router.get('/lucky-colors', adminController.getAllLuckyColors)
router.put('/lucky-colors/:id', adminController.updateLuckyColor)

// System Maintenance & Clean-up
router.post('/system/cleanup', adminController.cleanSystemOrphans)

export default router
