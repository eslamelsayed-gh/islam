#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
يولّد lib/data/quran_texts.dart كاملاً (6236 آية + تفسير السعدي) من المصدر الرسمي:
  • الرسم العثماني:  https://api.quran.com/api/v4 (text_uthmani)
  • تفسير السعدي:    resource_id = 91
تحقق إلزامي: 6236 آية بالضبط وإلا يتوقف دون كتابة الملف.
يعالج آية «الم» (البقرة 1) وكل الآيات دون استثناء.
"""
import json, re, time, urllib.request
from pathlib import Path

API = 'https://api.quran.com/api/v4'
OUT = Path(__file__).resolve().parent.parent / 'lib' / 'data' / 'quran_texts.dart'

def api(path, retries=6):
    for i in range(retries):
        try:
            with urllib.request.urlopen(API + path, timeout=90) as r:
                return json.load(r)
        except Exception as e:
            if i == retries - 1:
                raise SystemExit(f'✗ فشل نهائي: {path}\nأعد التشغيل — الخادم متقطع أحياناً.\n{e}')
            time.sleep(3 * (i + 1))

def clean(s):
    if not s:
        return ''
    s = re.sub(r'<[^>]+>', '', s)
    return s.replace('\\"', '"').replace('\\', '').strip()

def dq(s):
    return s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')

verses, tafsir = {}, {}

for ch in api('/chapters')['chapters']:
    cid = ch['id']
    d = api(f'/verses/by_chapter/{cid}'
            f'?fields=text_uthmani,page_number,juz_number&per_page=400')
    for v in d['verses']:
        verses[v['verse_key']] = (
            cid, v['verse_number'], v['page_number'],
            v['juz_number'],
            v['text_uthmani'].strip())
    t = api(f'/tafsirs/91/by_chapter/{cid}?per_page=400')
    for row in t.get('tafsirs', []):
        tafsir[row['verse_key']] = clean(row['text'])
    print(f'سورة {cid:>3} ✓  آيات: {len(d["verses"]):>3}')

assert len(verses) == 6236, f'✗ عدد الآيات {len(verses)} ≠ 6236 — لم يُكتب الملف'
missing_tf = [k for k in verses if k not in tafsir]
print(f'⚠ تفسير غير متوفر من المصدر لـ {len(missing_tf)} آية (يُعرض «غير متاح»)')
print(f'✓ تحقق ناجح: {len(verses)} آية — من 1:1 إلى 114:6')

L = ['// ⚠️ ملف مولَّد آلياً من api.quran.com — لا تعدّله يدوياً',
     '// آخر توليد: tool/generate_quran_data.py', '',
     'class QuranVerse {',
     '  final int surah, ayah, page, juz;',
     '  final String text;',
     '  const QuranVerse(this.surah, this.ayah, this.page, this.juz, this.text);',
     "  String get key => '$surah:$ayah';", '}', '',
     'const kQuranVerses = <QuranVerse>[']
for k in sorted(verses, key=lambda x: tuple(map(int, x.split(':')))):
    s, a, p, j, t = verses[k]
    L.append(f'  QuranVerse({s}, {a}, {p}, {j}, \'{dq(t)}\'),')
L += ['];', '', 'const kSaadiTafsir = <String, String>{']
for k in sorted(tafsir, key=lambda x: tuple(map(int, x.split(':')))):
    L.append(f"  '{k}': '{dq(tafsir[k])}',")
L += ['};', '']
OUT.write_text('\n'.join(L), encoding='utf-8')
print(f'✅ اكتمل: {len(verses)} آية + {len(tafsir)} تفسيراً ← {OUT}')
