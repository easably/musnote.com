# Docker Quick Start Guide 🐳

## Быстрый старт

### Локальная сборка и запуск

```bash
# Сборка образа
docker build -t musnote .

# Запуск контейнера
docker run -d -p 80:80 --name musnote musnote

# Или используйте docker-compose
docker-compose up -d
```

Сайт будет доступен по адресу: http://localhost

### Остановка и удаление

```bash
docker stop musnote
docker rm musnote

# Или с docker-compose
docker-compose down
```

## GitHub Actions - Автоматическая сборка

После push в репозиторий:
1. GitHub Actions автоматически соберет Docker образ
2. Образ будет опубликован в GitHub Container Registry
3. Образ будет доступен по адресу: `ghcr.io/<your-username>/musnote.com:latest`

### Настройка доступа к образу

Сделайте образ публичным:
1. Перейдите на https://github.com/<your-username>?tab=packages
2. Найдите пакет `musnote.com`
3. Package settings → Change visibility → Public

## Деплой на DigitalOcean

### Вариант 1: App Platform (рекомендуется)

1. Создайте новое приложение в DigitalOcean App Platform
2. Выберите "Docker Hub or Container Registry"
3. Укажите: `ghcr.io/<your-username>/musnote.com:latest`
4. Нажмите Deploy

### Вариант 2: Droplet с Docker

```bash
# На сервере DigitalOcean
docker pull ghcr.io/<your-username>/musnote.com:latest
docker run -d -p 80:80 --name musnote --restart unless-stopped \
  ghcr.io/<your-username>/musnote.com:latest
```

## Полезные команды

```bash
# Просмотр логов
docker logs musnote
docker logs -f musnote  # Follow mode

# Проверка статуса
docker ps

# Статистика использования ресурсов
docker stats musnote

# Перезапуск
docker restart musnote

# Обновление до последней версии
docker pull ghcr.io/<your-username>/musnote.com:latest
docker stop musnote && docker rm musnote
docker run -d -p 80:80 --name musnote --restart unless-stopped \
  ghcr.io/<your-username>/musnote.com:latest
```

## Характеристики образа

- **Базовый образ**: nginx:alpine (~45MB)
- **Общий размер**: ~46MB (легковесный!)
- **Порт**: 80
- **Health check**: Встроенная проверка здоровья каждые 30 секунд
- **Restart policy**: unless-stopped
- **Gzip compression**: Включено
- **Security headers**: Настроены (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection)

## Поддержка

Подробные инструкции по деплойменту смотрите в файле [DEPLOYMENT.md](./DEPLOYMENT.md)

