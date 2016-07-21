FROM ubuntu:trusty

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -q -y install libpq-dev build-essential git-core wget libssl-dev apt-transport-https ca-certificates libcurl4-openssl-dev libicu52 liblldb-3.6 liblttng-ust0 libunwind8 libobjc-4.8-dev

ENV NODE_VERSION="4.4.4" \
    DOTNET_CORE_SDK_VERSION="1.0.0-preview2-003121" \
    DOTNET_CORE_VERSION="1.0.0-rc2-3002702" \
    ASPNETCORE_URLS="http://*:5000" \
    ASPNETCORE_ENVIRONMENT="Production"

RUN git clone https://github.com/tj/n.git ~/.n \
    && cd ~/.n \
    && make install \
    && n ${NODE_VERSION} \
    && rm -rf ~/.n
RUN echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet/ trusty main" > /etc/apt/sources.list.d/dotnetdev.list \
    && apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893 \
    && echo "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.5 main \n deb-src http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.5 main \n" > /etc/apt/sources.list \
    && wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y install libclang1-3.5 clang-3.5 dotnet-sharedframework-microsoft.netcore.app-$DOTNET_CORE_VERSION dotnet-dev-$DOTNET_CORE_SDK_VERSION
RUN mkdir -p /app
COPY . /app/
WORKDIR /app
RUN dotnet restore

EXPOSE 5000

ENTRYPOINT dotnet run