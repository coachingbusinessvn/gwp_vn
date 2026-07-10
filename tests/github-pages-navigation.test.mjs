import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const programmePages = [
  'Khai_Van_Hieu_Suat_Thuc_Chien.dc.html',
  'Khai_Van_Quan_Tri_Chuyen_Nghiep.dc.html',
  'Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.dc.html',
];

async function hrefsFor(file) {
  const html = await readFile(file, 'utf8');
  return [...html.matchAll(/<a\b[^>]*\bhref="([^"]+)"/g)].map((match) => match[1]);
}

test('internal page links are relative to the GitHub Pages project path', async () => {
  const homeHrefs = await hrefsFor('index.html');
  const expectedProgrammeHrefs = programmePages.map((page) => `./${page}`);

  for (const href of expectedProgrammeHrefs) {
    assert.ok(homeHrefs.includes(href), `index.html must link to ${href}`);
  }

  for (const page of programmePages) {
    const hrefs = await hrefsFor(page);
    assert.ok(hrefs.includes('./index.html'), `${page} must link back to ./index.html`);
  }
});
