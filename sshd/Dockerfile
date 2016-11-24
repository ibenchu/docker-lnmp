FROM centos
MAINTAINER HuadongZuo admin@zuohuadong.cn
RUN yum update
RUN yum install -y openssh-server passwd
RUN mkdir /var/run/sshd

# Password is 'password'
RUN echo 'root:password' | chpasswd

RUN sed -ie "s/PermitRootLogin without-password/PermitRootLogin yes/" /etc/ssh/sshd_config
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
