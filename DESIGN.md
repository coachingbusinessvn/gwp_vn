# GoWise Partners — Design System (v2.0, locked)

**Scope:** website corporate / consulting / strategic management coaching.
**Tokens are FROZEN** — reuse them verbatim on every new page. Do not invent new colors, fonts, or radii.

Files in this pack:
- `brand/gowise.css` — framework-free brand stylesheet (link it directly).
- `brand/tailwind.config.js` — Tailwind v3 config + Play-CDN `extend` object.
- Reference build: `Khai_Van_Hieu_Suat_Thuc_Chien.html`.

---

## 1. Brand direction

Boutique advisory firm, not a mass landing page: **strategic, uy tín, sắc sảo, định hướng kết quả.** Ít màu · nhiều khoảng thở · serif headline sang · icon line-art chính xác · hình ảnh cinematic có chiều sâu. Voice: cố vấn cấp cao — bình tĩnh, có cấu trúc, không phô trương.

Visual keywords: **Clarity · Strategy · Growth · Trust · Premium.** Motif: compass, mũi tên đi lên, grid/step-flow, đường dẫn.

---

## 2. Color (frozen)

| Token | Hex | CSS var / Tailwind | Vai trò |
|---|---|---|---|
| Navy 950 | `#07121F` | `--gp-navy-950` / `gp-navy-950` | Hero, footer, nền tối nhất |
| Navy 900 | `#0D1B2A` | `--gp-navy-900` / `gp-navy-900` | Nền tối chính, card tối |
| Navy 800 | `#102338` | `--gp-navy-800` / `gp-navy-800` | Card hover / raised |
| Navy 700 | `#12304C` | `--gp-navy-700` / `gp-navy-700` | Tâm radial glow / accent |
| Gold 200 | `#E7D0A2` | `--gp-gold-200` / `gp-gold-200` | Highlight chữ, nhấn headline |
| Gold 300 | `#D7B16E` | `--gp-gold-300` / `gp-gold-300` | Link, đỉnh gradient CTA |
| **Gold 400** | `#C9A668` | `--gp-gold-400` / `gp-gold-400` | **Primary** — button, icon, line |
| Gold 500 | `#B98A48` | `--gp-gold-500` / `gp-gold-500` | Border, icon stroke |
| Gold 600 | `#A87636` | `--gp-gold-600` / `gp-gold-600` | Accent trên nền sáng |
| Ivory | `#F7F1E7` | `--gp-ivory` / `gp-ivory` | Nền section sáng, chữ heading trên tối |
| Porcelain | `#F5F7FA` | `--gp-porcelain` | Card sáng phụ |
| Mist | `#D9E0E7` | `--gp-mist` / `gp-mist` | Body trên nền tối |
| Slate | `#8193A4` | `--gp-slate` / `gp-slate` | Text phụ trên nền tối |
| Slate deep | `#4C6076` | `--gp-slate-deep` | Footer legal / faint |
| Ink soft | `#45505C` | `--gp-ink-soft` | Body trên nền sáng |

**Tỷ lệ:** navy 55–65% · ivory 25–35% · **gold ≤ 10%** (chỉ CTA, icon, line, label, 1 cụm headline — không dùng gold cho body dài).

**Hairlines:** gold `rgba(201,166,104,.16)` (mờ) → `.40` (rõ); dark `rgba(13,27,42,.09)`.

**Gradients (2 duy nhất):** CTA `linear-gradient(180deg,#E7D0A2,#C9A668)` · Hero `radial-gradient(120% 90% at 78% 22%,#12304C,#0D1B2A 42%,#07121F)`. Không dùng gradient rực nào khác.

---

## 3. Typography (frozen)

- **Heading:** Playfair Display — weight 500 cho H1/H2, 600 cho H3, italic cho quote.
- **Body/UI:** Montserrat — 400/500/600/700.
- Google Fonts link (bắt buộc ở mọi trang):
  ```html
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&family=Montserrat:wght@400;500;600;700&display=swap" rel="stylesheet">
  ```

