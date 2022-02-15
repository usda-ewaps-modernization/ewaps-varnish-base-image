FROM        centos:7
MAINTAINER  Jerry Eshbaugh & Sean Schoolcraft


#update alpine and install Varnish
RUN yum -y update
RUN yum -y install epel-release 
RUN yum -y install python-pip
RUN pip install requests

ADD conf/test.py /test.py
RUN chmod 700 /test.py
CMD ["/test.py"]
