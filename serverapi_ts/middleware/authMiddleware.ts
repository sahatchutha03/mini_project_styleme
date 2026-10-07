import jwt, { JwtPayload } from 'jsonwebtoken'
import { Request, Response, NextFunction } from 'express'
import db from '../utils/knex'

// Extend the Express Request type with the user property
export interface RequestWithUser extends Request {
  user?: JwtPayload | any
  adminUser?: any
}

export function authenticateToken(req: RequestWithUser, res: Response, next: NextFunction) {
  const authHeader = req.headers['authorization']
  const token = authHeader && authHeader.split(' ')[1]

  if (token == null) {
    return res.status(401).json({
      status: 'error',
      message: 'Unauthorized: กรุณาแนบ Token',
      statusCode: 401,
    })
  }

  jwt.verify(token, process.env.JWT_SECRET || '1234@secret', (err, user) => {
    if (err) {
      return res.status(403).json({
        status: 'error',
        message: 'Forbidden: Token ไม่ถูกต้องหรือหมดอายุ',
        statusCode: 403,
      })
    }
    req.user = user
    next()
  })
}

export async function requireAdmin(req: RequestWithUser, res: Response, next: NextFunction) {
  const user = req.user
  if (!user || !user.id) {
    return res.status(401).json({
      status: 'error',
      message: 'กรุณาเข้าสู่ระบบก่อนดำเนินการ',
    })
  }

  try {
    const dbUser = await db('users').where({ id: user.id }).first()
    if (!dbUser || dbUser.role !== 'admin') {
      return res.status(403).json({
        status: 'error',
        message: 'ไม่สามารถเข้าใช้งานในส่วนนี้ได้',
      })
    }

    req.adminUser = dbUser
    next()
  } catch (error) {
    console.error('requireAdmin error:', error)
    return res.status(500).json({
      status: 'error',
      message: 'เกิดข้อผิดพลาดในการตรวจสอบสิทธิ์ผู้ดูแลระบบ',
    })
  }
}

export default authenticateToken