| Cấp | Desktop | Class | Ghi chú |
|---|---:|---|---|
| Hero H1 | 62px (clamp 44) | `.gp-display` | serif 500, line 1.06, tracking −.01em |
| Section H2 | 44px (clamp 34) | `.gp-h2` | serif 500, line 1.14 |
| Card H3 | 27px (clamp 22) | `.gp-h3` | serif 600 |
| Lead | 18px | `.gp-lead` | sans, line 1.7, `--gp-mist` |
| Body | 16px | `.gp-body` | sans, line 1.8 |
| Eyebrow | 12px | `.gp-eyebrow` | sans 600, UPPER, tracking .24em, gold-400 |

Nhấn 1 cụm trong headline bằng `.gp-accent` (gold-200). Trên nền ivory dùng `.gp-eyebrow--light` (gold-600).

---

## 4. Layout

- Container: `.gp-container` = `max-width:1200px; padding:0 32px`.
- Section: `.gp-section` = `padding:108px 0` (band nhỏ hơn tuỳ nội dung; CTA ~118px).
- Nhịp nền xen kẽ: **tối → tối hơn → sáng (ivory)**. Tối đa 1–2 section ivory cho phần đọc nặng; phần còn lại navy.
- Grid card: 3 cột desktop → 2 tablet → 1 mobile, `gap: 24px`.
- Ưu tiên flex/grid + `gap`, không dùng margin rời từng phần tử.

---

## 5. Components (dùng class trong `gowise.css`)

- **Header:** sticky, `rgba(7,18,31,.82)` + `backdrop-filter: blur(14px)`, border-dưới `--gp-line-gold`. Logo mark tròn trái + wordmark; nav giữa/phải; CTA gold `.gp-btn--sm` phải.
- **Buttons:** `.gp-btn` (gold gradient, hover nâng −2px + shadow gold) · `.gp-btn-outline` / `--light`. Radius vuông (giữ cảm giác corporate). CTA động từ rõ: “Đăng ký tham gia”, “Đặt lịch tư vấn”.
- **Cards:** `.gp-card-dark` (navy 900, border gold mờ, hover nâng + navy-800) · `.gp-card-light` (white, border dark mờ, shadow mềm).
- **Hairline list:** `.gp-list` cho metrics/outcomes (khe 1px gold trên nền gold mờ).
- **Icon:** `.gp-icon-ring` (tròn, viền gold, stroke gold-400) · `.gp-icon-chip` (bo 14px, nền gold mờ, stroke gold-200). Xem §10 để render SVG đúng.
- **Stat/number:** `.gp-eyebrow-num` (Playfair 600, gold-200).

---

## 6. Trang & thứ tự khuyến nghị

`/` Hero → trust/metrics bar → Vấn đề → Giải pháp/năng lực → Kết quả → Đối tượng → Nội dung/module → CTA band → Footer.
Các trang khác: `/about` `/services` `/approach` `/insights` `/contact` — cùng bộ token, cùng nhịp nền, cùng component.

---

## 7. Hình ảnh

- **Nên:** coaching session, boardroom, strategy workshop, ánh sáng cinematic, contrast cao, tone lạnh/neutral. Motif compass/mũi tên tinh tế.
- **Tránh:** stock cười giả, handshake cliché, neon, teamwork generic, cartoon/3D trẻ.
- **Overlay trên ảnh tối:** `.gp-image-overlay` = `linear-gradient(90deg, rgba(7,18,31,.94), .82 38%, .34)`.
- Trong Design Component dùng `<image-slot>` (fillable) — điền `src` stock miễn phí (Pexels: no-attribution; Unsplash: **bắt buộc** `credit="Photo by NAME on Unsplash"` + `credit-href`).
- Asset trừu tượng on-brand có sẵn: `assets/logo-mark.png` (compass), `insight-1` (line chart), `insight-2` (network), `insight-3` (growth bars).

---

## 8. Iconography

Line-art, `stroke-width 1.5–2`, góc bo tròn, màu gold. Motif: compass, mũi tên lên, bar chart, target, diamond (clarity), team/leadership, lightbulb.

---

## 9. Motion (kín đáo, cao cấp)

