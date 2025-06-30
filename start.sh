#!/bin/bash
# Запускаем вспомогательные сервисы в фоновом режиме
code-server --bind-addr 0.0.0.0:8080 --auth none &
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root &

# Запускаем ComfyUI как основной процесс, который держит контейнер активным
cd /workspace/ComfyUI
python3 main.py --listen
