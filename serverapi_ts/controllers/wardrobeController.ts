import { Request, Response } from 'express'
import jwt from 'jsonwebtoken'
import db from '../utils/knex'

function getUserIdFromToken(req: Request): number | null {
  const authHeader = req.headers.authorization
  if (!authHeader || !authHeader.startsWith('Bearer ')) return null

  const token = authHeader.split(' ')[1]
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || '1234@secret') as any
    return decoded.id
  } catch {
    return null
  }
}

// 1. ดึงชุดทั้งหมดในตู้เสื้อผ้าของผู้ใช้
export async function getWardrobe(req: Request, res: Response): Promise<void> {
  const userId = getUserIdFromToken(req)
  if (!userId) {
    res.status(401).json({ status: 'error', message: 'กรุณาเข้าสู่ระบบ' })
    return
  }

  try {
    const savedRecords = await db('user_wardrobe')
      .where({ user_id: userId })
      .orderBy('created_at', 'desc')

    const outfitIds = savedRecords.map((r) => r.outfit_id)

    if (outfitIds.length === 0) {
      res.json({ status: 'ok', data: [] })
      return
    }

    const outfits = await db('outfits').whereIn('id', outfitIds)

    const outfitList = await Promise.all(
      outfits.map(async (outfit) => {
        const items = await db('outfit_items').where({ outfit_id: outfit.id })
        const tips = await db('styling_tips').where({ outfit_id: outfit.id })

        const tipsMap: Record<string, any> = {}
        tips.forEach((t) => {
          tipsMap[t.body_shape] = {
            id: t.id,
            bodyShape: t.body_shape,
            tipTitle: t.tip_title,
            tipContent: t.tip_content,
            highlightFeature: t.highlight_feature,
            luckyColorSynergy: t.lucky_color_synergy,
          }
        })

        return {
          id: outfit.id,
          title: outfit.title,
          description: outfit.description,
          imageUrl: outfit.image_url,
          occasion: outfit.occasion,
          bodyShapes: outfit.body_shapes.split(','),
          colorCategory: outfit.color_category,
          colorName: outfit.color_name,
          colorHex: outfit.color_hex,
          matchScore: outfit.match_score,
          items: items.map((i) => ({
            category: i.category,
            name: i.name,
            colorName: i.color_name,
            colorHex: i.color_hex,
          })),
          stylingTips: tipsMap,
        }
      })
    )

    res.json({ status: 'ok', data: outfitList })
  } catch (error) {
    console.error('getWardrobe error:', error)
    res.status(500).json({ status: 'error', message: 'ไม่สามารถดึงข้อมูลตู้เสื้อผ้าได้' })
  }
}

// 2. บันทึกชุดลงตู้เสื้อผ้า
export async function saveToWardrobe(req: Request, res: Response): Promise<void> {
  const userId = getUserIdFromToken(req)
  if (!userId) {
    res.status(401).json({ status: 'error', message: 'กรุณาเข้าสู่ระบบ' })
    return
  }

  const { outfitId } = req.body
  if (!outfitId) {
    res.status(400).json({ status: 'error', message: 'ระบุรหัสชุดเสื้อผ้า' })
    return
  }

  try {
    const existing = await db('user_wardrobe')
      .where({ user_id: userId, outfit_id: outfitId })
      .first()

    if (!existing) {
      await db('user_wardrobe').insert({
        user_id: userId,
        outfit_id: outfitId,
        created_at: new Date(),
        updated_at: new Date(),
      })
    }

    res.json({ status: 'ok', message: 'บันทึกลงตู้เสื้อผ้าแล้ว' })
  } catch (error) {
    console.error('saveToWardrobe error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการบันทึก' })
  }
}

// 3. ลบชุดออกจากตู้เสื้อผ้า
export async function removeFromWardrobe(req: Request, res: Response): Promise<void> {
  const userId = getUserIdFromToken(req)
  if (!userId) {
    res.status(401).json({ status: 'error', message: 'กรุณาเข้าสู่ระบบ' })
    return
  }

  const { outfitId } = req.params

  try {
    await db('user_wardrobe')
      .where({ user_id: userId, outfit_id: outfitId })
      .del()

    res.json({ status: 'ok', message: 'ลบออกจากตู้เสื้อผ้าแล้ว' })
  } catch (error) {
    console.error('removeFromWardrobe error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการลบ' })
  }
}

// 4. ตรวจสอบว่าชุดนี้ถูกบันทึกไว้ในตู้หรือไม่
export async function checkIsSaved(req: Request, res: Response): Promise<void> {
  const userId = getUserIdFromToken(req)
  if (!userId) {
    res.json({ status: 'ok', isSaved: false })
    return
  }

  const { outfitId } = req.params

  try {
    const existing = await db('user_wardrobe')
      .where({ user_id: userId, outfit_id: outfitId })
      .first()

    res.json({ status: 'ok', isSaved: !!existing })
  } catch (error) {
    res.json({ status: 'ok', isSaved: false })
  }
}
