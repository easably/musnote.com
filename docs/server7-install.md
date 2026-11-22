# Повторная установка на server7

Две модели пробы живут только на server7, в своей папке. Контейнер нот `api/` тоже на server7 и слушает `127.0.0.1:8095`. server8 только пересылает порты 8095 и 8096.

Папка: `/home/admin2/musnote-separate`

| Что | Куда | Зачем своя копия |
|---|---|---|
| PyTorch `2.11.0+cu128` | venv этой папки | Видеокарта RTX 5070 Ti. Обычное колесо PyTorch её не видит, нужно CUDA 12.8 |
| Demucs `htdemucs_6s` | тот же venv, веса в кэш при первом запуске | Режет запись на 6 аудио: голос, пианино, гитара, ударные, бас, остальное |
| MuScriptor | отдельно, через `uvx`, не в этот venv | Ноты с уже отделённой дорожки. Веса CC BY-NC 4.0, только некоммерческие |

Перед установкой карта должна быть свободна. Сейчас её занимают чужие контейнеры. Остановка и подъём обратно:

```bash
cd /home/admin2/deploy/dict-api && docker compose -f docker-compose.external-vllm.yml stop
cd /home/admin2/deploy/qwen3-14b && docker compose stop
```

```bash
cd /home/admin2/deploy/qwen3-14b && docker compose start
cd /home/admin2/deploy/dict-api && docker compose -f docker-compose.external-vllm.yml start
```

## С нуля

На сервере, пользователь `admin2`:

```bash
sudo apt-get update
sudo apt-get install -y ffmpeg python3.12-venv
rm -rf /home/admin2/musnote-separate/venv
mkdir -p /home/admin2/musnote-separate/in /home/admin2/musnote-separate/out
python3 -m venv /home/admin2/musnote-separate/venv
/home/admin2/musnote-separate/venv/bin/pip install -U pip
/home/admin2/musnote-separate/venv/bin/pip install \
  torch==2.11.0+cu128 torchaudio==2.11.0+cu128 \
  --index-url https://download.pytorch.org/whl/cu128
/home/admin2/musnote-separate/venv/bin/pip install demucs==4.1.0 numpy
```

Проверка, что пакет Demucs не подменил PyTorch:

```bash
/home/admin2/musnote-separate/venv/bin/python -c \
  "import torch; print(torch.__version__, torch.cuda.is_available(), torch.cuda.get_device_name(0))"
```

Ожидается строка с `2.11.0+cu128`, `True` и `NVIDIA GeForce RTX 5070 Ti`. Если `False` или версия без `cu128`, заново поставьте две строки `pip install` выше и не запускайте разделение.

## Разделить одну запись

Файл песни на сервер не из git. Его копируют с ноутбука в `in/`. Официальная проверка — `.tmp/Lewis Capaldi - Someone You Loved.mp3`.

```bash
/home/admin2/musnote-separate/venv/bin/demucs -n htdemucs_6s \
  -o /home/admin2/musnote-separate/out \
  "/home/admin2/musnote-separate/in/Lewis Capaldi - Someone You Loved.mp3"
```

Первый запуск сам скачивает веса `htdemucs_6s` в `~/.cache/torch/hub/checkpoints/`. Повторный запуск их не качает.

Шесть файлов появляются в `out/htdemucs_6s/Lewis Capaldi - Someone You Loved/`: `vocals`, `piano`, `guitar`, `drums`, `bass`, `other`. Дальше слушают `vocals` и `piano`. Пока пение и пианино не узнать, ноты не снимают.

## Замер на этой песне

Повторный прогон, веса уже в кэше, карта свободна (контейнеры остановлены). `htdemucs_6s`, 187,2 секунды аудио, RTX 5070 Ti: **6,1 секунды** от запуска до шести wav (`/usr/bin/time`, 20.11).

21.11 до перезагрузки карта не инициализировалась: модуль ядра NVIDIA 595.84, библиотека NVML 595.99 (`Failed to initialize NVML: Driver/library version mismatch`). Тот же `demucs -d cpu` на этой песне: **56 секунд**, шесть wav. Код пробы по умолчанию на процессор не переключали. Чужие контейнеры (`qwen3-14b-vllm-1`, `dict-api-dict-api-1`) остановлены через `docker compose stop`, тома не удалялись.

Пользователь разрешил перезагрузку. После неё, 21.11 около 11:07, модуль в памяти и `nvidia-smi` оба **595.99.02**, карта `NVIDIA GeForce RTX 5070 Ti`. PyTorch `2.11.0+cu128` её видит. Чужие контейнеры сами не поднялись. Новый прогон Demucs на карте после этого ещё не делали.

