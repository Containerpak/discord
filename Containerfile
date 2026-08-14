FROM ghcr.io/containerpak/base:main AS assemble

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends brotli ca-certificates curl jq && \
    curl -fsSL https://dl.discordapp.net/apps/linux/1.0.153/discord-1.0.153.tar.gz \
      -o /tmp/bootstrap.tar.gz && \
    echo 'ff6751840d1319172066bd188190804adc34147c5ed55b1d584223ec4bf42474  /tmp/bootstrap.tar.gz' | sha256sum -c - && \
    mkdir -p /tmp/bootstrap /out/discord/modules && \
    tar -xzf /tmp/bootstrap.tar.gz -C /tmp/bootstrap --strip-components=1 && \
    curl -fsSL https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/full.distro \
      -o /tmp/discord.tar.br && \
    echo '033710d9fe9fb0b00ebda9a024cc4c5496e1561dc94a41de78b46c0b036ab27c  /tmp/discord.tar.br' | sha256sum -c - && \
    brotli -cd /tmp/discord.tar.br | tar -xf - -C /out/discord --strip-components=1 && \
    fetch_module() { \
      name="$1"; url="$2"; sha="$3"; file="/tmp/${name}.tar.br"; \
      curl -fsSL "$url" -o "$file"; \
      echo "$sha  $file" | sha256sum -c -; \
      mkdir -p "/out/discord/modules/$name"; \
      brotli -cd "$file" | tar -xf - -C "/out/discord/modules/$name" --strip-components=1; \
    }; \
    fetch_module discord_desktop_core \
      https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/discord_desktop_core/1/full.distro \
      662b3f40ceda9f009e6e12555de3be91843ef36255c44fe5ffd0d216f6c4d0cf; \
    fetch_module discord_erlpack \
      https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/discord_erlpack/1/full.distro \
      30c70f187aee4de6ff16ef6cc8d9f9fd74f1511d094cda807ac1932db022db4b; \
    fetch_module discord_game_utils \
      https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/discord_game_utils/1/full.distro \
      52467b7ff0a4736a03292235b5d654ff6601ba49155757ae82d3824394a15609; \
    fetch_module discord_krisp \
      https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/discord_krisp/1/full.distro \
      ac519e1a147977b63b268d51de77ad24dcf468090777cb817d1b5b70ade66458; \
    fetch_module discord_rpc \
      https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/discord_rpc/1/full.distro \
      f008321cf16ede2c5e0a2ef53355b88637191ef69c5992b6bcf361a91305a99b; \
    fetch_module discord_spellcheck \
      https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/discord_spellcheck/1/full.distro \
      959662b60b439156b39e475adadeffe64af17ce877845d91e880fda077da368b; \
    fetch_module discord_utils \
      https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/discord_utils/1/full.distro \
      6e2ef8b7fe034c02f85fc2c8891bf1f79525bcfcb56f5391815a38f52e621ab0; \
    fetch_module discord_voice \
      https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/discord_voice/1/full.distro \
      a3c7440060996f0cbb30d197dd79446f5ff671f4b05bab7d3544b94b878f779a; \
    fetch_module discord_zstd \
      https://stable.dl2.discordapp.net/distro/app/stable/linux/x64/1.0.153/discord_zstd/1/full.distro \
      c0f55b8309738bbaaf8a6dfe55e5ef935a1705856788d8bbb62947d51dff5e6e; \
    mkdir -p /out/discord/modules/discord_krisp/KMS/logs && \
    jq '.newUpdater = false | .localModulesRoot = "/opt/discord/modules"' \
      /out/discord/resources/build_info.json > /tmp/build_info.json && \
    mv /tmp/build_info.json /out/discord/resources/build_info.json

FROM ghcr.io/containerpak/gtk3:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates desktop-file-utils libasound2t64 \
    libayatana-appindicator3-1 libgtk-3-0 libnss3 libxss1 xdg-utils && \
    cpak-clean-junk

COPY --from=assemble /out/discord /opt/discord
COPY --from=assemble /tmp/bootstrap/discord.desktop /usr/share/applications/com.discordapp.Discord.desktop
COPY --from=assemble /tmp/bootstrap/discord.png /usr/share/icons/hicolor/256x256/apps/com.discordapp.Discord.png
COPY discord /usr/bin/discord

RUN desktop-file-edit --set-key=Exec --set-value='discord %U' \
      /usr/share/applications/com.discordapp.Discord.desktop && \
    desktop-file-edit --set-key=Icon --set-value=com.discordapp.Discord \
      /usr/share/applications/com.discordapp.Discord.desktop && \
    desktop-file-edit --add-mime-type=x-scheme-handler/discord \
      /usr/share/applications/com.discordapp.Discord.desktop
