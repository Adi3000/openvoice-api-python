FROM nvidia/cuda:12.6.3-base-ubuntu24.04

RUN apt-get update \
    && apt-get -qq install -y software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get -qq update \
    && apt-get remove -y software-properties-common \
    && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -qq install --no-install-recommends -y git git-lfs curl python3.11 python3.11-venv ffmpeg libmagic1 \
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash \
    && git lfs install \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir app \
    && apt-get autoremove -y \
    && python3.11 -m venv /app/.venv


WORKDIR /app

ENV PATH /app/.venv/bin:$PATH

RUN /app/.venv/bin/pip install -U pip setuptools \
 && /app/.venv/bin/pip install --no-cache-dir git+https://github.com/myshell-ai/MeloTTS.git@main \
 && python -m unidic download \
 && /app/.venv/bin/pip install --no-cache-dir librosa==0.11.0 \
 && /app/.venv/bin/pip install --no-cache-dir git+https://github.com/Adi3000/OpenVoice.git@main \
 && /app/.venv/bin/pip install --no-cache-dir torch==2.7.1+cu126 torchaudio==2.7.1+cu126 --index-url https://download.pytorch.org/whl/cu126 \
 && git clone --depth=1 https://huggingface.co/myshell-ai/OpenVoiceV2 \
 && git clone --depth=1 https://huggingface.co/myshell-ai/OpenVoice \
 && ln -s /app/OpenVoiceV2 /app/OpenVoice/checkpoints_v2 \
 && /app/.venv/bin/pip cache purge \
 && /app/.venv/bin/pip install nvidia-cublas-cu12 nvidia-cudnn-cu12==9.*

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/app/.venv/lib/python3.11/site-packages/nvidia/cublas/lib:/app/.venv/lib/python3.11/site-packages/nvidia/cudnn/lib

COPY . /app

RUN /app/.venv/bin/pip install --no-cache-dir -r requirements.txt

EXPOSE 5000
ENTRYPOINT ["/app/.venv/bin/python3","app.py"]
