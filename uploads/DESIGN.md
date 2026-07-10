# GoWise Partners — Website Design System

**Phiên bản:** 1.0  
**Phạm vi:** Website corporate / consulting / strategic management coaching  
**Dựa trên:** logo monogram `GWP`, vòng mũi tên tăng trưởng, tone navy–gold cao cấp.

---

## 1. Brand direction

GoWise Partners cần thể hiện cảm giác **chiến lược, uy tín, sắc sảo và định hướng kết quả**. Website không nên giống một landing page bán hàng đại trà; nên có nhịp điệu của một boutique advisory firm: ít màu, nhiều khoảng thở, typography sang, icon line-art chính xác, hình ảnh có chiều sâu.

### Từ khóa thị giác

- **Clarity:** bố cục rõ, hierarchy mạnh, CTA trực tiếp.
- **Strategy:** đường kẻ, grid, step flow, compass/arrow motif.
- **Growth:** mũi tên đi lên, đường dẫn, biểu đồ, hành trình leo núi.
- **Trust:** navy đậm, gold tiết chế, nội dung chuyên nghiệp.
- **Premium:** serif headline, spacing rộng, shadow mềm, không dùng gradient quá rực.

### Brand personality

GoWise Partners nói chuyện như một cố vấn cấp cao: bình tĩnh, có cấu trúc, định hướng hành động, không phô trương. Nội dung nên dùng các cụm như: strategic clarity, measurable impact, execution discipline, leadership alignment, sustainable growth.

---

## 2. Logo usage

### Logo files

| File | Mục đích |
|---|---|
| `assets/logo-primary.svg` | Logo đầy đủ trên nền sáng hoặc nền trong suốt |
| `assets/logo-on-navy.svg` | Logo đầy đủ tối ưu trên nền navy |
| `assets/mark.svg` | Symbol độc lập trên nền sáng |
| `assets/mark-on-navy.svg` | Symbol độc lập trên nền navy |

### Clear space

Dùng chiều cao của ký tự **G** trong wordmark hoặc khoảng 1/2 chiều cao symbol làm vùng an toàn tối thiểu xung quanh logo.

```text
Minimum clear space = 0.5x mark height
```

### Kích thước tối thiểu

| Biến thể | Desktop | Mobile |
|---|---:|---:|
| Full logo | 160 px wide | 132 px wide |
| Mark/icon | 40 px | 32 px |
| Favicon | 32 px / 16 px | 32 px / 16 px |

### Không nên dùng

- Không đổi logo sang màu xanh sáng, đỏ, tím hoặc màu accent ngoài hệ màu.
- Không đặt logo gold trên nền vàng/kem nhạt thiếu tương phản.
- Không thêm stroke, glow hoặc drop shadow cứng.
- Không bóp ngang/dọc logo.
- Không tách wordmark khỏi tagline trừ khi dùng bản symbol riêng.

---

## 3. Color system

Hệ màu chính lấy từ mockup: **deep navy** làm nền chiến lược, **metallic gold** làm điểm nhấn, **ivory** cho vùng nội dung sáng.

### Core palette

| Token | Hex | Tailwind class | Vai trò |
|---|---|---|---|
| Navy 950 | `#07121F` | `bg-gp-navy-950` | Nền hero / footer / section tối |
| Navy 900 | `#0D1B2A` | `bg-gp-navy-900` | Nền chính tối |
| Navy 800 | `#12304C` | `bg-gp-navy-800` | Card tối / hover |
| Navy 700 | `#18395A` | `bg-gp-navy-700` | Border / trạng thái active |
| Gold 300 | `#D7B16E` | `text-gp-gold-300` | Highlight / CTA |
| Gold 400 | `#C9A668` | `bg-gp-gold-400` | Button chính |
| Gold 500 | `#B98A48` | `border-gp-gold-500` | Border / icon |
| Gold 600 | `#A87636` | `text-gp-gold-600` | Accent trên nền sáng |
| Ivory | `#F7F1E7` | `bg-gp-ivory` | Nền section sáng |
| Porcelain | `#F5F7FA` | `bg-gp-porcelain` | Card sáng / background phụ |
| Mist | `#D9E0E7` | `text-gp-mist` | Body text trên nền tối |
| Slate | `#8193A4` | `text-gp-slate` | Text phụ |

### Tỷ lệ màu khuyến nghị

- Navy / dark surface: **55–65%**
- Ivory / light surface: **25–35%**
- Gold accent: **5–10%**
- White / grey utility: phần còn lại

### Quy tắc tương phản

- Text chính trên nền navy: dùng `text-white` hoặc `text-gp-porcelain`.
- Text phụ trên nền navy: dùng `text-gp-mist` hoặc `text-gp-slate-200`.
- Gold chỉ nên dùng cho CTA, icon, line, label hoặc một phần headline.
- Không dùng gold cho đoạn body dài.

---

## 4. Typography

### Font stack

