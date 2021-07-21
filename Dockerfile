FROM "ubuntu:rolling"

# Needed for string substitution
SHELL ["/bin/bash", "-c"]

ENV TZ=Asia/Kolkata
ARG DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN groupadd -r kunalshah --gid=1000; \
    useradd -r -g kunalshah --uid=1000 --home-dir=/home/kunalshah --shell=/bin/bash kunalshah; \
    mkdir -p /home/kunalshah; \
    chown -R kunalshah:kunalshah /home/kunalshah

COPY py_reqs.txt rscript.R /tmp/

ENV LANG C.UTF-8

RUN apt-get update & apt-get upgrade -y

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        lsb-release \
        curl \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip \
        python3 \
        python3-pip \
        python3-dev \
        python3-testresources \
        git \
        wget \
        tzdata \
        gnupg \
        vim \
        pandoc \
        texlive-xetex \
        texlive-fonts-recommended \
        r-base \
        r-base-dev \
        && rm -rf /var/lib/apt/lists/*

RUN ln -s $(which python3) /usr/local/bin/python

RUN python3 -m pip --no-cache-dir install --upgrade \
    pip \
    setuptools \
    wheel
RUN python3 -m pip --no-cache-dir install --upgrade --requirement /tmp/py_reqs.txt

RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

RUN Rscript /tmp/rscript.R

WORKDIR /code

EXPOSE 8888

RUN jupyter labextension install @techrah/text-shortcuts

RUN apt autoremove -y

RUN rm -rf /tmp/py_reqs.txt /tmp/rscript.R

CMD [ "/bin/bash" ]
