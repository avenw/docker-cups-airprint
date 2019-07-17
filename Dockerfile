FROM ubuntu:xenial

# Add repos
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse' >> /etc/apt/sources.list.d/multiverse.list && \
	echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse' >> /etc/apt/sources.list.d/multiverse.list

# Install the packages we need. Avahi will be included
RUN apt-get update && apt-get install -y \
    tzdata \
	brother-lpr-drivers-extra brother-cups-wrapper-extra \
	cups \
	cups-pdf \
	inotify-tools \
	python-cups \
&& rm -rf /var/lib/apt/lists/*

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*
CMD ["/root/run_cups.sh"]

# time zone
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

