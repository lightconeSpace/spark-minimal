# Stage 1: Build Environment
FROM debian:11-slim as builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    build-essential \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Compile Python 3.9.18
RUN wget https://www.python.org/ftp/python/3.9.18/Python-3.9.18.tgz \
 && tar xzf Python-3.9.18.tgz \
 && cd Python-3.9.18 \
 && ./configure \
    --prefix=/usr/local \
    --enable-shared \
 && make -j$(nproc) \
 && make install \
 && cd .. \
 && rm -rf Python-3.9*

# Setup LD path
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/python3.9.conf \
 && ldconfig

# Configure symbolic links
RUN ln -sf /usr/local/bin/python3.9 /usr/bin/python \
 && ln -sf /usr/local/bin/pip3.9 /usr/bin/pip

# Copy Spark
COPY spark-3.5.2-bin-hadoop3.tgz /tmp/
RUN mkdir -p /opt \
 && tar -xzf /tmp/spark-3.5.2-bin-hadoop3.tgz -C /opt \
 && mv /opt/spark-3.5.2-bin-hadoop3 /opt/spark \
 && rm /tmp/spark-3.5.2-bin-hadoop3.tgz

# Install Py4J
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
RUN pip install --no-cache-dir py4j==0.10.9.7

# ================================================

# Stage 2: Runtime Environment
FROM debian:11-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jre \
    openssh-server \
    libffi7 \
    zlib1g \
    bash \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/sshd

# Setup SSH
RUN echo 'root:spark' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config \
    && echo "GatewayPorts yes" >> /etc/ssh/sshd_config \
    && echo "PermitTunnel yes" >> /etc/ssh/sshd_config

# Configure LD
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/python3.9.conf \
    && mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Copy Python and Spark
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/local/bin/python* /usr/local/bin/
COPY --from=builder /usr/local/bin/pip* /usr/local/bin/
COPY --from=builder /usr/local/include/python3.9/ /usr/local/include/python3.9/
COPY --from=builder /usr/local/lib/python3.9/ /usr/local/lib/python3.9/
COPY --from=builder /opt/spark /opt/spark

# Configure symbolic links
RUN ln -sf /usr/local/bin/python3.9 /usr/bin/python \
 && ln -sf /usr/local/bin/python3.9 /usr/bin/python3 \
 && ln -sf /usr/local/bin/pip3.9 /usr/bin/pip

# Environment variable configuration
ENV SPARK_HOME=/opt/spark
ENV PYSPARK_PYTHON=/usr/bin/python
ENV PATH="${PATH}:${SPARK_HOME}/bin"
ENV LD_LIBRARY_PATH="/usr/local/lib:/usr/lib:/lib"

# Refresh library cache
RUN ldconfig

# Verify installation
RUN java -version \
 && python --version \
 && pip --version \
 && ${SPARK_HOME}/bin/spark-submit --version

# Add startup script
RUN echo '#!/bin/bash' > /entrypoint.sh \
    && echo 'service ssh start' >> /entrypoint.sh \
    && echo 'tail -f /dev/null' >> /entrypoint.sh \
    && chmod +x /entrypoint.sh

# Set working directory
WORKDIR /app

# Expose SSH port
EXPOSE 22

# Start service
CMD ["/entrypoint.sh"]