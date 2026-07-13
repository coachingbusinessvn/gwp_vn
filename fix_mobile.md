# Fix Mobile — GoWise Partners

Kết quả kiểm thử bản mobile toàn bộ website, tập trung vào lỗi layout và các rủi ro đặc thù trên **iOS Safari**.

## Phương pháp & phạm vi test

- **Công cụ:** trình duyệt tích hợp của Claude (Chromium), viewport mobile **375 × 812** (iPhone X/11/12/13 mini logical size).
- **Server:** `python3 -m http.server 8777` (config `.claude/launch.json`).
- **Đã đo bằng script tại runtime:** horizontal overflow (element bị cắt khỏi mép phải), grid track vượt container, font-size của input, tap target size, font quá nhỏ, sticky + backdrop-filter.
- **Lưu ý quan trọng về iOS:** Chromium **không mô phỏng 100%** hành vi iOS Safari. Các mục gắn nhãn `[iOS – cần test máy thật]` được kết luận từ CSS/computed style (bằng chứng chắc chắn) nhưng cần xác nhận trên iPhone thật (ưu tiên Safari iOS 16–18).

Các trang đã test:
1. `index.html` (Trang chủ)
2. `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html`
3. `Khai-Van_Quan_Tri_Chuyen_Nghiep.html`
4. `Khai_Van_Hieu_Suat_Thuc_Chien.html` (reference implementation)
5. `Lien_He.html`

---

## Tổng kết mức độ ưu tiên

| # | Lỗi | Trang | Mức độ |
|---|-----|-------|--------|
| 1 | Input form font-size 14.5px → iOS tự zoom khi focus | Lien_He | 🔴 Cao (iOS) |
| 2 | Card coach `300px 1fr` không stack → tràn ngang, card rỗng cao ~1400px | Quan_Tri | 🔴 Cao |
| 3 | Heading hardcode `width:802px` → chữ bị cắt, không xuống dòng | Thuc_Chien | 🔴 Cao |
| 4 | Form card `.lh-grid` tràn mép phải (grid `1fr` = min-content) | Lien_He | 🔴 Cao |
| 5 | Hero grid `1.18fr 0.82fr` + grid override dùng `1fr` (thiếu `minmax(0,1fr)`) | Quan_Tri | 🟠 Trung bình |
| 6 | Sticky header + `backdrop-filter: blur` → giật/lag khi scroll | Tất cả | 🟠 Trung bình (iOS) |
| 7 | Ảnh trang trí hero + badge "5★" bị cắt ~15px mép phải | Chuyen_Gia, Thuc_Chien | 🟡 Thấp |
| 8 | Tap target < 44px (link social/phone/email ở footer) | Tất cả (footer) | 🟡 Thấp |
| 9 | Font < 12px (eyebrow/label 9–11px) | Tất cả | 🟡 Thấp |
| 10 | `.gp-reveal`/`.rv` bắt đầu `opacity:0`, không có fallback nếu JS lỗi | Tất cả | 🟡 Thấp |
| 11 | Lỗi chính tả "Managenment" → "Management" | index | ⚪ Trivial |

---

## Lỗi đặc thù iOS (ưu tiên theo yêu cầu)

### [iOS-1] 🔴 Input form 14.5px làm Safari tự động zoom khi focus — `Lien_He.html`
- **Bằng chứng:** tất cả input/select/textarea của form đều có `font-size: 14.5px` (< 16px). iOS Safari **luôn phóng to trang** khi focus vào input có font < 16px, sau đó không tự thu lại → trải nghiệm nhập liệu rất khó chịu.
- **Ảnh hưởng:** ô Họ tên, SĐT, Email, Công ty (`name`, `phone`, `email`, `company`), `<select>` chương trình, `<textarea>` lời nhắn.
- **Fix:** đặt `font-size: 16px` cho tất cả control của form ở mobile (có thể giữ 14.5px ở desktop qua media query).
  ```css
  @media (max-width: 560px) {
    #... input, #... select, #... textarea { font-size: 16px; }
  }
  ```

### [iOS-2] 🟠 Sticky header + `backdrop-filter: blur(14px)` gây giật khi scroll — `Header.dc.html:30`
- **Bằng chứng:** header `position: sticky` + `backdrop-filter: blur(14px)` (đã có `-webkit-` prefix — tốt). Trong khi test, lệnh cuộn chuột **liên tục time-out 30s** trên nhiều trang → dấu hiệu repaint nặng mỗi frame scroll. Đây đúng là mẫu lỗi jank/flicker nổi tiếng của backdrop-filter trên iOS Safari.
- **DOM không bị freeze** (đã xác minh: cuộn bằng JS `scrollTop` với `scroll-behavior:auto` hoạt động 100%). Đây là vấn đề **hiệu năng/độ mượt**, không phải kẹt scroll.
- **Cần test máy thật.** Nếu iPhone bị giật: giảm blur (`blur(8px)`), hoặc thêm `transform: translateZ(0)`/`will-change`, hoặc bỏ backdrop-filter thay bằng nền mờ đặc (`rgba(7,18,31,0.94)`).
- **Liên quan:** `html { scroll-behavior: smooth }` (index.html:45) kết hợp blur nặng có thể càng stutter.

