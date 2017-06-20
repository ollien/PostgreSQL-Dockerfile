FROM ubuntu:trusty
MAINTAINER Nick Krichevsky <nick@ollien.com>

RUN groupadd -r postgres
RUN useradd -r -g postgres postgres
RUN apt-get update
RUN mkdir -p /etc/apt/sources.list.d/
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get install -y wget sudo
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y postgresql-9.4
COPY cmd.sh /root/cmd.sh
RUN chmod +x /root/cmd.sh
EXPOSE 5432
EXPOSE 5433
CMD ["/root/cmd.sh"]
