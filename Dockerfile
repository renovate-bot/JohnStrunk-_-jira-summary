# This Dockerfile is based on the pattern recommended by the pipenv docs:
# https://pipenv.pypa.io/en/latest/docker.html
FROM python:3.12@sha256:942374a9ed2353df11065502733c29c7f655a2b6bd03e0e2a3dd2086fdb1044c as builder

RUN pip install --no-cache-dir pipenv==2023.12.1
ENV PIPENV_VENV_IN_PROJECT=1

WORKDIR /app
COPY Pipfile Pipfile.lock /app/
RUN pipenv --no-site-packages install -v --deploy


############################################################
FROM python:3.12-slim@sha256:be0861bf8b25e4d36180bf0d62fa70a6925b4039cec7eff125f382b06af9a775 as final

RUN adduser --uid 19876 summarizer-bot && \
    mkdir /app && \
    chown summarizer-bot:summarizer-bot /app
USER 19876

# Make sure stdout gets flushed so we see it in the pod logs
ENV PYTHONUNBUFFERED=true

WORKDIR /app
COPY --from=builder --chown=summarizer-bot:summarizer-bot /app/.venv /app/.venv
COPY --chown=summarizer-bot:summarizer-bot *.py /app/

ENTRYPOINT ["/app/.venv/bin/python", "bot.py"]
