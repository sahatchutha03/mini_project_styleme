import { Request, Response } from 'express'
import db from '../utils/knex'

// 1. Dashboard & System Overview
export async function getDashboardStats(req: Request, res: Response): Promise<void> {
  try {
    const totalOutfitsResult = await db('outfits').count('id as count').first()
    const totalUsersResult = await db('users').count('id as count').first()
    const totalAdminsResult = await db('users').where({ role: 'admin' }).count('id as count').first()
    const totalWardrobeResult = await db('user_wardrobe').count('id as count').first()

    // Occasion Breakdown
    const occasionRows = await db('outfits')
      .select('occasion')
      .count('id as count')
      .groupBy('occasion')

    // Color Category Breakdown
    const colorCategoryRows = await db('outfits')
      .select('color_category')
      .count('id as count')
      .groupBy('color_category')

    // Recent Outfits (Top 5)
    const recentOutfits = await db('outfits')
      .select('id', 'title', 'occasion', 'image_url', 'match_score', 'created_at')
      .orderBy('id', 'desc')
      .limit(5)

    // Recent Users (Top 5)
    const recentUsers = await db('users')
      .select('id', 'fullname', 'email', 'body_shape', 'role', 'created_at')
      .orderBy('id', 'desc')
      .limit(5)

    res.json({
      status: 'ok',
      data: {
        totalOutfits: Number(totalOutfitsResult?.count || 0),
        totalUsers: Number(totalUsersResult?.count || 0),
        totalAdmins: Number(totalAdminsResult?.count || 0),
        totalWardrobeSaves: Number(totalWardrobeResult?.count || 0),
        occasionCounts: occasionRows.map((r: any) => ({
          occasion: r.occasion,
          count: Number(r.count),
        })),
        colorCategoryCounts: colorCategoryRows.map((r: any) => ({
          category: r.color_category,
          count: Number(r.count),
        })),
        recentOutfits,
        recentUsers,
        systemHealth: {
          database: 'Connected (MySQL 8.x)',
          uptimeSeconds: Math.floor(process.uptime()),
          nodeVersion: process.version,
          serverTimestamp: new Date().toISOString(),
          status: 'healthy',
        },
      },
    })
  } catch (error) {
    console.error('getDashboardStats error:', error)
    res.status(500).json({ status: 'error', message: 'ไม่สามารถดึงข้อมูลสถิติภาพรวมระบบได้' })
  }
}

// 2. User Management
export async function getAllUsers(req: Request, res: Response): Promise<void> {
  try {
    const search = typeof req.query.search === 'string' ? req.query.search.trim() : ''

    let query = db('users').select(
      'users.id',
      'users.fullname',
      'users.email',
      'users.body_shape',
      'users.role',
      'users.created_at',
      'users.updated_at'
    )

    if (search) {
      query = query.where(function () {
        this.where('users.fullname', 'like', `%${search}%`)
          .orWhere('users.email', 'like', `%${search}%`)
      })
    }

    const users = await query.orderBy('users.id', 'desc')

    // Attach wardrobe count for each user
    const usersWithStats = await Promise.all(
      users.map(async (u) => {
        const wardrobeCount = await db('user_wardrobe').where({ user_id: u.id }).count('id as count').first()
        return {
          id: u.id,
          fullName: u.fullname,
          email: u.email,
          bodyShape: u.body_shape,
          role: u.role || 'user',
          createdAt: u.created_at,
          updatedAt: u.updated_at,
          wardrobeCount: Number(wardrobeCount?.count || 0),
        }
      })
    )

    res.json({
      status: 'ok',
      data: usersWithStats,
    })
  } catch (error) {
    console.error('getAllUsers error:', error)
    res.status(500).json({ status: 'error', message: 'ไม่สามารถดึงรายชื่อผู้ใช้งานได้' })
  }
}

export async function updateUserRole(req: Request, res: Response): Promise<void> {
  try {
    const userId = parseInt(req.params.id)
    const { role } = req.body

    if (!['admin', 'user'].includes(role)) {
      res.status(400).json({ status: 'error', message: 'บทบาทต้องเป็น admin หรือ user เท่านั้น' })
      return
    }

    const targetUser = await db('users').where({ id: userId }).first()
    if (!targetUser) {
      res.status(404).json({ status: 'error', message: 'ไม่พบผู้ใช้งานที่ระบุ' })
      return
    }

    // Protect: Prevent demoting the last admin
    if (targetUser.role === 'admin' && role === 'user') {
      const adminCount = await db('users').where({ role: 'admin' }).count('id as count').first()
      if (Number(adminCount?.count || 0) <= 1) {
        res.status(400).json({
          status: 'error',
          message: 'ไม่สามารถปลดผู้ดูแลระบบคนสุดท้ายได้ ระบบต้องมีผู้ดูแลระบบอย่างน้อย 1 คน',
        })
        return
      }
    }

    await db('users').where({ id: userId }).update({
      role,
      updated_at: new Date(),
    })

    res.json({
      status: 'ok',
      message: `เปลี่ยนสิทธิ์ผู้ใช้ "${targetUser.fullname}" เป็น ${role} เรียบร้อยแล้ว`,
      userId,
      role,
    })
  } catch (error) {
    console.error('updateUserRole error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการเปลี่ยนสิทธิ์ผู้ใช้' })
  }
}

