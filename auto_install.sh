#!/bin/bash

# Выйти на директорию выше
cd ..

# Установка необходимых пакетов
echo "Installing necessary packages..."
sudo apt install -y git dpkg python3-venv wget

# Функция для обновления и апгрейда системы
update_system() {
    echo "Updating and upgrading system..."
    sudo apt update -y
    sudo apt upgrade -y
}

# Клонируем репозиторий
echo "Cloning the repository..."
git clone -b repo https://github.com/ShanazarDev/MetrikBot.git

# Переходим в папку репозитория
cd MetrikBot || { echo "Failed to enter the MetrikBot directory"; exit 1; }

# Устанавливаем google-chrome
install_chrome() {
    echo "Installing google-chrome..."
    sudo dpkg -i google-chrome_114.0.5.deb || { 
        echo "Failed to install google-chrome, trying to fix dependencies..."; 
        update_system; 
        sudo apt --fix-broken install -y;
        sudo dpkg -i google-chrome_114.0.5.deb || { echo "Failed to install google-chrome after update"; exit 1; }
    }
}

install_chrome

# Создаем и активируем виртуальное окружение
echo "Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Устанавливаем зависимости из requirements.txt
echo "Installing requirements..."
pip install -r requirements.txt

# Получаем текущий путь
CURRENT_PATH=$(pwd)

# Запрашиваем у пользователя необходимые данные
read -p "Please enter the URL for [URLs][urls]: " USER_URL
read -p "Please enter scroll_delay_min: " SCROLL_DELAY_MIN
read -p "Please enter scroll_delay_max: " SCROLL_DELAY_MAX
read -p "Please enter scroll_step_min: " SCROLL_STEP_MIN
read -p "Please enter scroll_step_max: " SCROLL_STEP_MAX
read -p "Please enter random_page_counts: " RANDOM_PAGE_COUNTS
read -p "Please enter delay_on_page: " DELAY_ON_PAGE

# Обновляем settings.ini
echo "Updating settings.ini..."
cat > settings.ini <<EOL
[Driver]
path = ${CURRENT_PATH}/chromedriver

[LOGS]
path = logs/

[URLs]
urls = ${USER_URL}

[Timers]
scroll_delay_min = ${SCROLL_DELAY_MIN}
scroll_delay_max = ${SCROLL_DELAY_MAX}
delay_on_page = ${DELAY_ON_PAGE}

[Counts]
scroll_step_min = ${SCROLL_STEP_MIN}
scroll_step_max = ${SCROLL_STEP_MAX}
random_page_counts = ${RANDOM_PAGE_COUNTS}
EOL

# Перемещаем файл run_script.sh в папку /MetrikBot/
echo "Moving run_script.sh to /MetrikBot/..."
mv AutoInstall/run_script.sh .

# Устанавливаем cron
echo "Installing cron..."
sudo apt install -y cron

# Спросим у пользователя о тайминге для cron
read -p "Please enter the timing for cron job (e.g., */5 * * * *): " CRON_TIMING

# Добавляем задание в crontab
(crontab -l ; echo "*/${CRON_TIMING} * * * * /root/MetrikBot/run_script.sh") | crontab -

# Спросим у пользователя о тестовом запуске
read -p "Do you want to perform a test run? (yes/no): " TEST_RUN

if [ "$TEST_RUN" = "yes" ]; then
    echo "Performing test run..."
    python main.py
else
    echo "Test run skipped."
fi

echo "Setup completed successfully."
