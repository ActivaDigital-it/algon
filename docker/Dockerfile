FROM ubuntu:22.04
# 4-0-1
EXPOSE 8080 9100

ENV DEBIAN_FRONTEND=noninteractive

# kubectl & curl
RUN apt update && \
    apt install -y curl ca-certificates jq bash bind9-dnsutils && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/bin/kubectl

# Algorand node
RUN mkdir /algorand
WORKDIR /algorand
SHELL ["/bin/bash", "-c"]
RUN curl -L https://raw.githubusercontent.com/algorand/go-algorand/rel/stable/cmd/updater/update.sh --output ./update.sh && \
    chmod -v 744 ./update.sh && \
    mkdir node && \
    ./update.sh -i -c stable -p node -d node/_data -n && \
    /algorand/node/algod -v && \
    rm -rf node/_data

ADD ./scripts ./

# USER 10001:10001
