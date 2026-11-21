# Цвета и ролик ожидания

Источник цветов — `musnote.tokens.json`. После правки:

```bash
node scripts/build-tokens.js
```

Скрипт пишет `web/assets/css/design-tokens.css` и `vocal_note_monitor/lib/theme/musnote_tokens.g.dart`. Проверка, что копии не разъехались: `node scripts/build-tokens.js --check`.

Шрифты: Outfit для текста, Source Serif 4 для заголовков. Радиусы 8 / 12 / 20. Тени — мягкая тёмная и приподнятая зелёная.

Ролик ожидания — один файл без слов: `web/assets/anim/musnote-loading.json`. На сайте он показывается высотой 48 px (пропорция 400×160, ширина 120 px) рядом со строкой «Читаем ноты…». Цикл 4 секунды. Пересобирается так:

```bash
python3 design/loading-animation/lottie/build_lottie.py
```

Цвета и длина цикла берутся из этого JSON.
