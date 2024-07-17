#!/bin/bash

# Функция для обновления системы
update_system() {
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt --fix-broken install -y
}

# Установка необходимых пакетов
sudo apt install -y git dpkg python3-venv

# Переход на директорию выше
cd ..

# Скачивание репозитория
git clone -b repo https://github.com/ShanazarDev/MetrikBot.git

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

# Получение пути драйвера и обновление settings.ini
CHROMEDRIVER_PATH=$(pwd)/chromedriver

# Обновление конфигурационного файла settings.ini
cat <<EOT > settings.ini
[Driver]
path = ${CHROMEDRIVER_PATH}

[LOGS]
path = logs/

[URLs]
urls = https://turkmenportal.com, https://infoportal.today
EOT

# Генерация случайного таймера для cron от 3 до 7 минут
CRON_TIMING="*/$((RANDOM % 5 + 3)) * * * *"

# Установка cron задачи
(crontab -l ; echo "${CRON_TIMING} /root/MetrikBot/run_script.sh")| crontab -

# Показать пользователю какой таймер был установлен для cron
echo "Cron job установлен с таймером: ${CRON_TIMING}"

# Запуск сервиса cron
sudo service cron start

# Запуск тестового скрипта
python main.py
