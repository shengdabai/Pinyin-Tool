FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt ./
RUN pip install --prefix=/install -r requirements.txt

FROM python:3.11-slim

WORKDIR /app

COPY --from=builder /install /usr/local
COPY pinyin_tool.py .
COPY pinyin_types.py .

ENV PYTHONUNBUFFERED=1

EXPOSE 7860

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "from pinyin_tool import convert_pinyin_text; convert_pinyin_text('你好', 'NORMAL')" || exit 1

CMD ["python", "pinyin_tool.py"]
