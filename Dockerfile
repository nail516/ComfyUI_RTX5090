# Финальная версия. Используем официальный образ RunPod как надежную основу.
FROM runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04

# Устанавливаем переменные окружения
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV WORKSPACE=/workspace

WORKDIR ${WORKSPACE}

# Устанавливаем системные утилиты, которые могут отсутствовать в базовом образе
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl rclone \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Устанавливаем Python-библиотеки, необходимые для ComfyUI и наших инструментов
# PyTorch и Torchvision уже есть в базовом образе, но мы устанавливаем xformers и др.
RUN pip install --no-cache-dir \
    PyYAML \
    aiohttp \
    xformers \
    jupyterlab \
    runpodctl

# Устанавливаем дополнительные инструменты
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN curl -sSL https://raw.githubusercontent.com/runpod/oh-my-runpod/main/install.sh | bash
RUN curl -L https://getcroc.schollz.com | bash

# Клонируем ComfyUI и ComfyUI-Manager
RUN git clone --branch v0.3.43 https://github.com/comfyanonymous/ComfyUI.git && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git ComfyUI/custom_nodes/ComfyUI-Manager

# Устанавливаем зависимости из requirements.txt самого ComfyUI
RUN cd ComfyUI && pip install --no-cache-dir -r requirements.txt

# Копируем ваши скрипты и конфигурации из репозитория внутрь образа
COPY start.sh ${WORKSPACE}/start.sh
COPY extra_model_paths.yaml ${WORKSPACE}/extra_model_paths.yaml
RUN chmod +x ${WORKSPACE}/start.sh

# Устанавливаем команду для запуска при старте контейнера
CMD ["/workspace/start.sh"]
