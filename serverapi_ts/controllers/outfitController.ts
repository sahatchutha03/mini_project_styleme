import { Request, Response } from 'express'
import db from '../utils/knex'

async function fetchFullOutfitById(id: number) {
  const outfit = await db('outfits').where({ id }).first()
  if (!outfit) return null

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
    bodyShapes: outfit.body_shapes ? outfit.body_shapes.split(',') : [],
    colorCategory: outfit.color_category,
    colorName: outfit.color_name,
    colorHex: outfit.color_hex,
    matchScore: outfit.match_score,
    items: items.map((i) => ({
      id: i.id,
      category: i.category,
      name: i.name,
      colorName: i.color_name,
      colorHex: i.color_hex,
    })),
    stylingTips: tipsMap,
  }
}

export async function getMatchedOutfits(req: Request, res: Response): Promise<void> {
  try {
    const bodyShape = typeof req.query.bodyShape === 'string' ? req.query.bodyShape : undefined
    const occasion = typeof req.query.occasion === 'string' ? req.query.occasion : undefined
    const color = typeof req.query.color === 'string' ? req.query.color : undefined

    let query = db('outfits')

    if (bodyShape && bodyShape !== 'All') {
      query = query.where('body_shapes', 'like', `%${bodyShape}%`)
    }

    if (occasion && occasion !== 'All') {
      query = query.where('occasion', occasion)
    }

    if (color && color !== 'All') {
      query = query.where('color_category', color)
    }

    const outfits = await query.orderBy('id', 'desc')

    // Attach items and styling tips for each outfit
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
          bodyShapes: outfit.body_shapes ? outfit.body_shapes.split(',') : [],
          colorCategory: outfit.color_category,
          colorName: outfit.color_name,
          colorHex: outfit.color_hex,
          matchScore: outfit.match_score,
          items: items.map((i) => ({
            id: i.id,
            category: i.category,
            name: i.name,
            colorName: i.color_name,
            colorHex: i.color_hex,
          })),
          stylingTips: tipsMap,
        }
      })
    )

    res.json({
      status: 'ok',
      data: outfitList,
    })
  } catch (error) {
    console.error('getMatchedOutfits error:', error)
    res.status(500).json({ status: 'error', message: 'Failed to fetch outfits' })
  }
}

export async function getOutfitDetail(req: Request, res: Response): Promise<void> {
  try {
    const id = parseInt(req.params.id)
    const detail = await fetchFullOutfitById(id)

    if (!detail) {
      res.status(404).json({ status: 'error', message: 'Outfit not found' })
      return
    }

    res.json({
      status: 'ok',
      data: detail,
    })
  } catch (error) {
    console.error('getOutfitDetail error:', error)
    res.status(500).json({ status: 'error', message: 'Failed to fetch outfit detail' })
  }
}