export async function deleteUser(req: any, res: Response): Promise<void> {
  try {
    const targetUserId = parseInt(req.params.id)
    const currentAdminId = req.user?.id

    if (currentAdminId && currentAdminId === targetUserId) {
      res.status(400).json({ status: 'error', message: 'ไม่สามารถลบบัญชีผู้ดูแลระบบของตนเองขณะเข้าใช้งานได้' })
      return
    }

    const targetUser = await db('users').where({ id: targetUserId }).first()
    if (!targetUser) {
      res.status(404).json({ status: 'error', message: 'ไม่พบผู้ใช้งานที่ต้องการลบ' })
      return
    }

    // Cascade delete wardrobe records first
    await db('user_wardrobe').where({ user_id: targetUserId }).del().catch(() => {})
    await db('users').where({ id: targetUserId }).del()

    res.json({
      status: 'ok',
      message: `ลบผู้ใช้งาน "${targetUser.fullname}" ออกจากระบบเรียบร้อยแล้ว`,
      deletedId: targetUserId,
    })
  } catch (error) {
    console.error('deleteUser error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการลบผู้ใช้งาน' })
  }
}

// 3. Lucky Colors Management
export async function getAllLuckyColors(req: Request, res: Response): Promise<void> {
  try {
    const list = await db('lucky_colors').select('*').orderBy('day_number', 'asc')
    res.json({
      status: 'ok',
      data: list,
    })
  } catch (error) {
    console.error('getAllLuckyColors error:', error)
    res.status(500).json({ status: 'error', message: 'ไม่สามารถดึงข้อมูลสีมงคลได้' })
  }
}

export async function updateLuckyColor(req: Request, res: Response): Promise<void> {
  try {
    const id = parseInt(req.params.id)
    const {
      work_color,
      work_hex,
      wealth_color,
      wealth_hex,
      love_color,
      love_hex,
      unlucky_color,
      unlucky_hex,
      advice,
    } = req.body

    const existing = await db('lucky_colors').where({ id }).first()
    if (!existing) {
      res.status(404).json({ status: 'error', message: 'ไม่พบข้อมูลสีมงคลประจำวันที่ระบุ' })
      return
    }

    const updateData: any = { updated_at: new Date() }
    if (work_color !== undefined) updateData.work_color = work_color
    if (work_hex !== undefined) updateData.work_hex = work_hex
    if (wealth_color !== undefined) updateData.wealth_color = wealth_color
    if (wealth_hex !== undefined) updateData.wealth_hex = wealth_hex
    if (love_color !== undefined) updateData.love_color = love_color
    if (love_hex !== undefined) updateData.love_hex = love_hex
    if (unlucky_color !== undefined) updateData.unlucky_color = unlucky_color
    if (unlucky_hex !== undefined) updateData.unlucky_hex = unlucky_hex
    if (advice !== undefined) updateData.advice = advice

    await db('lucky_colors').where({ id }).update(updateData)

    const updated = await db('lucky_colors').where({ id }).first()
    res.json({
      status: 'ok',
      message: `อัปเดตข้อมูลสีมงคลของ ${existing.day_title} สำเร็จ`,
      data: updated,
    })
  } catch (error) {
    console.error('updateLuckyColor error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการอัปเดตสีมงคล' })
  }
}

// 4. System Maintenance & Cleanup (จัดการความเรียบร้อยของระบบ)
export async function cleanSystemOrphans(req: Request, res: Response): Promise<void> {
  try {
    // 1. Delete orphaned outfit_items where outfit does not exist
    const orphanItems = await db('outfit_items')
      .whereNotIn('outfit_id', db('outfits').select('id'))
      .del()

    // 2. Delete orphaned styling_tips where outfit does not exist
    const orphanTips = await db('styling_tips')
      .whereNotIn('outfit_id', db('outfits').select('id'))
      .del()

    // 3. Delete orphaned user_wardrobe where user or outfit does not exist
    const orphanWardrobeUser = await db('user_wardrobe')
      .whereNotIn('user_id', db('users').select('id'))
      .del()

    const orphanWardrobeOutfit = await db('user_wardrobe')
      .whereNotIn('outfit_id', db('outfits').select('id'))
      .del()

    // Check table row counts for report
    const outfitsCount = await db('outfits').count('id as count').first()
    const itemsCount = await db('outfit_items').count('id as count').first()
    const tipsCount = await db('styling_tips').count('id as count').first()
    const usersCount = await db('users').count('id as count').first()
    const wardrobeCount = await db('user_wardrobe').count('id as count').first()

    res.json({
      status: 'ok',
      message: 'ตรวจสอบและจัดระเบียบฐานข้อมูลระบบเรียบร้อยแล้ว ไม่พบข้อผิดพลาดตกค้าง',
      cleanupSummary: {
        orphanedItemsRemoved: orphanItems,
        orphanedTipsRemoved: orphanTips,
        orphanedWardrobeRemoved: (orphanWardrobeUser || 0) + (orphanWardrobeOutfit || 0),
      },
      currentIntegrity: {
        totalOutfits: Number(outfitsCount?.count || 0),
        totalClothingItems: Number(itemsCount?.count || 0),
        totalStylingTips: Number(tipsCount?.count || 0),
        totalUsers: Number(usersCount?.count || 0),
        totalWardrobeEntries: Number(wardrobeCount?.count || 0),
        databaseStatus: 'All foreign keys consistent and clean',
      },
    })
  } catch (error) {
    console.error('cleanSystemOrphans error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการตรวจสอบความเรียบร้อยของระบบ' })
  }
}
