# StyleMe: The Perfect Fit (Personal Stylist System)
> 👗 **ระบบสไตล์ลิสต์ส่วนตัว (StyleMe)** — Mobile Application พัฒนาด้วย Flutter เชื่อมต่อ REST API (Node.js/Express + TypeScript) และฐานข้อมูล MySQL 8.x

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![NodeJS](https://img.shields.io/badge/Node.js-18%2B-339933?logo=nodedotjs&logoColor=white)
![Express](https://img.shields.io/badge/Express.js-TypeScript-000000?logo=express&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.x-4479A1?logo=mysql&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-purple)

---

## 📌 เกี่ยวกับโปรเจกต์ (About Project)

**StyleMe** เป็นแอปพลิเคชันที่ทำหน้าที่เป็นสไตล์ลิสต์ส่วนตัวอัจฉริยะ ช่วยแนะนำการแต่งกายเฉพาะบุคคลโดยคำนวณและจับคู่เสื้อผ้าจากฐานข้อมูลจริงตามสรีระรูปร่าง (Body Shape: Pear, Hourglass, Apple, Rectangle, Inverted Triangle) กาลเทศะสถานที่ (Occasion: Cafe, Office, Dinner, Street, Beach) พร้อมผสานศาสตร์สีมงคลประจำวัน (Daily Lucky Color) จาก API สด และมีระบบตู้เสื้อผ้าดิจิทัล (Digital Wardrobe) ให้ผู้ใช้สามารถบันทึกชุดที่ชื่นชอบได้

นอกจากนี้ ระบบยังมี **ส่วนควบคุมสำหรับผู้ดูแลระบบ (Admin Control Panel)** พร้อมการแบ่งแยกสิทธิ์ตามบทบาท (Role-Based Access Control: RBAC) สำหรับดูสถิติภาพรวม จัดการชุดเสื้อผ้า (CRUD) จัดการสมาชิก และปรับปรุงตารางสีมงคลได้อย่างครบวงจร

---

## ✨ ฟีเจอร์หลักของระบบ (Core Features)

### ฝั่งผู้ใช้งานทั่วไป (Customer / User)
* 🔐 **Authentication & Auto-login:** สมัครสมาชิกและเข้าสู่ระบบด้วย JWT Token และจัดเก็บสถานะลงใน `SharedPreferences`
* 🔮 **Daily Lucky Colors:** ดึงข้อมูลสีมงคล 4 ด้าน (งาน, เงิน, ความรัก, กาลกิณี) ประจำวันสดจาก API
* 🎯 **Style Matcher:** กรองชุดเสื้อผ้าตามรูปร่าง 5 แบบ และโอกาส 5 แบบ พร้อมแสดงคะแนนความเข้ากันได้ (Match Score %)
* 👗 **Outfit Detail & Personalized Tips:** แสดงชิ้นส่วนเสื้อผ้า (Top, Bottom, Shoes...) พร้อมวงกลมตัวอย่างสี (Color Dot) และคำแนะนำสไตล์ลิสต์เฉพาะบุคคล
* 🗄️ **Digital Wardrobe:** บันทึก (Bookmark) ชุดที่ชอบลงตู้เสื้อผ้าส่วนตัว และลบออกได้ตลอดเวลา
* 🌙 **Material 3 & Dark Mode:** รองรับโหมดมืดด้วย Palette สีม่วง 4 เฉด (Midnight Plum, Royal Purple...) สบายตา

### ฝั่งผู้ดูแลระบบ (Admin Control Panel)
* 📊 **Dashboard & System Health:** การ์ดสถิติภาพรวมจำนวนชุด, สมาชิก, แอดมิน, สถิติตู้เสื้อผ้า, กราฟโอกาส/สี, และสถานะเซิร์ฟเวอร์
* 👗 **Outfit Management (CRUD):** เพิ่มชุดใหม่พร้อมชิ้นส่วนและคำแนะนำสไตล์ลิสต์, แก้ไขข้อมูล, และลบชุดแบบ Cascade Delete
* 👥 **User & Role Management:** ค้นหาผู้ใช้, สลับบทบาท (User <-> Admin), และลบผู้ใช้ พร้อมกฎป้องกันการปลดแอดมินคนสุดท้าย (Last Admin Protection)
* 🎨 **Lucky Colors Editor:** ดูและแก้ไขตารางสีมงคลทั้ง 7 วันผ่านหน้าต่าง Modal Dialog
* 🛡️ **Security Route Guard:** ป้องกันผู้ใช้ทั่วไปเข้าสู่หน้าจอแอดมินด้วย `AdminGuard` และ `requireAdmin` (HTTP 403 Forbidden)

---

## 🏗️ สถาปัตยกรรมระบบ (System Architecture)

ระบบใช้สถาปัตยกรรม **3-Tier Decoupled Architecture**:
```text
+-----------------------------------+        +-----------------------------------+
|      Flutter Mobile Client        |        |       REST API Server             |
|   (Android Emulator / Web)        |        |     Node.js + Express + TS        |
|                                   |  HTTP  |                                   |
|  screens/    <--- UI Layer        | =====> |  routes/      <--- URL Endpoints  |
|  providers/  <--- State (Provider)|  JSON  |  middleware/  <--- JWT Auth Check |
|  services/   <--- HTTP Client     |  +JWT  |  controllers/ <--- Business Logic |
|  models/     <--- Data Classes    |        |  utils/knex   <--- Connection Pool|
+-----------------------------------+        +-----------------+-----------------+
                                                               |
                                                               | SQL Query
                                                               v
                                             +-----------------------------------+
                                             |       MySQL Database (8.x)        |
                                             |           (styleme_app)           |
                                             | users / lucky_colors / outfits    |
                                             | outfit_items / styling_tips       |
                                             | user_wardrobe                     |
                                             +-----------------------------------+
```

---

## 🚀 วิธีการติดตั้งและการรันโปรเจกต์ (Getting Started)

### 1. ติดตั้งระบบหลังบ้าน (Backend Server)
```bash
# 1. เข้าสู่โฟลเดอร์เซิร์ฟเวอร์
cd serverapi_ts

# 2. ติดตั้ง Dependencies
npm install

# 3. ตั้งค่าสภาพแวดล้อม (.env)
# ตรวจสอบว่ามีฐานข้อมูล MySQL ชื่อ styleme_app ที่พอร์ต 3306 หรือ 3307

# 4. รัน Seeding ข้อมูลเริ่มต้น
npm run knex:seed:run

# 5. เริ่มต้นการทำงานของเซิร์ฟเวอร์
npm start
```

### 2. ติดตั้งและรันแอปพลิเคชัน (Flutter Client)
```bash
# 1. เข้าสู่โฟลเดอร์หลักของโปรเจกต์
cd min_project_styleme

# 2. ดาวน์โหลดแพ็กเกจ Flutter
flutter pub get

# 3. รันแอปพลิเคชัน
flutter run
```

---

## 🔑 บัญชีทดลองใช้งาน (Demo Accounts)

| บทบาท (Role) | อีเมล (Email) | รหัสผ่าน (Password) | สิทธิ์การเข้าถึง |
| :--- | :--- | :---: | :--- |
| **ผู้ดูแลระบบ (Admin หลัก)** | `style@me.com` | `password123` | เข้าถึงแผงควบคุม Admin Dashboard ได้ครบทุกฟังก์ชัน |
| **ผู้ดูแลระบบ (Admin สำรอง)** | `admin@styleme.com` | `password123` | สิทธิ์แอดมินสำหรับทดสอบกฎ Last Admin Protection |
| **ผู้ใช้งานทั่วไป (User)** | `test@example.com` | `password123` | ค้นหาชุด, ดูสีมงคล, บันทึกตู้เสื้อผ้าส่วนตัว |

---

## 👥 ผู้จัดทำ (Author)

* **ผู้จัดทำ:** 66122660114 น.ส. สหัทจุฑา ขัดแก้ว
* **รายวิชา:** 5673303 การพัฒนาโปรแกรมประยุกต์สำหรับอุปกรณ์เคลื่อนที่ขั้นสูง
* **อาจารย์ผู้สอน / ที่ปรึกษา:** ผศ.ศักดิ์ชัย ศรีมากรณ์
