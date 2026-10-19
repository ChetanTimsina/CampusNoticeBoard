# Alpine-based image; one source tree, behaviour set by build args.
FROM python:3.12-alpine
ARG APP_VERSION=1.0.0
ARG BROKEN=false
ARG STUDENT=02230120
ENV APP_VERSION=$APP_VERSION BROKEN=$BROKEN STUDENT=$STUDENT
RUN adduser -D -u 10001 app
WORKDIR /app
COPY app.py .
USER 10001
EXPOSE 8080
CMD ["python", "-u", "app.py"]
