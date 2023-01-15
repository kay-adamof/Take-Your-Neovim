# Using multi-stage build to specify minor/patch version of programing languages
FROM node:18.3.0-slim as node
FROM python:3.10.9-slim AS python
# Using ubuntu as base image
FROM ubuntu:focal-20220531 as base
# Copy minimal runtime needed
COPY --from=node /usr/local/include/ /usr/local/include/
COPY --from=node /usr/local/lib/ /usr/local/lib/
COPY --from=node /usr/local/bin/ /usr/local/bin/
COPY --from=python /usr/local/include/ /usr/local/include/
COPY --from=python /usr/local/lib/ /usr/local/lib/
COPY --from=python /usr/local/bin/ /usr/local/bin/

WORKDIR /root/

# Installing Neovim and its related dependencies
RUN apt-get update  && apt-get install -y \
    wget \
    curl \
    git \
    unzip && \
    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb && \
    apt-get install ./nvim-linux64.deb && \
    rm -rf /var/lib/apt/lists/*
# To activate python
# See: https://stackoverflow.com/questions/43333207/python-error-while-loading-shared-libraries-libpython3-4m-so-1-0-cannot-open
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/


# FROM base as xclip
# RUN apt install -y xclip

FROM base as astro
# What is astro? See this link;
# https://astronvim.github.io/ 

# Installing the requirements of AstroNvim
RUN wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.2.2/Hack.zip && \
    unzip Hack.zip && rm -rf Hack.zip && \
    npm install tree-sitter-cli && \
    wget https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb && \
    apt-get install -y ./ripgrep_13.0.0_amd64.deb && rm -rf ripgrep_13.0.0_amd64.deb && \
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name":' |  sed -E 's/.*"v*([^"]+)".*/\1/') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz -C /usr/local/bin lazygit && \
    curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz && \
    chmod +x gdu_linux_amd64 && \
    mv gdu_linux_amd64 /usr/bin/gdu && \
    curl -LO https://github.com/ClementTsang/bottom/releases/download/0.7.1/bottom_0.7.1_amd64.deb && \
    dpkg -i bottom_0.7.1_amd64.deb && \
    rm -rf /var/lib/apt/lists/*


