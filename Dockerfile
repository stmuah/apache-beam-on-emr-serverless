FROM public.ecr.aws/emr-serverless/spark/emr-7.5.0:latest

USER root
ARG PYTHON_VERSION=3.11.10
ARG BEAM_VERSION=2.58.0


RUN yum install -y openssl openssl-devel
RUN yum install -y wget perl unzip gcc zlib-devel

RUN yum install -y xz-devel lzma  bzip2-devel libffi-devel tar gzip make && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make install


ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV --copies
RUN cp -r /usr/local/lib/python3.11/* $VIRTUAL_ENV/lib/python3.11 

ENV PATH="$VIRTUAL_ENV/bin:$PATH"
 
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install apache_beam==${BEAM_VERSION} \
    s3fs \
    boto3
 
ENV PYSPARK_PYTHON="/opt/venv/bin/python3"
ENV PYSPARK_DRIVER_PYTHON="/opt/venv/bin/python3"
ENV RUN_PYTHON_SDK_IN_DEFAULT_ENVIRONMENT=1
COPY --from=apache/beam_python3.11_sdk:2.58.0 /opt/apache/beam /opt/apache/beam
USER hadoop:hadoop
