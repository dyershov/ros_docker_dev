FROM ros:eloquent as base

# install base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
      sudo \
      zsh \
    && rm -rf /var/lib/apt/lists/*

# docker unprivileged user
ARG user=yershov
ARG group=yershov
ARG uid=1000
ARG gid=1000
ARG home=/home/${user}

RUN groupadd -g ${gid} ${group} \
    && useradd -d ${home} -u ${uid} -g ${gid} -m -s /bin/zsh ${user} \
    && echo "${user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudoers_${user} \
    && usermod -a -G sudo ${user}

COPY home/.zshrc ${home}/.zshrc

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