### [iOS-3] ✅ 100vh — KHÔNG có vấn đề
- Đã quét: **không có** element nào dùng `100vh`/`min-height:100vh`. Hero dùng chiều cao px cố định → không dính lỗi thanh địa chỉ iOS. (Vẫn nên xác nhận hero không bị hụt trên máy thật.)

---

## Chi tiết theo trang

### 1. `index.html` — Trang chủ ✅ Về cơ bản tốt
- **Không** horizontal overflow (docW = 375). Nav mobile (hamburger + submenu ĐÀO TẠO) hoạt động đúng.
- Các section (Hero, Stats 13+/2100+/300+, Trusted-by, About, Solutions, Blog, Footer) render tốt, stack gọn.
- **Nhỏ:** chevron `▼` của submenu không xoay khi mở (UX nit). Typo "Certified Strategic Manage**n**ment Coach" → "Management" (mục #11).

### 2. `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.html` ✅ Tốt, 1 lỗi nhỏ
- Hero, CTA, các section stack tốt. Không có grid overflow.
- **🟡 Lỗi nhỏ:** khối ảnh hero (coach photo) + badge **"5★ TIÊU CHUẨN TỔ CHỨC"** dùng absolute positioning tuned cho desktop → **cắt ~15px** ở mép phải trên mobile. Vòng tròn trang trí cũng tràn nhẹ. Không ảnh hưởng nội dung, chỉ mất thẩm mỹ.

### 3. `Khai-Van_Quan_Tri_Chuyen_Nghiep.html` 🔴 Nhiều lỗi nhất
- Runtime audit: **65 element bị cắt** khỏi mép phải, nhiều grid tràn.
- **🔴 [P3-a] Card coach `grid-template-columns: 300px 1fr` không stack** — dòng **360** và **398**. Media query mobile (dòng 58–72) chỉ override `repeat(N)`, `1fr 1fr`, `210px 1fr` — **bỏ sót `300px 1fr`**. Hậu quả (đã chụp xác nhận): card "HEAD OF MANAGEMENT COACH": ảnh coach (cột 300px) tràn khỏi mép phải, cột chữ + badge "HPC / High Performance Coach" **bị cắt mất khỏi màn hình**, và card cao ~1400px **gần như rỗng** phần dưới. Card "ICF PCC" (dòng 398) lỗi tương tự.
  - **Fix:** thêm override ở `@media (max-width: 620px)`:
    ```css
    #mc-root [style*="300px 1fr"] { grid-template-columns: minmax(0,1fr) !important; }
    ```
- **🟠 [P3-b] Grid override dùng `1fr` thay vì `minmax(0,1fr)`** — dòng 64, 71. `1fr` = `minmax(auto,1fr)` nên track vẫn phồng theo min-content của con → còn 1 grid resolve ra `359px` trong container 311px (section "BỐI CẢNH"). Đổi tất cả `1fr` trong override thành `minmax(0,1fr)`.
- **🟠 [P3-c] Hero `grid-template-columns: 1.18fr 0.82fr`** — dòng **85** — không có override mobile → 2 cột chật trên mobile. Thêm rule stack về 1 cột ở breakpoint mobile.

### 4. `Khai_Van_Hieu_Suat_Thuc_Chien.html` 🔴 1 lỗi rõ (reference page)
- Nhìn chung sạch (chỉ 2 element overflow), grid audit không lỗi — chứng tỏ page 2/3 là "regression" so với page này.
- **🔴 [P4-a] Heading hardcode kích thước** — dòng **240**:
  ```html
  <h2 style="...; width: 802px; height: 69px">Dành cho người dẫn dắt sự thay đổi.</h2>
  ```
  `width: 802px` + `height: 69px` (artifact export từ design tool) → chữ **không xuống dòng, bị cắt** thành "Dành cho người dẫn dắt sự th…" trên mobile (đã chụp xác nhận).
  - **Fix:** xóa `width: 802px; height: 69px` (hoặc đổi thành `max-width: 100%`, bỏ `height`). Kiểm tra thêm các heading khác export kèm `width/height` px cứng.
- **🟡** Cùng lỗi ảnh hero clip ~15px như page 2 (mục #7).

### 5. `Lien_He.html` 🔴 Form card tràn + input zoom iOS
- **🔴 [P5-a] Form card tràn mép phải** — dòng **83–86**. `.lh-grid` ở ≤900px chuyển `grid-template-columns: 1fr` (dòng 59), nhưng `1fr` = `minmax(auto,1fr)` nên cột resolve ra **392px** trong container 327px → card "GỬI YÊU CẦU TƯ VẤN" bị **cắt mất viền/padding phải** (masked bởi `overflow-x:hidden`, không thấy scrollbar nhưng nội dung lệch).
  - **Đã verify fix tại runtime:** đổi `grid-template-columns: 1fr` → **`minmax(0, 1fr)`** (dòng 59) → card về đúng 327px, nằm gọn trong viewport. ✅
  - Nên kèm: giảm padding card `44px` → ~`22–24px` ở ≤560px (dòng 86) vì 44px×2 quá lớn trên màn 375px.
- **🔴 [P5-b] Input zoom iOS** — xem [iOS-1].

---

## Lỗi chung (mọi trang, dùng chung Header/Footer)

- **🟡 [G-1] Tap target < 44px** — footer social links (**LinkedIn/Facebook/YouTube ~16px cao**), link SĐT & email (~17–23px cao), submenu ĐÀO TẠO trong dropdown (~17px). Chuẩn Apple HIG là **tối thiểu 44×44px**. Tăng padding vùng chạm cho các link này.
- **🟡 [G-2] Font < 12px** — có text ở 9px, 10px, 10.5px, 11px, 11.5px (eyebrow/label letter-spacing). Cân nhắc nâng tối thiểu ≥ 11–12px cho dễ đọc trên mobile.
- **🟡 [G-3] Reveal không có fallback** — `.gp-reveal`/`.rv` bắt đầu `opacity:0`, chỉ hiện khi IntersectionObserver fire. Nếu JS (DC framework/`support.js`) lỗi hoặc chậm, **nội dung vô hình**. Đã thấy nội dung trống khi scroll nhanh (bình thường hiện lại sau ~1s). Nên thêm fallback: `<noscript>` hoặc class `.no-js` để `opacity:1`.

---

## Task list — trạng thái

Đã sửa trên branch `fix/mobile-layout-ios`, verify lại trong trình duyệt ở 375px (và desktop 1280px không regression).

- [x] **T1** `Lien_He.html` — `.lh-grid` ≤900px: `1fr` → `minmax(0, 1fr)` — *verified: card 392→327px, right 351 ≤ 375*
- [x] **T2** `Lien_He.html` — `@media (max-width:560px)` input/select/textarea `font-size:16px` — *verified: 14.5→16px, hết zoom iOS*
- [x] **T3** `Khai-Van_Quan_Tri_Chuyen_Nghiep.html` — thêm `[style*="300px 1fr"]` → `minmax(0,1fr)` (dòng 64) — *verified: card coach stack đúng, 300px→221px*
- [x] **T4** `Khai_Van_Hieu_Suat_Thuc_Chien.html:240` — xóa `width:802px; height:69px` → `max-width:100%` — *verified: heading 802→311px, wrap đúng*
- [x] **T5** `Khai-Van_Quan_Tri_Chuyen_Nghiep.html:64,71` — grid override `1fr` → `minmax(0,1fr)` — *verified: clippedCount 65→0, gridOverflow 3→0*. Hero `1.18fr` đã được bắt sẵn ở dòng 62 (không cần thêm).
- [x] **T6** `Lien_He.html` — card padding 44px → 28/22px ở ≤560px (thêm class `.lh-form-card`) — *verified*
- [x] **T7** Xóa artifact `width×height` px trên wrapper chữ: `Thuc_Chien.html:238` (`width:692px;height:109px`) + `:240`. Các `width×height` px còn lại đều là element vuông (vòng tròn/ảnh/icon) — giữ nguyên.
- [ ] **T8** `Header.dc.html:30` — **CHƯA sửa, cần test máy iOS thật trước** (đổi `backdrop-filter` ảnh hưởng brand đang locked). Nếu giật: giảm `blur(14px)`→`blur(8px)` hoặc bỏ, thay nền mờ đặc.
- [x] **T9** `Footer.dc.html` — tăng vùng chạm link ≤820px — *verified: social 16→40px cao, ecosystem 17→35px*
- [~] **T10** **Không sửa (không áp dụng):** trang render bằng DC framework — không JS thì không có DOM để hiện; trường hợp thiếu IntersectionObserver đã được code xử lý (`!('IntersectionObserver' in window)` → hiện hết).
- [x] **T11** `index.html:192` — "Managenment" → "Management" — *fixed*

### ⚠️ Lưu ý sửa file `.dc.html`
Header/Footer là partial `.dc.html` được `<dc-import>` nạp và `fix-dc.sh` xử lý. Sửa vào `Header.dc.html`/`Footer.dc.html`, sau đó chạy lại `fix-dc.sh`. Các trang top-level (`*.html`) sửa trực tiếp — nhưng nếu chúng được sync từ Claude Design (xem `.claude/design-sync.json`), cần đồng bộ ngược để tránh bị ghi đè khi `/design-sync`.

### Cần verify trên iPhone thật (Safari iOS 16–18)
- iOS-1 (zoom input), iOS-2 (giật header blur), độ mượt scroll tổng thể, hero không bị hụt do thanh địa chỉ động.
