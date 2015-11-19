FROM krajcovic/centos-base

MAINTAINER Dusan Krajcovic <dusan.krajcovic@gmail.com>

# Variables
#ENV hostname node.base.docker.monetplus.cz
ENV container docker

RUN yum -y update --skip-broken; yum -y install libaio mysql-libs mysql-community-server mysql-community-client

ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD mysqld_charset.cnf /etc/mysql/conf.d/mysqld_charset.cnf
# RUN chown -R mysql /etc/mysql/conf.d/my.cnf
# RUN chgrp -R mysql /etc/mysql/conf.d/my.cnf
# RUN chown -R mysql /etc/mysql/conf.d/mysqld_charset.cnf
# RUN chgrp -R mysql /etc/mysql/conf.d/mysqld_charset.cnf

# COPY mysql/replication.sql /var/lib/mysql/replication.sql

# RUN /usr/bin/mysql -uroot </var/lib/mysql/replication.sql >/var/lib/mysql/replication.sql.initialized

RUN mkdir /opt/scripts
ADD import_sql.sh /opt/scripts/import_sql.sh
ADD run.sh /opt/scripts/run.sh
# RUN chown -R mysql /opt/scripts
# RUN chgrp -R mysql /opt/scripts



# MYSQL_PASS=**Random** \
# ON_CREATE_DB=**False** \
ENV MYSQL_USER=admin \
	MYSQL_PASS=passw \
    ON_CREATE_DB=monettest \
    REPLICATION_MASTER=**False** \
    REPLICATION_SLAVE=**False** \
    REPLICATION_USER=replica \
    REPLICATION_PASS=replica

EXPOSE 3306

VOLUME ["/etc/mysql", "/var/lib/mysql"]

# CMD ["/bin/bash"]

WORKDIR /

# USER mysql

ENTRYPOINT ["/opt/scripts/run.sh"]