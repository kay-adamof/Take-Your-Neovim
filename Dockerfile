ARG VARIANT="bookworm"
FROM buildpack-deps:${VARIANT} AS bare-neovim
WORKDIR /root/
RUN apt-get update  && apt-get install -y locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen && \
    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb && \
    apt-get install ./nvim-linux64.deb && \
    rm -rf nvim-linux64.deb && \
    rm -rf /var/lib/apt/lists/*
# After installing Neovim, `:checkhealth` shows an error about system locale.
# To fix this, I follow instructions in the link below.
# 'https://stackoverflow.com/questions/28405902/how-to-set-the-locale-inside-a-debian-ubuntu-docker-container'
ENV ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Using multi-stage build to specify minor/patch version of programing languages
FROM node:18.3.0-slim as node
FROM python:3.10.9-slim AS python
FROM rust:1.66.1-slim-buster AS rust
FROM ubuntu:focal-20220531 as lua
RUN apt-get update && apt-get install -y wget build-essential && \
    wget https://www.lua.org/ftp/lua-5.4.4.tar.gz && \
    tar -xf lua-5.4.4.tar.gz && \
    cd lua-5.4.4 && \
    make linux && \
    make install && \
    rm -rf /var/lib/apt/lists/*

# Using ubuntu as base image
FROM bare-neovim as neovim
# Copy minimal runtime needed
COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/lib/ /usr/local/lib/
COPY --from=node /usr/local/bin/ /usr/local/bin/
COPY --from=python /usr/local/include/ /usr/local/include/
COPY --from=python /usr/local/lib/ /usr/local/lib/
COPY --from=python /usr/local/bin/ /usr/local/bin/
COPY --from=lua /usr/local/include/ /usr/local/include/
COPY --from=lua /usr/local/lib/ /usr/local/lib/
COPY --from=lua /usr/local/bin/ /usr/local/bin/
WORKDIR /root/
RUN apt-get update && apt-get install -y build-essential && \
    rm -rf /var/lib/apt/lists/*
# To activate python
# See: https://stackoverflow.com/questions/43333207/python-error-while-loading-shared-libraries-libpython3-4m-so-1-0-cannot-open
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/

# https://astronvim.github.io/
FROM neovim as requirements-of-astro
# Installing the requirements of AstroNvim
# See: https://astronvim.github.io/#-requirements
RUN wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip && \
    unzip Hack.zip && rm -rf Hack.zip && \
    npm install tree-sitter-cli && \
    wget https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb && \
    apt-get install -y ./ripgrep_13.0.0_amd64.deb && rm -rf ripgrep_13.0.0_amd64.deb && \
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' |  sed -E 's/.*"v*([^"]+)".*/\1/') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz -C /usr/local/bin lazygit && \
    rm -rf lazygit.tar.gz && \
    curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz && \
    chmod +x gdu_linux_amd64 && \
    mv gdu_linux_amd64 /usr/bin/gdu && \
    curl -LO https://github.com/ClementTsang/bottom/releases/download/0.7.1/bottom_0.7.1_amd64.deb && \
    dpkg -i bottom_0.7.1_amd64.deb && \
    rm -rf bottom_0.7.1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# About 140sec is needed to build this image in the case of my machine.
FROM requirements-of-astro as astro
RUN git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim && \
    nvim --headless -c 'autocmd User PackerComplete quitall' && \
    nvim --headless -c 'TSUpdateSync lua vim' -c 'qa' && \
    cp -r ~/.config/nvim/lua/user_example/ ~/.config/nvim/lua/user/
ENV ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

FROM neovim AS lvim
COPY --from=rust /usr/local/cargo /usr/local/cargo
COPY --from=rust /usr/local/rustup /usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV RUSTUP_HOME=/usr/local/rustup
ENV PATH=/root/.local/bin:/usr/local/cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LV_BRANCH='release-1.2/neovim-0.8'
RUN curl https://raw.githubusercontent.com/lunarvim/lunarvim/fc6873809934917b470bff1b072171879899a36b/utils/installer/install.sh -o install.sh && \
    yes | bash install.sh && \
    rm -rf install.sh && \
    rm -rf /var/lib/apt/lists/*