| Vai trò | Font | Tailwind token |
|---|---|---|
| Heading | Playfair Display / Cormorant Garamond / Georgia | `font-serif` |
| Body/UI | Montserrat / Inter / system-ui | `font-sans` |
| Numeric/metrics | Montserrat / Inter | `font-sans tabular-nums` |

### Type scale

| Level | Desktop | Mobile | Class gợi ý |
|---|---:|---:|---|
| Hero H1 | 72–88 px | 44–52 px | `gp-display` |
| Section H2 | 44–56 px | 34–40 px | `gp-h2` |
| Card H3 | 22–28 px | 20–24 px | `gp-h3` |
| Body lead | 18–21 px | 17–18 px | `gp-lead` |
| Body | 15–17 px | 15–16 px | `text-base leading-7` |
| Eyebrow | 11–12 px | 11 px | `gp-eyebrow` |

### Heading style

Headline nên ngắn, có nhịp 2 dòng. Cho phép dùng gold để nhấn 1 cụm quan trọng.

Ví dụ:

```html
<h1 class="gp-display">
  Clarity. Strategy. Growth.
  <span class="text-gp-gold-300">That Lasts.</span>
</h1>
```

---

## 5. Layout system

### Grid

- Container desktop: `max-w-7xl`, padding ngang `px-6` hoặc `px-8`.
- Hero desktop: 12-column logic, copy chiếm 5–6 cột, visual chiếm 5–6 cột.
- Section cards: 3 columns desktop, 2 columns tablet, 1 column mobile.
- Mobile: ưu tiên vertical flow; CTA full-width khi cần.

### Spacing

| Token | Giá trị | Dùng cho |
|---|---:|---|
| `space-3` | 12 px | gap nhỏ, icon/text |
| `space-5` | 20 px | card nội dung |
| `space-8` | 32 px | block spacing |
| `space-12` | 48 px | section internal |
| `space-20` | 80 px | section padding mobile/tablet |
| `space-28` | 112 px | section padding desktop |

### Border radius

- Button: `rounded-none` hoặc `rounded-sm` để giữ cảm giác corporate.
- Card: `rounded-2xl` cho website hiện đại, nhưng border sắc vẫn nên có.
- Image/card lớn: `rounded-[1.5rem]`.

---

## 6. Components

### Header

Header nên trong suốt hoặc navy rất đậm, có border dưới mảnh. Logo bên trái, nav ở giữa/phải, CTA gold bên phải.

**Desktop:**

```html
<header class="gp-container flex h-24 items-center justify-between">
  <a class="flex items-center gap-3" href="/">
    <img src="/assets/mark-on-navy.svg" class="h-11 w-11" alt="">
    <span class="font-serif text-xl text-white">GoWise Partners</span>
  </a>
  <nav class="hidden items-center gap-9 lg:flex">...</nav>
  <a class="gp-btn gp-btn-sm" href="#contact">Book a call</a>
</header>
```

### Buttons

| Component | Class | Mục đích |
|---|---|---|
| Primary | `gp-btn` | CTA chính |
| Secondary dark | `gp-btn-secondary-dark` | CTA trên nền navy |
| Secondary light | `gp-btn-secondary-light` | CTA trên nền sáng |
| Text link | `gp-text-link` | Link trong card/article |

CTA nên dùng động từ rõ: **Book a strategy session**, **Explore services**, **Start diagnostic call**.

### Cards

- Card tối: nền navy 900/800, border gold opacity thấp, icon gold.
- Card sáng: nền porcelain/white, border navy opacity thấp, shadow mềm.
- Không nên dùng card nhiều màu.

### Service card anatomy

1. Icon line-art gold
2. Service name
3. Short benefit statement
4. Text link

### Approach step

Dùng 4 bước:

1. Discover
2. Define
3. Design
4. Deliver

Mỗi bước có số thứ tự, icon tròn, connector line ngang trên desktop; stack dọc trên mobile.

---

## 7. Page architecture

### Homepage recommended order

1. **Hero:** headline mạnh + CTA + logo mark/mountain/strategy visual.
2. **Trust bar:** logo khách hàng hoặc nhóm đối tượng phục vụ.
3. **About:** định vị firm + metrics ngắn.
4. **Services:** 3–4 service cards.
5. **Approach:** process 4 bước.
6. **Outcomes:** kết quả cụ thể: clarity, alignment, execution, growth.
7. **Insights:** 3 bài viết hoặc resource cards.
8. **CTA band:** đặt lịch trao đổi.
9. **Footer:** logo, nav, contact, legal.

### Website pages

| Page | Mục tiêu |
|---|---|
| `/` | Chốt định vị và chuyển đổi lead |
| `/about` | Tăng niềm tin, founder story, principles |
| `/services` | Giải thích offer và engagement model |
| `/approach` | Cho thấy phương pháp có cấu trúc |
| `/insights` | Thought leadership |
| `/contact` | Đặt lịch / form lead |

---

## 8. Imagery direction

### Hình ảnh nên dùng

