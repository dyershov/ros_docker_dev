#! /bin/bash
#

GIT_SOURCES=()
PACKAGES=()
VERBOSE=false

function print {
    if [[ $VERBOSE ]] ; then
	echo $1
    fi
}

while getopts ":g:p:v" opt; do
    case ${opt} in
	g )
	    GIT_SOURCES+=("$OPTARG")
	    ;;
	p )
	    PACKAGES+=("$OPTARG")
	    ;;
	v )
	    VERBOSE=true
	    ;;
	\? ) echo "Usage: cmd [-g <git source url>] [-p <ros package to install>] -v"
	     ;;
    esac
done

print "Preparation..."
source /opt/ros/${ROS_DISTRO}/setup.bash
sudo apt-get update

mkdir -p ros_ws/src
cd ros_ws/src

for SOURCE in "${GIT_SOURCES[@]}"; do
    print "Downloading ${SOURCE}..."
    git clone ${SOURCE}
done

cd ..

print "Installing dependencies..."
rosdep update
rosdep install -i --from-path src --rosdistro ${ROS_DISTRO} -y

print "Building packages..."
colcon build

for PACKAGE in "${PACKAGES[@]}"; do
    print "Installing ${PACKAGE}..."
    sudo cp -r install/${PACKAGE}/* /opt/ros/${ROS_DISTRO}/
    sudo chown root:root -R /opt/ros/${ROS_DISTRO}/
done

print "Cleanup..."
cd ..
rm -rf ros_ws
sudo rm -rf /var/lib/apt/lists/*

print "Done!"
