#!/bin/bash

# Функция для обновления системы
update_system() {
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt --fix-broken install -y
}

# Установка необходимых пакетов
sudo apt install -y git dpkg python3-venv unzip wget

# Переход на директорию выше
cd ..

# Скачивание репозитория в формате zip
wget https://codeload.github.com/ShanazarDev/MetrikBot/zip/refs/heads/repo -O MetrikBot.zip

# Распаковка архива
unzip MetrikBot.zip

# Переименование распакованной папки
mv MetrikBot-repo MetrikBot

# Переход в папку MetrikBot
cd MetrikBot

# Установка Google Chrome из локального файла
sudo dpkg -i google-chrome_114.0.5.deb || { update_system && sudo dpkg -i google-chrome_114.0.5.deb; }

# Создание виртуального окружения и установка зависимостей
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Перемещение файла run_script.sh в папку MetrikBot
mv AutoInstall/run_script.sh .

# Генерация случайного таймера для cron от 3 до 7 минут
CRON_TIMING="*/$((RANDOM % 5 + 3)) * * * *"

# Установка cron задачи
(crontab -l ; echo "${CRON_TIMING} $(pwd)/run_script.sh")| crontab -

# Показать пользователю какой таймер был установлен для cron
echo "Cron job установлен с таймером: ${CRON_TIMING}"

# Запуск сервиса cron
sudo service cron start

# Запуск тестового скрипта
python main.py
