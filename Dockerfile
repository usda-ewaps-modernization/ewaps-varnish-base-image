FROM        centos:7

#set default  ENV variables, overwritable by docker or Rancher
ENV VARNISH_MEMORY 64M

# Expose this port in case it is not mapped at container startup
EXPOSE 6081

#update CentOS and install services 
RUN yum -y update && \
    yum -y  install epel-release && \
    yum -y install varnish && \
    yum clean all

COPY conf/default.vcl /etc/varnish/default.vcl

#start Varnish service
ADD conf/start.sh /start.sh
RUN chmod 700 /start.sh
CMD ["/start.sh"]
