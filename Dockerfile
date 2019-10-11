FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
  apt-utils \
  build-essential \
  cmake \
  sudo

#####################################################################
# Setup ssh service
RUN apt-get update && apt-get install -y \
  openssh-server \
  zsh \
  tmux \
  vim \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN apt-get update && apt-get install -y locales

RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
#####################################################################

#####################################################################
# Setup X-windows stuff
RUN apt-get update && apt-get install -y \
  xauth \
  x11-apps \
  x11-common \
  x11-session-utils \
  x11-utils \
  x11-xserver-utils \
  && rm -rf /var/lib/apt/lists/*

# Fixed X11 forwarding
RUN echo X11Forwarding yes >> /etc/ssh/sshd_config
RUN sed -i 's/.*X11UseLocalhost.*/X11UseLocalhost no/' /etc/ssh/sshd_config
RUN echo X11UseLocalhost no >> /etc/ssh/sshd_config

#####################################################################

RUN apt-get update && apt-get install -y \
  binutils-mingw-w64-x86-64 \
  gcc-mingw-w64-x86-64 \
  mingw-w64 \
  mingw-w64-tools

CMD ["/usr/sbin/sshd", "-D"]
