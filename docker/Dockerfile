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

# upgrade?
RUN apt-get update && apt-get upgrade -y

# install base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      sudo \
      zsh \
      wget \
      curl \
      less \
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
    && rm -r librobotcontrol-${LIBROBOTCONTROL_RELEASE} \
    && rm V${LIBROBOTCONTROL_RELEASE}.tar.gz

USER ${user}
WORKDIR ${home}

CMD [ "/bin/zsh" ]

###
##  Joystic teleop container
###
FROM base as joy

ARG user=yershov
ARG home=/home/${user}

# install rqt and rosbag packages
RUN sudo apt-get update \
    && sudo apt-get install -y \
       	    	    	    ros-${ROS_DISTRO}-joy \
		    	    ros-${ROS_DISTRO}-teleop-twist-joy \
    && sudo rm -rf /var/lib/apt/lists/*

COPY home/config/teleop_twist/xbox_joy.yaml ${home}/config/teleop_twist/xbox_joy.yaml

CMD [ "/bin/zsh" ]

###
##  Container with ros tools such as introspection, record, and replay
###
FROM base as tools

#####  Copied from nVidia GL container recepe
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
       	 libxau6 \
	 libxdmcp6 \
	 libxcb1 \
	 libxext6 \
	 libx11-6 \
    && sudo rm -rf /var/lib/apt/lists/*

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics,compat32,utility

RUN sudo sh -c "echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf ; \
    	        echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf"

# Required for non-glvnd setups.
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64

RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends \
      libglvnd0 \
      libgl1 \
      libglx0 \
      libegl1 \
      libgles2 \
    && sudo rm -rf /var/lib/apt/lists/*

COPY 10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# install ROS tools packages
RUN sudo apt-get update && sudo apt-get install -y \
      "ros-${ROS_DISTRO}-rqt*" \
      ros-${ROS_DISTRO}-ros2bag \
      ros-${ROS_DISTRO}-rosbag2 \
      ros-${ROS_DISTRO}-rosbag2-transport \
      ros-${ROS_DISTRO}-rviz2 \
    && sudo rm -rf /var/lib/apt/lists/*


###
##  Container with ros camera
###
FROM base as camera

ARG user=yershov
ARG home=/home/${user}

RUN sudo groupmod -g 986 video
RUN sudo usermod -a -G video yershov # ???

COPY home/install_ros_packages.bash ${home}/

RUN bash ${home}/install_ros_packages.bash -g https://github.com/klintan/ros2_usb_camera.git -p usb_camera_driver -v

RUN sudo apt-get update && sudo apt-get install -y \
      ros-${ROS_DISTRO}-image-transport-plugins \
    && sudo rm -rf /var/lib/apt/lists/*

# install demo ros packages
RUN sudo apt-get update && sudo apt-get install -y \
      ros-${ROS_DISTRO}-v4l2-camera \
    && sudo rm -rf /var/lib/apt/lists/*

###
##  Container with ros examples
###
FROM base as examples

# install demo ros packages
RUN sudo apt-get update && sudo apt-get install -y \
      ros-${ROS_DISTRO}-demo-nodes-cpp \
      ros-${ROS_DISTRO}-demo-nodes-py \
      ros-${ROS_DISTRO}-turtlesim \
    && sudo rm -rf /var/lib/apt/lists/*
