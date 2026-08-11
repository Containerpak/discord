FROM ghcr.io/containerpak/mesa:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates curl desktop-file-utils libasound2t64 libayatana-appindicator3-1 libgtk-3-0 \
    libnss3 libxss1 xdg-utils && \
    curl -fsSL https://dl.discordapp.net/apps/linux/1.0.153/discord-1.0.153.tar.gz \
      -o /tmp/discord.tar.gz && \
    echo 'ff6751840d1319172066bd188190804adc34147c5ed55b1d584223ec4bf42474  /tmp/discord.tar.gz' | sha256sum -c - && \
    mkdir -p /opt/discord && \
    tar -xzf /tmp/discord.tar.gz -C /opt/discord --strip-components=1 && \
    ln -s /opt/discord/Discord /usr/bin/discord && \
    install -Dm644 /opt/discord/discord.desktop /usr/share/applications/com.discordapp.Discord.desktop && \
    desktop-file-edit --set-key=Exec --set-value='discord %U' \
      /usr/share/applications/com.discordapp.Discord.desktop && \
    desktop-file-edit --set-key=Icon --set-value=com.discordapp.Discord \
      /usr/share/applications/com.discordapp.Discord.desktop && \
    desktop-file-edit --add-mime-type=x-scheme-handler/discord \
      /usr/share/applications/com.discordapp.Discord.desktop && \
    install -Dm644 /opt/discord/discord.png \
      /usr/share/icons/hicolor/256x256/apps/com.discordapp.Discord.png && \
    cpak-clean-junk
