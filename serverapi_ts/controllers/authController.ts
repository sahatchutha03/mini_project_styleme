import jwt from 'jsonwebtoken'
import bcrypt from 'bcrypt'
import { Request, Response } from 'express'
import db from '../utils/knex'

// Register
export async function register(req: Request, res: Response): Promise<void> {
  const { email, password, fullName, fullname, defaultBodyShape, bodyShape } = req.body
  const name = fullName || fullname || 'ผู้ใช้งาน StyleMe'
  const shape = defaultBodyShape || bodyShape || 'Pear'

  try {
    const existing = await db('users').where({ email }).first()
    if (existing) {
      res.status(400).json({ status: 'error', message: 'อีเมลนี้ถูกใช้งานในระบบแล้ว' })
      return
    }

    const hashedPassword = await bcrypt.hash(password, 10)
    const [userId] = await db('users').insert({
      fullname: name,
      email,
      password: hashedPassword,
      body_shape: shape,
      role: 'user',
      created_at: new Date(),
      updated_at: new Date(),
    })

    const token = jwt.sign(
      { id: userId, email, role: 'user' },
      process.env.JWT_SECRET || '1234@secret',
      { expiresIn: '7d' }
    )

    res.status(201).json({
      status: 'ok',
      message: 'สมัครสมาชิกสำเร็จ',
      token,
      user: {
        id: userId,
        fullName: name,
        email,
        defaultBodyShape: shape,
        role: 'user',
      },
    })
  } catch (error) {
    console.error('Register error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการสมัครสมาชิก' })
  }
}

// Login
export async function login(req: Request, res: Response): Promise<void> {
  const { email, password } = req.body

  try {
    const user = await db('users').where({ email }).first()
    if (!user) {
      res.status(401).json({ status: 'error', message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' })
      return
    }

    const isMatch = await bcrypt.compare(password, user.password)
    if (!isMatch) {
      res.status(401).json({ status: 'error', message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' })
      return
    }

    const userRole = user.role || 'user'
    const token = jwt.sign(
      { id: user.id, email: user.email, role: userRole },
      process.env.JWT_SECRET || '1234@secret',
      { expiresIn: '7d' }
    )

    res.json({
      status: 'ok',
      message: 'เข้าสู่ระบบสำเร็จ',
      token,
      user: {
        id: user.id,
        fullName: user.fullname,
        email: user.email,
        defaultBodyShape: user.body_shape,
        role: userRole,
      },
    })
  } catch (error) {
    console.error('Login error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ' })
  }
}

// Profile
export async function profile(req: Request, res: Response): Promise<void> {
  const authHeader = req.headers.authorization
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ status: 'error', message: 'Unauthorized' })
    return
  }

  const token = authHeader.split(' ')[1]
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || '1234@secret') as any
    const user = await db('users').where({ id: decoded.id }).first()

    if (!user) {
      res.status(404).json({ status: 'error', message: 'User not found' })
      return
    }

    res.json({
      status: 'ok',
      user: {
        id: user.id,
        fullName: user.fullname,
        email: user.email,
        defaultBodyShape: user.body_shape,
        role: user.role || 'user',
      },
    })
  } catch (error) {
    res.status(401).json({ status: 'error', message: 'Invalid token' })
  }
}

// Update Profile
export async function updateProfile(req: Request, res: Response): Promise<void> {
  const authHeader = req.headers.authorization
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ status: 'error', message: 'Unauthorized' })
    return
  }

  const token = authHeader.split(' ')[1]
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || '1234@secret') as any
    const { fullName, bodyShape } = req.body

    const updateData: any = { updated_at: new Date() }
    if (fullName) updateData.fullname = fullName
    if (bodyShape) updateData.body_shape = bodyShape

    await db('users').where({ id: decoded.id }).update(updateData)

    const updatedUser = await db('users').where({ id: decoded.id }).first()

    res.json({
      status: 'ok',
      message: 'อัปเดตข้อมูลผู้ใช้สำเร็จ',
      user: {
        id: updatedUser.id,
        fullName: updatedUser.fullname,
        email: updatedUser.email,
        defaultBodyShape: updatedUser.body_shape,
        role: updatedUser.role || 'user',
      },
    })
  } catch (error) {
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการอัปเดตข้อมูล' })
  }
}
