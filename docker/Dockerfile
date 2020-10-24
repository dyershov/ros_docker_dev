FROM ros:eloquent as base

# docker unprivileged user
ARG user=yershov
ARG group=yershov
ARG uid=1000
ARG gid=1000
ARG home=/home/${user}

# Cannot configure packages interactively
ENV DEBIAN_FRONTEND=noninteractive
# librobotcontrol version
ARG LIBROBOTCONTROL_RELEASE=1.0.5

# install base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      sudo \
      zsh \
      wget \
      curl \
    && rm -rf /var/lib/apt/lists/*


RUN groupadd -g ${gid} ${group} \
    && useradd -d ${home} -u ${uid} -g ${gid} -m -s /bin/zsh ${user} \
    && echo "${user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudoers_${user} \
    && usermod -a -G sudo ${user} \
#    && addgroup --gid 15 kmem \
#    && usermod -a -G kmem ${user} \
    && addgroup --gid 114 i2c \
    && usermod -a -G i2c ${user} \
    && addgroup --gid 999 gpio \
    && usermod -a -G gpio ${user} \
    && addgroup --gid 998 pwm \
    && usermod -a -G pwm ${user} \
    && addgroup --gid 997 eqep \
    && usermod -a -G eqep ${user} \
    && addgroup --gid 996 remoteproc \
    && usermod -a -G remoteproc ${user} \
    && addgroup --gid 993 spi \
    && usermod -a -G spi ${user} \
    && addgroup --gid 992 iio \
    && usermod -a -G iio ${user}

COPY home/.zshrc ${home}/.zshrc

# librobotcontrol using deb package (unfortunately no deb for V1.0.5)
#RUN export ARCH="$(dpkg --print-architecture)" \
#    && echo "Downloading from https://github.com/beagleboard/librobotcontrol/releases/download/V${LIBROBOTCONTROL_RELEASE}/librobotcontrol_${LIBROBOTCONTROL_RELEASE}_${ARCH}.deb ..." \
#    && wget -q -O librobotcontrol.deb https://github.com/beagleboard/librobotcontrol/releases/download/V${LIBROBOTCONTROL_RELEASE}/librobotcontrol_${LIBROBOTCONTROL_RELEASE}_${ARCH}.deb \
#    && echo "Installing librobotcontrol.deb ..." \
#    && dpkg --unpack librobotcontrol.deb \
#    && unset ARCH \
#    && rm librobotcontrol.deb

# librobotcontrol from sources
RUN wget https://github.com/beagleboard/librobotcontrol/archive/V${LIBROBOTCONTROL_RELEASE}.tar.gz \
    && tar -xzvf V${LIBROBOTCONTROL_RELEASE}.tar.gz \
    && cd librobotcontrol-${LIBROBOTCONTROL_RELEASE} \
    && make \
    && sudo make install \
    && cd .. \
    && rm -r librobotcontrol-${LIBROBOTCONTROL_RELEASE}

USER ${user}
WORKDIR ${home}

CMD [ "/bin/zsh" ]


###
##  Container with ros examples
###
FROM base as examples

# install demo ros packages
RUN sudo apt-get update && sudo apt-get install -y \
      ros-${ROS_DISTRO}-demo-nodes-cpp \
      ros-${ROS_DISTRO}-demo-nodes-py \
      ros-${ROS_DISTRO}-turtlesim && \
    sudo rm -rf /var/lib/apt/lists/*

###
##  Container with ros tools such as introspection, record, and replay
###
FROM base as tools

# install rqt and rosbag packages
RUN sudo apt-get update && sudo apt-get install -y \
      "ros-${ROS_DISTRO}-rqt*" \
      ros-${ROS_DISTRO}-ros2bag \
      ros-${ROS_DISTRO}-rosbag2 \
      ros-${ROS_DISTRO}-rosbag2-transport && \
    sudo rm -rf /var/lib/apt/lists/*