Тот же файл целиком через текущий `POST /v1/piano-notes` на server8: **8,6 секунды**, 1653 ноты, MIDI от 25 до 89, `clipped` нет. Это не время server7. Пять звучащих дорожек плюс 6 секунд разделения укладываются в минуту, поэтому пробный ответ синхронный, без отдельной задачи.

## Ноты, после того как дорожки узнали

MuScriptor в venv Demucs не ставить. Авторы отдают её отдельно, веса качаются с Hugging Face после согласия с CC BY-NC 4.0.

1. Принять лицензию на странице выбранного размера: [small](https://huggingface.co/MuScriptor/muscriptor-small), [medium](https://huggingface.co/MuScriptor/muscriptor-medium), [large](https://huggingface.co/MuScriptor/muscriptor-large). Для этой карты сначала `medium`. `large` около 7 ГБ на одну песню.
2. На сервере войти в Hugging Face: `uvx hf auth login`. Токен в репозиторий не класть.
3. Снять ноты с уже отделённого файла:

```bash
uvx muscriptor transcribe \
  "/home/admin2/musnote-separate/out/htdemucs_6s/Lewis Capaldi - Someone You Loved/piano.wav"
```

Авторы для Linux пишут команду без флага карты. Если в этой команде карта не видна, та же установка, но с колесом CUDA 12.8, как у них указано для Windows:

```bash
uvx --torch-backend=cu128 muscriptor transcribe \
  "/home/admin2/musnote-separate/out/htdemucs_6s/Lewis Capaldi - Someone You Loved/piano.wav"
```

Веса MuScriptor при этом попадают в `~/.cache/huggingface/`, не в venv Demucs.

Код и страницы авторов: [Demucs](https://github.com/facebookresearch/demucs), [MuScriptor](https://github.com/muscriptor/muscriptor).

## Пробный HTTP

Код в репозитории: `probe/server7/`. Это не `api/` и на server8 не уезжает. Свой venv, потому что Basic Pitch не живёт рядом с NumPy 2 у Demucs.

Python здесь 3.10, как в `api/Dockerfile`. У `basic-pitch==0.4.0` зависимость `tensorflow<2.15`, а у неё нет колеса для Python 3.12, который стоит на server7. Интерпретатор качается в домашний кэш `uv`, в системный Python его не подменяем.

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
~/.local/bin/uv python install 3.10
rm -rf /home/admin2/musnote-separate/venv-notes
~/.local/bin/uv venv --python 3.10 /home/admin2/musnote-separate/venv-notes
~/.local/bin/uv pip install --python /home/admin2/musnote-separate/venv-notes/bin/python \
  -r probe/server7/requirements.txt
```

`POST /v1/separated-notes`, поле `file`. Слушает только localhost. С ноутбука — SSH-туннель на 8096.

Сервис — контейнер, как API на server8. Один образ на Python 3.10: внутри ffmpeg, PyTorch `cu128`, Demucs и Basic Pitch. Два контейнера не нужны: один процесс и так вызывает обе модели, а деление на 3.10 и 3.12 было только из-за системного Python на хосте. Файл `probe/server7/docker-compose.yml`. Политика `restart: unless-stopped` — после перезагрузки машины контейнер поднимается сам. Слушает только `127.0.0.1:8096`. Веса Demucs лежат в `/home/admin2/.cache/torch` и переживают пересборку образа.

До этого короткое время работал systemd-юнит и ещё раньше `nohup`. Юнит в репозитории не хранится. Перед запуском контейнера его выключают, чтобы порт не заняли двое:

```bash
sudo systemctl disable --now musnote-separate.service
cd /home/admin2/musnote-separate/probe/server7
docker compose up -d --build
```

Проверка: `docker ps` показывает контейнер Up, `curl http://127.0.0.1:8096/health` → `{"ok": true}`. В контейнере `torch.cuda.is_available()` должен быть `True`. Compose с `gpus: all` на этом хосте отдаёт устройства, но не ставит `NVIDIA_VISIBLE_DEVICES`, и PyTorch тогда молча считает на процессоре. В compose это задано явно: `all`.

Драйвер NVIDIA сам не обновляется. 21.11 пакет на диске стал 595.99, а модуль в памяти остался 595.84, и карта перестала открываться до перезагрузки. Пакеты ветки 595 держатся через `apt-mark hold`. Осознанное обновление: `sudo apt-mark unhold` этих пакетов, обновление, перезагрузка, затем снова `hold`. Проверка после входа: `nvidia-smi` без строки `version mismatch`.
