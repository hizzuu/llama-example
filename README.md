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
```

### 2. Dockerイメージのビルド

```bash
docker buildx build --platform linux/amd64 -t hizzuu/gemma-2-2b-jpn-it:latest .
```

### 3. コンテナの実行

```bash
docker run -p 7860:7860 hizzuu/gemma-2-2b-jpn-it
```

## 使用方法

サーバーが起動したら、以下のようなcurlコマンドでAPIにアクセスできます：

### 基本的な質問応答

```bash
curl -X POST http://localhost:7860/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "<start_of_turn>user 東京の観光スポットを教えてください<end_of_turn>\n<start_of_turn>model",
    "n_predict": 512,
    "penalty": 1.1,
    "temperature": 0.7,
    "stop": ["<end_of_turn>"]
  }'
```

### チャットフォーマット

```bash
curl -X POST http://localhost:7860/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma-2-2b-jpn-it",                                                                         
    "messages": [    
      {"role": "user", "content": "こんにちは、自己紹介をしてください"}
    ],     
    "penalty": 1.1,                  
    "temperature": 0.7,
    "max_tokens": 512
  }'
```

### hf環境

```bash
curl -X POST https://hizzuu-gemma.hf.space/completion \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer HF_TOKEN" \
  -d '{
    "prompt": "<start_of_turn>user 東京の観光スポットを教えてください<end_of_turn>\n<start_of_turn>model",
    "n_predict": 512,
    "penalty": 1.1,
    "temperature": 0.7,
    "stop": ["<end_of_turn>"]
  }'
```

### Docker push

```bash
docker push hizzuu/gemma-2-2b-jpn-it:latest
```
