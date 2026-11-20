# ТЗ: ядро запросов и локали

К исполнению. Схема продукта: [audio-to-piano-notes.md](audio-to-piano-notes.md). Сервис: `POST /v1/notes`. Новые языки — свои поисковые фразы, не перевод английской строки.

Фразы из подсказок Google (ноябрь 2026). Это не частотность в визитах.

## Список языков — 11, не двадцать

| Префикс | Язык | Статус |
|---|---|---|
| `/` (en) | английский | на сайте |
| `/ru/` | русский | на сайте |
| `/de/` | немецкий | на сайте |
| `/pl/` | польский | на сайте |
| `/es/` | испанский | на сайте |
| `/pt/` | португальский (Бразилия) | на сайте |
| `/ja/` | японский | на сайте |
| `/ko/` | корейский | на сайте |
| `/zh-tw/` | китайский традиционный | на сайте |
| `/zh-cn/` | китайский упрощённый | на сайте |
| `/vi/` | вьетнамский | на сайте |

Не берём: тайский, индонезийский, хинди, отдельный европейский португальский, французский, итальянский в этой волне.

## Фразы ядра

Заголовок страницы (title и h1) — колонка «В заголовок». «Рядом» — description и второй абзац.

| # | Страница | В заголовок | Рядом |
|---|---|---|---|
| 1 | `/` | audio to piano notes | audio to notes |
| 2 | `/song-to-notes/` | song to piano notes | song to notes |
| 3 | `/ru/` | аудио в ноты | аудио в ноты онлайн |
| 4 | `/ru/song-to-notes/` | песня в ноты | музыка в ноты |
| 5 | `/de/` | Audio in Noten | Audio in Noten umwandeln |
| 6 | `/de/song-to-notes/` | Lied in Noten | Musik in Noten umwandeln |
| 7 | `/pl/` | audio na nuty | mp3 na nuty |
| 8 | `/pl/song-to-notes/` | piosenka na nuty | nuty z nagrania |
| 9 | `/es/` | audio a notas de piano | convertir audio a notas de piano |
| 10 | `/es/song-to-notes/` | canción a notas musicales | canción a notas de piano |
| 11 | `/pt/` | áudio em notas de piano | converter áudio em partitura |
| 12 | `/pt/song-to-notes/` | música para partitura | mp3 para partitura |
| 13 | `/ja/` | 自動採譜 | 音源 楽譜化 |
| 14 | `/ja/song-to-notes/` | 耳コピ | mp3 楽譜 変換 |
| 15 | `/ko/` | 오디오 악보 변환 | mp3 악보 변환 |
| 16 | `/ko/song-to-notes/` | 노래 악보로 변환 | 자동 채보 |
| 17 | `/zh-tw/` | 扒譜 | 扒譜網站 |
| 18 | `/zh-tw/song-to-notes/` | 音檔轉譜 | — |
| 19 | `/zh-cn/` | 扒谱 | 自动扒谱 |
| 20 | `/zh-cn/song-to-notes/` | 音频转谱 | 音频转midi |
| 21 | `/vi/` | chuyển nhạc thành nốt | chuyển mp3 thành nốt nhạc |
| 22 | `/vi/song-to-notes/` | chuyển bài hát thành nốt nhạc | chuyển audio thành nốt nhạc |

В title и h1 не писать: sheet music, 五線譜, 五线谱, PDF, нотный лист как обещание экрана; голое `채보`; not angka; speech to text; karaoke. Где в запросе partitura / 악보 / 楽譜 / 谱 — в первом абзаце сказать: на экране клавиши, не лист.

## Автоопределение языка по стране

Скрипт [`web/assets/js/locale-by-country.js`](../web/assets/js/locale-by-country.js):

1. Страна из ` /cdn-cgi/trace` (поле `loc=`), запасной адрес — `https://www.cloudflare.com/cdn-cgi/trace`.
2. Страна → префикс (PL→pl, BR→pt, MX→es, JP→ja, …).
3. Редирект только если целевой язык уже есть на сайте. Живые: все 11 кодов в `LIVE` в том же скрипте. Учебник аккордов полный только у en/ru/de (`DEEP`); остальные при смене языка с `/chords/` попадают на свою главную.
4. Выбор в переключателе пишет `localStorage.mn_lang` — дальше страна не перебивает выбор.
5. Без сохранённого выбора: один раз за сессию (метка в `sessionStorage`) подставить язык страны, если он живой и путь другой.

Переключатель и снятие префикса пути: все 11 кодов в [`web/assets/js/chords-shared.js`](../web/assets/js/chords-shared.js). В выпадающем списке — все 11 языков (скрываются только если нет в `LIVE`).

## Страницы (когда делаем локали)

На каждом языке: главная с загрузкой файла + `/song-to-notes/`. Один скрипт [`web/assets/js/page-audio-to-piano-notes.js`](../web/assets/js/page-audio-to-piano-notes.js). Учебник `/chords/…` на новые языки не переводить — ссылка на английский урок. На EN, RU, DE карточки аккордов остаются под формой.

## Не делать

- Не раздувать список до ~20 языков.
- Не обещать нотный лист, если на экране только клавиатура.
- Не трогать Docker-выкладку API, пока нет машины.
