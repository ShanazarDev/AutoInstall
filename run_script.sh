#!/bin/bash

VENV_PATH="/root/MetrikBot/venv"

SCRIPT_PATH="/root/MetrikBot/main.py"

source "$VENV_PATH/bin/activate"

cd "/root/MetrikBot/"

python "$SCRIPT_PATH" &

