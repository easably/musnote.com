# Поисковые фразы по языкам (ASO)

Не перевод EN строка-в-строку. В каждом языке — **как люди ищут** (подсказки Google / ядро сайта). Отсюда Name, Subtitle и Keywords в App Store Connect.

Источник фраз: [plans/tz-keyword-core-locales.md](../../plans/tz-keyword-core-locales.md). Готовые поля: [names.md](names.md), [locales/](locales/).

## Два имени (не путать)

| Где | Что видит человек |
|---|---|
| Магазин + поиск ОС (иконка на домашнем экране) | Локализованный **Name** из ASC / `CFBundleDisplayName` · на EN: **`Audio to Piano Notes - MusNote`** |
| Шапка списка файлов **внутри** приложения | Коротко **`MusNote`** (бренд на картинке) |

MusNote в конце Name — бренд; впереди всегда поисковая фраза языка.

## Как собирать поля

1. **Name** ≤ 30 — головной запрос языка + ` - MusNote`, если влезает. Если не влезает — укоротить фразу, не переносить бренд вперёд.
2. **Subtitle** ≤ 30 — соседний запрос (песня / mp3 / второй глагол), **без слов из Name**.
3. **Keywords** ≤ 100 — остальные поисковые слова языка через запятую, без пробелов после запятой, без повтора слов из Name и Subtitle.

В Name/Subtitle не обещать sheet music / нотный лист PDF.

## Пакет по языкам

### English (en-US, en-GB, en-AU, en-CA)

| Роль | Фраза |
|---|---|
| Ищут (голова) | audio to piano notes |
| Рядом | audio to notes · song to piano notes · song to notes |
| Ещё слова | midi, melody, solo, keyboard, recording, hum, tune, guitar, sheet, convert, wav, m4a, vocal, pitch, chord, sing, ear, mp3, transcriber |

**ASC:** Name `Audio to Piano Notes - MusNote` · Subtitle `Song & MP3 Transcriber`

### Русский (ru)

| Роль | Фраза |
|---|---|
| Ищут (голова) | аудио в ноты |
| Рядом | аудио в ноты онлайн · песня в ноты · музыка в ноты |
| Ещё слова | mp3, мелодия, пианино, конвертер, распознать, запись, midi, соло, wav, m4a, гитара, напеть, аккорд, клавиши |

**ASC:** Name `аудио в ноты - MusNote` · Subtitle `песня на клавиши`

### Deutsch (de-DE)

| Роль | Фраза |
|---|---|
| Ищут (голова) | Audio in Noten |
| Рядом | Audio in Noten umwandeln · Lied in Noten · Musik in Noten umwandeln |
| Ещё слова | midi, melodie, klavier, konverter, aufnahme, solo, transkribieren, mp3, wav, gitarre, akkord |

**ASC:** Name `Audio in Noten - MusNote` · Subtitle `Lied umwandeln MP3`  
Keywords: `midi,melodie,klavier,konverter,aufnahme,solo,transkribieren,wav,gitarre,akkord,mikrofon,musik,singen`

### Polski (pl)

| Роль | Фраза |
|---|---|
| Ищут (голова) | audio na nuty |
| Рядом | mp3 na nuty · piosenka na nuty · nuty z nagrania |
| Ещё слова | midi, melodia, pianino, konwerter, transkrypcja, solo, klawiatura, muzyka, wav, gitara |

**ASC:** Name `audio na nuty - MusNote` · Subtitle `piosenka z nagrania`

### Español (es-ES, es-MX)

Голова `audio a notas de piano` (22) + ` - MusNote` не влезает в 30 → в Name короче, **piano** уходит в Subtitle/Keywords.

| Роль | Фраза |
|---|---|
| Ищут (голова) | audio a notas de piano |
| Рядом | convertir audio a notas de piano · canción a notas musicales · canción a notas de piano |
| Ещё слова | midi, melodía, transcribir, grabación, teclado, partitura, mp3, piano, guitarra, solo |

**ASC:** Name `audio a notas - MusNote` · Subtitle `canción a piano MP3`

### Português Brasil (pt-BR)

Голова с «de piano» + MusNote не влезает → укоротить Name.

| Роль | Фраза |
|---|---|
| Ищут (голова) | áudio em notas de piano |
| Рядом | converter áudio em partitura · música para partitura · mp3 para partitura |
| Ещё слова | midi, melodia, converter, transcrever, gravação, teclado, piano, solo, wav |

На экране клавиши, не лист — в Subtitle не обещать partitura как PDF.

**ASC:** Name `áudio em notas - MusNote` · Subtitle `música e MIDI`

### 日本語 (ja)

| Роль | Фраза |
|---|---|
| Ищут (голова) | 自動採譜 |
| Рядом | 音源 楽譜化 · 耳コピ · mp3 楽譜 変換 |
| Ещё слова | midi, ピアノ, メロディ, 録音, wav, ギター, ハミング, 鍵盤, 変換 |

**ASC:** Name `自動採譜 - MusNote` · Subtitle `耳コピ AI無料`

### 한국어 (ko)

| Роль | Фраза |
|---|---|
| Ищут (голова) | 오디오 악보 변환 |
| Рядом | mp3 악보 변환 · 노래 악보로 변환 · 자동 채보 |
| Ещё слова | midi, 피아노, 변환기, 녹음, 솔로, 채보, 멜로디, 건반, 음원 |

**ASC:** Name `오디오 악보 변환 - MusNote` · Subtitle `노래 멜로디 추출`

### 繁體中文 (zh-Hant)

| Роль | Фраза |
|---|---|
| Ищут (голова) | 扒譜 |
| Рядом | 扒譜網站 · 音檔轉譜 |
| Ещё слова | mp3, midi, 鋼琴, 旋律, 轉換, 錄音, 哼唱, 鍵盤, 轉midi |

**ASC:** Name `扒譜 - MusNote` · Subtitle `音檔轉譜 AI`

### 简体中文 (zh-Hans)

| Роль | Фраза |
|---|---|
| Ищут (голова) | 扒谱 |
| Рядом | 自动扒谱 · 音频转谱 · 音频转midi |
| Ещё слова | mp3, midi, 钢琴, 旋律, 转换, 录音, 哼唱, 键盘, 音源 |

**ASC:** Name `扒谱 - MusNote` · Subtitle `音频转谱 AI`

### Tiếng Việt (vi)

Голова `chuyển nhạc thành nốt` + MusNote = 31 → убрать `chuyển `.

| Роль | Фраза |
|---|---|
| Ищут (голова) | chuyển nhạc thành nốt |
| Рядом | chuyển mp3 thành nốt nhạc · chuyển bài hát thành nốt nhạc · chuyển audio thành nốt nhạc |
| Ещё слова | mp3, piano, giai điệu, thu âm, bàn phím, midi, melody, converter, solo |

**ASC:** Name `nhạc thành nốt - MusNote` · Subtitle `bài hát sang MIDI`