// Create Outfit (Admin)
export async function createOutfit(req: Request, res: Response): Promise<void> {
  try {
    const {
      title,
      description,
      imageUrl,
      image_url,
      occasion,
      bodyShapes,
      body_shapes,
      colorCategory,
      color_category,
      colorName,
      color_name,
      colorHex,
      color_hex,
      matchScore,
      match_score,
      items,
      stylingTips,
    } = req.body

    if (!title || !occasion) {
      res.status(400).json({ status: 'error', message: 'กรุณาระบุชื่อชุดและโอกาสการแต่งตัว' })
      return
    }

    const shapesStr = Array.isArray(bodyShapes)
      ? bodyShapes.join(',')
      : (bodyShapes || body_shapes || 'Pear,Hourglass,Apple,Rectangle,Inverted Triangle')

    const [outfitId] = await db('outfits').insert({
      title,
      description: description || '',
      image_url: imageUrl || image_url || 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80',
      occasion,
      body_shapes: shapesStr,
      color_category: colorCategory || color_category || 'work',
      color_name: colorName || color_name || 'สีสุภาพ',
      color_hex: colorHex || color_hex || '#7A1CAC',
      match_score: matchScore || match_score || 95,
      created_at: new Date(),
      updated_at: new Date(),
    })

    // Insert clothing items if provided
    if (Array.isArray(items) && items.length > 0) {
      const itemRows = items.map((item: any) => ({
        outfit_id: outfitId,
        category: item.category || 'Top',
        name: item.name || 'เสื้อผ้า',
        color_name: item.colorName || item.color_name || 'สีสุภาพ',
        color_hex: item.colorHex || item.color_hex || '#000000',
        created_at: new Date(),
        updated_at: new Date(),
      }))
      await db('outfit_items').insert(itemRows)
    }

    // Insert styling tips if provided
    if (stylingTips) {
      const tipRows: any[] = []
      if (Array.isArray(stylingTips)) {
        stylingTips.forEach((tip: any) => {
          tipRows.push({
            outfit_id: outfitId,
            body_shape: tip.bodyShape || tip.body_shape || 'Pear',
            tip_title: tip.tipTitle || tip.tip_title || 'เทคนิคการสวมใส่',
            tip_content: tip.tipContent || tip.tip_content || 'ปรับให้เข้ากับสรีระ',
            highlight_feature: tip.highlightFeature || tip.highlight_feature || 'เพิ่มความมั่นใจ',
            lucky_color_synergy: tip.luckyColorSynergy || tip.lucky_color_synergy || '',
            created_at: new Date(),
            updated_at: new Date(),
          })
        })
      } else if (typeof stylingTips === 'object') {
        Object.keys(stylingTips).forEach((shapeKey) => {
          const tip = stylingTips[shapeKey]
          tipRows.push({
            outfit_id: outfitId,
            body_shape: shapeKey,
            tip_title: tip.tipTitle || tip.tip_title || `เทคนิคสำหรับหุ่น ${shapeKey}`,
            tip_content: tip.tipContent || tip.tip_content || 'สวมใส่เพื่อความสมส่วน',
            highlight_feature: tip.highlightFeature || tip.highlight_feature || 'จุดเด่นของชุด',
            lucky_color_synergy: tip.luckyColorSynergy || tip.lucky_color_synergy || '',
            created_at: new Date(),
            updated_at: new Date(),
          })
        })
      }
      if (tipRows.length > 0) {
        await db('styling_tips').insert(tipRows)
      }
    }

    const created = await fetchFullOutfitById(outfitId)
    res.status(201).json({
      status: 'ok',
      message: 'เพิ่มชุดเสื้อผ้าใหม่สำเร็จ',
      data: created,
    })
  } catch (error) {
    console.error('createOutfit error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการเพิ่มชุดเสื้อผ้า' })
  }
}

