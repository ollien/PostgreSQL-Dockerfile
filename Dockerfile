FROM ubuntu:trusty
MAINTAINER Nick Krichevsky <nick@ollien.com>

RUN apt-get update && \
	mkdir -p /etc/apt/sources.list.d/ && \
	apt-get update && \
	apt-get install -y postgresql sudo
COPY cmd.sh /root/cmd.sh
RUN chmod +x /root/cmd.sh
EXPOSE 5432
EXPOSE 5433
CMD ["/root/cmd.sh"]
