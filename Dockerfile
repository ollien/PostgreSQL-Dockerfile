FROM ubuntu:xenial
MAINTAINER Nick Krichevsky <nick@ollien.com>

COPY cmd.sh /cmd.sh
RUN apt-get update && \
	mkdir -p /etc/apt/sources.list.d/ && \
	apt-get update && \
	apt-get install -y postgresql && \
	chmod +x /cmd.sh && \
	chown postgres:postgres /cmd.sh
EXPOSE 5432
EXPOSE 5433
USER postgres
CMD ["/cmd.sh"]
