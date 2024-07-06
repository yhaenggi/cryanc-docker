ARG ARCH
FROM ${ARCH}/ubuntu:noble
MAINTAINER yhaenggi <yhaenggi-git-public@darkgamex.ch>

ARG ARCH
ARG VERSION
ARG IMAGE
ENV VERSION=${VERSION}
ENV ARCH=${ARCH}
ENV IMAGE=${IMAGE}

COPY ./qemu-arm /usr/bin/qemu-arm
COPY ./qemu-aarch64 /usr/bin/qemu-aarch64

RUN echo force-unsafe-io | tee /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
RUN apt-get update

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get install git gcc -y

WORKDIR /tmp/
RUN git clone --depth 1 --branch ${VERSION} https://github.com/classilla/cryanc.git ${IMAGE}
WORKDIR /tmp/${IMAGE}/

RUN gcc -O3 -o carl carl.c

# inetd or socat to run this...

FROM ${ARCH}/ubuntu:noble
ARG IMAGE
ENV IMAGE=${IMAGE}

COPY ./qemu-arm /usr/bin/qemu-arm
COPY ./qemu-aarch64 /usr/bin/qemu-aarch64

WORKDIR /root/

RUN echo force-unsafe-io | tee /etc/dpkg/dpkg.cfg.d/docker-apt-speedup

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install socat -y && apt-get clean && rm -R /var/cache/apt && rm -R /var/lib/apt/lists

RUN mkdir -p /home/cryanc
RUN groupadd -g 912 cryanc
RUN useradd -M -d /home/cryanc -u 912 -g 912 -s /bin/bash cryanc

COPY --from=0 /tmp/${IMAGE}/carl /usr/bin/carl

RUN chown cryanc:cryanc /home/cryanc -R

RUN rm /usr/bin/qemu-arm* /usr/bin/qemu-aarch64*

USER cryanc
WORKDIR /home/cryanc

EXPOSE 8080/tcp

ENTRYPOINT ["/usr/bin/socat"]
CMD ["TCP4-LISTEN:8080,fork", "SYSTEM:'carl -p',pty"]
