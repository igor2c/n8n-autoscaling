# Multi-stage build to add tools to n8n image
# This works around apk being stripped from the official image

# Stage 1: Build dependencies in Alpine
FROM alpine:3.23 AS builder

RUN apk add --no-cache \
    git \
    openssh-client \
    jq \
    curl

# --- OPTIONAL: ffmpeg (media processing) --- uncomment to enable ---
# RUN apk add --no-cache ffmpeg
# ---

# --- OPTIONAL: graphicsmagick (image manipulation) --- uncomment to enable ---
# RUN apk add --no-cache graphicsmagick
# ---

# Stage 2: Copy to n8n image
FROM n8nio/n8n:2.10.3

USER root

# Copy binaries and libraries from builder
COPY --from=builder /usr/bin/git /usr/bin/git
COPY --from=builder /usr/bin/jq /usr/bin/jq
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /usr/lib/libcurl*.so* /usr/lib/
COPY --from=builder /usr/lib/libjq*.so* /usr/lib/
COPY --from=builder /usr/lib/libonig*.so* /usr/lib/

# --- OPTIONAL: ffmpeg --- uncomment to enable ---
# COPY --from=builder /usr/bin/ffmpeg /usr/bin/ffmpeg
# COPY --from=builder /usr/bin/ffprobe /usr/bin/ffprobe
# COPY --from=builder /usr/lib/libav*.so* /usr/lib/
# COPY --from=builder /usr/lib/libsw*.so* /usr/lib/
# ---

# --- OPTIONAL: graphicsmagick --- uncomment to enable ---
# COPY --from=builder /usr/bin/gm /usr/bin/gm
# ---

# Expose task broker port for external runners (n8n 2.0)
EXPOSE 5679

USER node