- Executive coaching session, boardroom, strategy workshop.
- Mountain/path/growth metaphor, nhưng xử lý tinh tế.
- Dashboard, decision map, planning wall, leadership offsite.
- Ánh sáng cinematic, contrast cao, tone lạnh hoặc neutral.

### Hình ảnh nên tránh

- Stock photo quá cười, handshake cliché.
- Ảnh quá sáng hoặc màu neon.
- Ảnh teamwork generic không có cảm giác executive.
- Ảnh minh họa cartoon, 3D quá trẻ.

### Overlay

Trên nền ảnh tối, dùng overlay:

```css
linear-gradient(90deg, rgba(7,18,31,.88), rgba(7,18,31,.48), rgba(7,18,31,.18))
```

---

## 9. Iconography

Icon style: line-art, stroke 1.5–2 px, góc tròn vừa phải, màu gold. Các motif phù hợp:

- Compass / direction
- Upward arrow
- Chess knight / strategic move
- Bar chart / measurable growth
- Diamond / clarity
- Team / leadership
- Target / execution

Tailwind class gợi ý:

```html
<div class="gp-icon-wrap">
  <svg class="h-7 w-7" ...></svg>
</div>
```

---

## 10. Motion guidance

Motion nên kín đáo, cao cấp:

- Button hover: dịch lên `-translate-y-0.5`, shadow gold nhẹ.
- Card hover: border gold rõ hơn, background navy sáng hơn 3–5%.
- Hero mark: có thể dùng slow pulse/float rất nhẹ, không xoay nhanh.
- Page reveal: fade + translate 12 px.

Không dùng bounce, neon glow, confetti hoặc animation quá nhiều.

---

## 11. Accessibility

- CTA phải có focus ring rõ: `focus-visible:ring-2 focus-visible:ring-gp-gold-300`.
- Tỷ lệ tương phản text trên nền navy phải đủ cao.
- Không dùng gold nhạt làm body text nhỏ trên nền trắng.
- Logo `img` nên có `alt="GoWise Partners"` nếu là logo link chính; nếu chỉ trang trí dùng `alt=""`.
- Section cần `id` rõ để nav anchor hoạt động.

---

## 12. Tailwind implementation

### Files trong pack

```text
DESIGN.md
README.md
package.json
postcss.config.cjs
tailwind.config.cjs
src/tailwind.css
src/tailwind.v4.css
examples/homepage.tailwind.html
assets/logo-primary.svg
assets/logo-on-navy.svg
assets/mark.svg
assets/mark-on-navy.svg
```

### Cách build Tailwind v3

```bash
npm install
npm run build:css
```

Output dự kiến:

```text
dist/gowise.css
```

### Cách dùng Tailwind v4

Dùng file:

```text
src/tailwind.v4.css
```

File này đã có `@import "tailwindcss";`, `@theme` tokens và cùng component layer.

### Component classes chính

| Class | Mục đích |
|---|---|
| `gp-container` | Container chuẩn |
| `gp-section-dark` | Section nền navy |
| `gp-section-light` | Section nền ivory |
| `gp-display` | Hero headline |
| `gp-h2` | Section headline |
| `gp-h3` | Card headline |
| `gp-lead` | Lead paragraph |
| `gp-eyebrow` | Label uppercase |
| `gp-btn` | Button chính |
| `gp-btn-secondary-dark` | Button phụ trên nền tối |
| `gp-btn-secondary-light` | Button phụ trên nền sáng |
| `gp-card-dark` | Card tối |
| `gp-card-light` | Card sáng |
| `gp-icon-wrap` | Icon container |
| `gp-text-link` | Link text accent |
| `gp-divider` | Divider mảnh |
| `gp-gold-gradient` | Gradient gold |
| `gp-navy-texture` | Nền navy có texture nhẹ |

---

## 13. Content style

### Voice

- Direct, senior, strategic.
- Không dùng ngôn ngữ quá quảng cáo.
- Tập trung vào kết quả vận hành và quyết định tốt hơn.

### Example copy

**Hero headline:**

> Clarity. Strategy. Growth. That Lasts.

**Hero body:**

> We partner with leaders and organizations to turn vision into actionable strategies, stronger execution, and sustainable results.

**CTA:**

> Book a strategy session

**Service statement:**

> Focused advisory and coaching engagements that connect strategy, leadership, and execution into one practical management system.

---

## 14. QA checklist trước khi dev handoff

- [ ] Logo dùng đúng phiên bản nền sáng/tối.
- [ ] CTA primary xuất hiện ở hero, nav và CTA cuối trang.
- [ ] Mobile hero không bị quá cao hoặc che CTA.
- [ ] Gold accent không vượt 10% tổng giao diện.
- [ ] Text body trên nền tối đủ tương phản.
- [ ] Card grid chuyển 3 → 2 → 1 cột đúng breakpoint.
- [ ] Font fallback hoạt động nếu Google Fonts chưa load.
- [ ] Link, button, form có focus state.
- [ ] Image có alt text khi mang ý nghĩa nội dung.
- [ ] Không để placeholder client logo/số liệu trong bản production.
