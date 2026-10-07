import { Request, Response } from 'express'
import db from '../utils/knex'

export async function getToday(req: Request, res: Response): Promise<void> {
  try {
    const now = new Date()
    // JavaScript getDay(): 0 is Sunday, 1 is Monday, ..., 6 is Saturday
    // Convert to 1 = Monday, ..., 7 = Sunday
    const jsDay = now.getDay()
    const dayNumber = jsDay === 0 ? 7 : jsDay

    const row = await db('lucky_colors').where({ day_number: dayNumber }).first()

    if (!row) {
      // Fallback
      const fallback = await db('lucky_colors').first()
      res.json(mapRow(fallback))
      return
    }

    res.json(mapRow(row))
  } catch (error) {
    console.error('getToday error:', error)
    res.status(500).json({ status: 'error', message: 'Failed to fetch lucky colors' })
  }
}

export async function getAll(req: Request, res: Response): Promise<void> {
  try {
    const rows = await db('lucky_colors').orderBy('day_number', 'asc')
    res.json({
      status: 'ok',
      data: rows.map(mapRow),
    })
  } catch (error) {
    console.error('getAll error:', error)
    res.status(500).json({ status: 'error', message: 'Failed to fetch lucky colors' })
  }
}

function mapRow(row: any) {
  return {
    dayOfWeek: row.day_of_week,
    dayTitle: row.day_title,
    thaiDate: row.thai_date,
    workColor: row.work_color,
    workHex: row.work_hex,
    wealthColor: row.wealth_color,
    wealthHex: row.wealth_hex,
    loveColor: row.love_color,
    loveHex: row.love_hex,
    unluckyColor: row.unlucky_color,
    unluckyHex: row.unlucky_hex,
    advice: row.advice,
  }
}
