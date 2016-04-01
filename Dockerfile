FROM centos:7
MAINTAINER gtrebos

ENV NGINX_VERSION 1.9.13
ENV NGX_SMALL_LIGHT_VERSION 0.6.8
ENV IMAGEMAGICK_VERSION 6.8.6-8

RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

RUN yum -y upgrade
RUN yum -y update; yum clean all
RUN yum -y install wget gd gd-devel ImageMagick*
RUN yum -y install bash-completion \
                   curl \
                   openssh-clients \
                   openssh-server \
                   vim-enhanced \
                   sudo

RUN yum -y install gc gcc gcc-c++ pcre-devel zlib-devel make wget openssl-devel libxml2-devel libxslt-devel \
    gd-devel perl-ExtUtils-Embed GeoIP-devel gperftools gperftools-devel libatomic_ops-devel perl-ExtUtils-Embed

# Clean up YUM when done.
RUN yum clean -y all

# Add nginx user to system
RUN useradd nginx && usermod -s /sbin/nologin nginx
RUN mkdir -p /etc/nginx/conf.d/



# Install nginx_small_light
COPY conf/ngx_small_light.tar.gz /tmp/ngx_small_light.tar.gz
RUN cd /tmp && \
    tar -xvzf ngx_small_light.tar.gz && \
    cd ngx_small_light && ./setup

# Install Nginx from sources
ADD http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz /tmp/nginx-${NGINX_VERSION}.tar.gz
RUN cd /tmp && \
    tar -xvzf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION} && \
    ./configure --prefix=/etc/nginx \
                --sbin-path=/usr/sbin/nginx \
                --conf-path=/etc/nginx/nginx.conf \
                --error-log-path=/var/log/nginx/error.log \
                --http-log-path=/var/log/nginx/access.log \
                --pid-path=/var/run/nginx.pid \
                --user=nginx --group=nginx \
                --with-http_ssl_module \
                --with-http_realip_module \
                --with-http_addition_module \
                --with-http_sub_module \
                --with-http_dav_module \
                --with-http_flv_module \
                --with-http_mp4_module \
                --with-http_gunzip_module \
                --with-http_gzip_static_module \
                --with-http_random_index_module \
                --with-http_secure_link_module \
                --with-http_stub_status_module \
                --with-http_auth_request_module \
                --with-http_xslt_module=dynamic \
                --with-http_image_filter_module=dynamic \
                --with-http_geoip_module=dynamic \
                --with-http_perl_module=dynamic \
                --add-dynamic-module=/tmp/ngx_small_light \
                --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module \
                --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_v2_module \
                --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic' \
                --with-ld-opt="-Wl,-E" && \
    make && make install


# Configure nginx site
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/image-resizer.conf /etc/nginx/conf.d/image-resizer.conf

# Deal with ssh
COPY ssh_keys/id_rsa /root/.ssh/id_rsa
COPY ssh_keys/id_rsa.pub /root/.ssh/id_rsa.pub
RUN echo "IdentityFile /root/.ssh/id_rsa" > /root/.ssh/config

# set root password
RUN echo 'root:password' | chpasswd
RUN sed -i 's/\#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/\#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

# generate server keys
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo 'SSHD: ALL' >> /etc/hosts.allow

EXPOSE 80

ADD init.sh /init.sh
RUN chmod +x /init.sh
CMD /init.sh