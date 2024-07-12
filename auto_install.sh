#!/bin/bash

# Установка необходимых пакетов
cd ..
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
       	sudo apt --fix-broken-install	
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

# Обновляем settings.ini
echo "Updating settings.ini..."
cat > settings.ini <<EOL
[Driver]
path = ${CURRENT_PATH}/chromedriver

[LOGS]
path = logs/

[URLs]
urls = 

[Timers]
scroll_delay_min = 0.75
scroll_delay_max = 2
delay_on_page = 2.5

[Counts]
scroll_step_min = 15
scroll_step_max = 35
random_page_counts = 3
EOL

# Спросим у пользователя ссылку на сайт
read -p "Please enter the URL for [URLs][urls]: " USER_URL

# Обновляем URL в settings.ini
sed -i "s|urls =|urls = ${USER_URL}|" settings.ini

# Спросим у пользователя о тестовом запуске
read -p "Do you want to perform a test run? (yes/no): " TEST_RUN

if [ "$TEST_RUN" = "yes" ]; then
    echo "Performing test run..."
    python main.py
else
    echo "Test run skipped."
fi

echo "Setup completed successfully."

