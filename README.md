# Llama.cpp Docker サーバー

このプロジェクトは、[llama.cpp](https://github.com/ggerganov/llama.cpp)を使用して、大規模言語モデル（LLM）をDockerコンテナ内で実行するためのセットアップを提供します。特に日本語対応モデルである「Llama-3-ELYZA-JP-8B」を使用することを想定しています。

## 前提条件

- Docker
- 十分なディスク容量（モデルファイルのサイズによる）
- インターネット接続（モデルのダウンロード用）

## セットアップ

### 1. モデルのダウンロード

```bash
mkdir -p models
wget -O models/Llama-3-ELYZA-JP-8B-q4_k_m.gguf https://huggingface.co/elyza/Llama-3-ELYZA-JP-8B-GGUF/resolve/main/Llama-3-ELYZA-JP-8B-q4_k_m.gguf
```

### 2. Dockerイメージのビルド

```bash
docker build -t llama-cpu-q4km .
```

### 3. コンテナの実行

```bash
docker run -p 8080:8080 -v $(pwd)/models:/app/models llama-cpu-q4km /app/llama.cpp/build/bin/llama-server -m /app/models/Llama-3-ELYZA-JP-8B-q4_k_m.gguf -c 2048 --host 0.0.0.0 --port 8080
```

## 使用方法

サーバーが起動したら、以下のようなcurlコマンドでAPIにアクセスできます：

### 基本的な質問応答

```bash
curl -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "東京の観光スポットを5つ教えてください",
    "n_predict": 512,
    "temperature": 0.7,
    "stop": ["\n\n"]
  }'
```

### チャットフォーマット（Llama-3 ELYZA-JP用）

```bash
curl -X POST http://localhost:8080/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Llama-3-ELYZA-JP-8B-q4_k_m",
    "messages": [
      {"role": "user", "content": "東京の観光スポットを5つ教えてください"}
    ]
  }'
```