- Button hover: `translateY(-2px)` + shadow gold. Card hover: border gold rõ hơn + navy sáng 3–5% + nâng nhẹ.
- Hero: mark float chậm (`gp-float`/`gp-float-slow`), vòng dẫn hướng xoay rất chậm (`gp-spin` 44s). Không xoay nhanh, không bounce/neon/confetti.
- Page reveal: fade + translate ~28px, stagger 70–80ms mỗi item.
- Number count-up khi cuộn tới (900ms, ease-out cubic).
- Luôn tôn trọng `prefers-reduced-motion`.

---

## 10. ⚠ Kỹ thuật render SVG icon trong Design Component

Hole `{{ }}` **không** render React-element, và `dangerouslySetInnerHTML` trên `<svg>` hỏng namespace. Cách đã chốt: lưu chuỗi `<svg>…</svg>` đầy đủ vào attribute `data-svg`, rồi inject bằng `innerHTML` khi mount (browser tự parse đúng SVG namespace):

```js
root.querySelectorAll('[data-svg]').forEach((el) => {
  const svg = el.getAttribute('data-svg');
  if (svg && el.childElementCount === 0) el.innerHTML = svg;
});
```
Template: `<div class="gp-icon-ring" data-svg="{{ item.icon }}"></div>`.

---

## 11. Scroll-reveal + count-up (snippet chuẩn)

`.gp-reveal` (+ `--l`/`--r`) có sẵn trong `gowise.css`. Kích hoạt trong `componentDidMount`:

```js
componentDidMount() { requestAnimationFrame(() => this.initAnim()); }
initAnim() {
  const root = document.getElementById('kv-root'); if (!root) return;
  root.querySelectorAll('[data-svg]').forEach((el)=>{ const s=el.getAttribute('data-svg'); if(s&&!el.childElementCount) el.innerHTML=s; });
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;
  root.querySelectorAll('[data-stagger]').forEach((g)=>{
    [...g.children].filter(c=>c.classList.contains('gp-reveal')).forEach((el,i)=>el.style.transitionDelay=(i*75)+'ms');
  });
  if (reduce || !('IntersectionObserver' in window)) {
    root.querySelectorAll('.gp-reveal').forEach(el=>el.classList.add('in'));
    root.querySelectorAll('[data-count]').forEach(el=>el.textContent=el.getAttribute('data-count')); return;
  }
  const io=new IntersectionObserver((es)=>es.forEach(e=>{if(e.isIntersecting){e.target.classList.add('in');io.unobserve(e.target);}}),{threshold:0.12,rootMargin:'0px 0px -6% 0px'});
  root.querySelectorAll('.gp-reveal').forEach(el=>io.observe(el));
  const cio=new IntersectionObserver((es)=>es.forEach(e=>{if(e.isIntersecting){this.countUp(e.target);cio.unobserve(e.target);}}),{threshold:0.6});
  root.querySelectorAll('[data-count]').forEach(el=>{el.textContent='0';cio.observe(el);});
}
countUp(el){const t=parseInt(el.getAttribute('data-count'),10)||0,d=900,s=performance.now();
  const f=(n)=>{const p=Math.min(1,(n-s)/d),e=1-Math.pow(1-p,3);el.textContent=String(Math.round(e*t));if(p<1)requestAnimationFrame(f);else el.textContent=String(t);};requestAnimationFrame(f);}
```

---

## 12. QA trước khi ship

- [ ] Chỉ dùng token màu/font trong §2–3; gold ≤ 10%.
- [ ] Font Google load; fallback serif/sans hoạt động.
- [ ] Nhịp nền tối/ivory hợp lý; container 1200px.
- [ ] CTA primary ở hero + nav + cuối trang; động từ rõ.
- [ ] Card grid 3→2→1 đúng breakpoint; hit target ≥ 44px.
- [ ] Icon render (đã inject `data-svg`); reveal + count-up chạy; tôn trọng reduced-motion.
- [ ] Ảnh có overlay khi đặt chữ; Unsplash có credit; không để placeholder số liệu/logo giả ở production.
- [ ] Link/button/focus state rõ; section có `id` cho anchor.
