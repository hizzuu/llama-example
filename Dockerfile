FROM ubuntu:22.04

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    python3 \
    python3-pip \
    curl \
    wget \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# llama.cppをクローンしてCMakeでビルド
WORKDIR /app
RUN git clone https://github.com/ggerganov/llama.cpp && \
    cd llama.cpp && \
    mkdir build && \
    cd build && \
    cmake .. && \
    cmake --build . --config Release

# モデルをダウンロードするディレクトリを作成
RUN mkdir -p /app/models

# ローカルのモデルファイルをDockerイメージにコピー
COPY models/* /app/models/

# 簡単なAPIサーバーとしてllama.cppのサーバー機能を使用
WORKDIR /app/llama.cpp/build/bin
EXPOSE 8080

# サーバーモードで起動
CMD ["./llama-server", "-m", "/app/models/gemma-2-2b-jpn-it-Q4_K_M.gguf", "-c", "2048", "--host", "0.0.0.0", "--port", "8080", "--repeat-penalty", "1.1"]