// Update Outfit (Admin)
export async function updateOutfit(req: Request, res: Response): Promise<void> {
  try {
    const id = parseInt(req.params.id)
    const existing = await db('outfits').where({ id }).first()
    if (!existing) {
      res.status(404).json({ status: 'error', message: 'ไม่พบชุดเสื้อผ้าที่ต้องการแก้ไข' })
      return
    }

    const {
      title,
      description,
      imageUrl,
      image_url,
      occasion,
      bodyShapes,
      body_shapes,
      colorCategory,
      color_category,
      colorName,
      color_name,
      colorHex,
      color_hex,
      matchScore,
      match_score,
      items,
      stylingTips,
    } = req.body

    const updateData: any = { updated_at: new Date() }
    if (title !== undefined) updateData.title = title
    if (description !== undefined) updateData.description = description
    if (imageUrl !== undefined || image_url !== undefined) updateData.image_url = imageUrl || image_url
    if (occasion !== undefined) updateData.occasion = occasion
    if (bodyShapes !== undefined || body_shapes !== undefined) {
      updateData.body_shapes = Array.isArray(bodyShapes) ? bodyShapes.join(',') : (bodyShapes || body_shapes)
    }
    if (colorCategory !== undefined || color_category !== undefined) updateData.color_category = colorCategory || color_category
    if (colorName !== undefined || color_name !== undefined) updateData.color_name = colorName || color_name
    if (colorHex !== undefined || color_hex !== undefined) updateData.color_hex = colorHex || color_hex
    if (matchScore !== undefined || match_score !== undefined) updateData.match_score = matchScore || match_score

    await db('outfits').where({ id }).update(updateData)

    // Update items if provided
    if (items !== undefined && Array.isArray(items)) {
      await db('outfit_items').where({ outfit_id: id }).del()
      if (items.length > 0) {
        const itemRows = items.map((item: any) => ({
          outfit_id: id,
          category: item.category || 'Top',
          name: item.name || 'เสื้อผ้า',
          color_name: item.colorName || item.color_name || 'สีสุภาพ',
          color_hex: item.colorHex || item.color_hex || '#000000',
          created_at: new Date(),
          updated_at: new Date(),
        }))
        await db('outfit_items').insert(itemRows)
      }
    }

    // Update styling tips if provided
    if (stylingTips !== undefined) {
      await db('styling_tips').where({ outfit_id: id }).del()
      const tipRows: any[] = []
      if (Array.isArray(stylingTips)) {
        stylingTips.forEach((tip: any) => {
          tipRows.push({
            outfit_id: id,
            body_shape: tip.bodyShape || tip.body_shape || 'Pear',
            tip_title: tip.tipTitle || tip.tip_title || 'เทคนิคการสวมใส่',
            tip_content: tip.tipContent || tip.tip_content || 'ปรับให้เข้ากับสรีระ',
            highlight_feature: tip.highlightFeature || tip.highlight_feature || 'เพิ่มความมั่นใจ',
            lucky_color_synergy: tip.luckyColorSynergy || tip.lucky_color_synergy || '',
            created_at: new Date(),
            updated_at: new Date(),
          })
        })
      } else if (typeof stylingTips === 'object') {
        Object.keys(stylingTips).forEach((shapeKey) => {
          const tip = stylingTips[shapeKey]
          tipRows.push({
            outfit_id: id,
            body_shape: shapeKey,
            tip_title: tip.tipTitle || tip.tip_title || `เทคนิคสำหรับหุ่น ${shapeKey}`,
            tip_content: tip.tipContent || tip.tip_content || 'สวมใส่เพื่อความสมส่วน',
            highlight_feature: tip.highlightFeature || tip.highlight_feature || 'จุดเด่นของชุด',
            lucky_color_synergy: tip.luckyColorSynergy || tip.lucky_color_synergy || '',
            created_at: new Date(),
            updated_at: new Date(),
          })
        })
      }
      if (tipRows.length > 0) {
        await db('styling_tips').insert(tipRows)
      }
    }

    const updated = await fetchFullOutfitById(id)
    res.json({
      status: 'ok',
      message: 'อัปเดตข้อมูลชุดเสื้อผ้าสำเร็จ',
      data: updated,
    })
  } catch (error) {
    console.error('updateOutfit error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการแก้ไขชุดเสื้อผ้า' })
  }
}

// Delete Outfit (Admin)
export async function deleteOutfit(req: Request, res: Response): Promise<void> {
  try {
    const id = parseInt(req.params.id)
    const existing = await db('outfits').where({ id }).first()
    if (!existing) {
      res.status(404).json({ status: 'error', message: 'ไม่พบชุดเสื้อผ้าที่ต้องการลบ' })
      return
    }

    await db('user_wardrobe').where({ outfit_id: id }).del().catch(() => {})
    await db('styling_tips').where({ outfit_id: id }).del().catch(() => {})
    await db('outfit_items').where({ outfit_id: id }).del().catch(() => {})
    await db('outfits').where({ id }).del()

    res.json({
      status: 'ok',
      message: `ลบชุดเสื้อผ้า "${existing.title}" เรียบร้อยแล้ว`,
      deletedId: id,
    })
  } catch (error) {
    console.error('deleteOutfit error:', error)
    res.status(500).json({ status: 'error', message: 'เกิดข้อผิดพลาดในการลบชุดเสื้อผ้า' })
  }
}
