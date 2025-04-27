# ビルドステージ
FROM ubuntu:22.04 AS builder

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

# 実行ステージ
FROM ubuntu:22.04 AS runtime

# 実行に必要なパッケージのみインストール
RUN apt-get update && apt-get install -y \
    libcurl4 \
    python3 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# モデルを保存するディレクトリを作成
WORKDIR /app
RUN mkdir -p /app/models

# ビルドステージから必要なファイルのみコピー
COPY --from=builder /app/llama.cpp/build/bin/llama-server /app/bin/
COPY --from=builder /app/llama.cpp/build/bin/libggml*.so /app/bin/
COPY --from=builder /app/llama.cpp/build/bin/libllama.so /app/bin/

# ローカルのモデルファイルをDockerイメージにコピー
COPY models/* /app/models/

# サーバーモードで起動
WORKDIR /app/bin
ENV LD_LIBRARY_PATH=/app/bin
EXPOSE 7860

# CMD ["./llama-server", "-m", "/app/models/gemma-2-2b-jpn-it-Q4_K_M.gguf", "-c", "2048", "--host", "0.0.0.0", "--port", "7860", "--repeat-penalty", "1.1"]
CMD ["./llama-server", "-m", "/app/models/gemma-2-2b-jpn-it-Q4_K_M.gguf", "-c", "512", "--host", "0.0.0.0", "--port", "7860", "-t", "2", "-b", "64", "--top-k", "40", "--top-p", "0.9", "--no-mmap"]
