FROM ghcr.io/containerpak/gtk3:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates libasound2t64 libayatana-appindicator3-1 \
    libnss3 libxss1 xdg-utils && \
    mkdir -p /usr/share/applications /usr/share/icons/hicolor/256x256/apps && \
    ln -sf /usr/share/discord/discord.desktop /usr/share/applications/com.discordapp.Discord.desktop && \
    ln -sf /usr/share/discord/discord.png /usr/share/icons/hicolor/256x256/apps/com.discordapp.Discord.png && \
    cpak-clean-junk
