FROM centos
MAINTAINER Fer Uria <438653638@qq.com>
LABEL Description="vsftpd Docker image based on Centos 7. Supports passive mode and virtual users." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST PORT NUMBER]:21 -v [HOST FTP HOME]:/home/vsftpd fauria/vsftpd" \
	Version="1.0"

#RUN yum -y update && yum clean all
#RUN yum -y install httpd && yum clean all
RUN yum install -y \
	vsftpd \
	db4-utils \
	db4

ENV FTP_USER sobey
ENV FTP_PASS Sobey_2016
ENV LOG_STDOUT **Boolean**

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh
RUN mkdir -p /home/vsftpd/
RUN chown -R ftp:ftp /home/vsftpd/

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd

EXPOSE 20 21 21100-21110

CMD ["/usr/sbin/run-vsftpd.sh"]
