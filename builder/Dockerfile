FROM hashicorp/terraform:latest

RUN sed -i "s/nameserver*/nameserver 169.254.169.254/g" /etc/resolv.conf
