# This Dockerfile is based on the pattern recommended by the pipenv docs:
# https://pipenv.pypa.io/en/latest/docker.html
FROM python:3.12@sha256:2373ee6cd4b1199025af5bd6ee04103cdd1b07a83abe19e5e9c51f22921403fd as builder

RUN pip install --no-cache-dir pipenv==2023.12.1
ENV PIPENV_VENV_IN_PROJECT=1

WORKDIR /app
COPY Pipfile Pipfile.lock /app/
RUN pipenv --no-site-packages install -v --deploy


############################################################
FROM python:3.12-slim@sha256:692e412032bc1863f1af8eed42be664d8ab7da31de49cf142722b8065d77e3ab as final

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
