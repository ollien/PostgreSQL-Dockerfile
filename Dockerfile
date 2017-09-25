FROM ubuntu:trusty
MAINTAINER Nick Krichevsky <nick@ollien.com>

RUN groupadd -r postgres && \
	useradd -r -g postgres postgres && \
	apt-get update && \
	mkdir -p /etc/apt/sources.list.d/ && \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
	apt-get install -y wget sudo && \
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
	apt-get update && \
	apt-get install -y postgresql-9.4
COPY cmd.sh /root/cmd.sh
RUN chmod +x /root/cmd.sh
EXPOSE 5432
EXPOSE 5433
CMD ["/root/cmd.sh"]
