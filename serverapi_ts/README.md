# StyleMe Server API (TypeScript + MySQL) 👗🚀

Backend REST API สำหรับแอปพลิเคชัน **StyleMe: The Perfect Fit** ดัดแปลงและพัฒนาต่อยอดมาจากโครงสร้าง `serverapi_ts` เดิม

---

## 🗄 ข้อมูล Database (.env)

- **Database Name:** `styleme_app` (สร้างใหม่เรียบร้อยแล้ว)
- **Host:** `127.0.0.1`
- **Port:** `3307`
- **User:** `root`
- **Password:** *(ค่าว่าง)*
- **JWT Secret:** `1234@secret`

---

## 📋 ตารางในระบบ (Database Tables)

1. `users` — ข้อมูลผู้ใช้งาน (id, fullname, email, password, body_shape)
2. `lucky_colors` — ข้อมูลสีมงคลประจำวันทั้ง 7 วัน จันทร์–อาทิตย์
3. `outfits` — ข้อมูลชุดเสื้อผ้า, โอกาส/สถานที่, รูปร่างที่เหมาะสม, Match Score
4. `outfit_items` — ชิ้นส่วนเสื้อผ้า (Top, Bottom, Shoes, Accessory)
5. `styling_tips` — คำแนะนำการแต่งตัวเฉพาะบุคคล (Personalized Styling Tips) ตามแต่ละรูปร่าง

---

## 🔌 REST API Endpoints

- `GET /` — ตรวจสอบสถานะ Server และ Database
- `POST /api/auth/register` — สมัครสมาชิกใหม่
- `POST /api/auth/login` — เข้าสู่ระบบ และรับ JWT Token
- `GET /api/auth/profile` — ข้อมูลโปรไฟล์ผู้ใช้ (ต้องการ Bearer Token)
- `GET /api/lucky-colors/today` — ดึงสีมงคลประจำวัน
- `GET /api/lucky-colors` — ดึงสีมงคลครบทั้ง 7 วัน
- `GET /api/outfits?bodyShape=Pear&occasion=Cafe` — กรองชุดที่แมทช์จาก Database
- `GET /api/outfits/:id` — ดึงรายละเอียดชุดและคำแนะนำเฉพาะบุคคล

---

## 🚀 คำสั่งใช้งาน (Scripts)

```bash
# รันเซิร์ฟเวอร์แบบ Dev
npm run start
# หรือ
npx ts-node server.ts

# รัน Migration ตาราง
npm run knex:migrate:latest

# รัน Seed ข้อมูลเริ่มต้น
npm run knex:seed:run
```
