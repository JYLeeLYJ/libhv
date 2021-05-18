#!/bin/bash

SCRIPT_DIR=$(cd `dirname $0`; pwd)
ROOT_DIR=${SCRIPT_DIR}/..

# install libevent libev libuv asio poco
# sudo apt install libevent-dev libev-dev libuv1-dev libboost-dev libboost-system-dev libasio-dev libpoco-dev

# install muduo => https://github.com/chenshuo/muduo.git
if false; then
cd ${ROOT_DIR}/..
git clone https://github.com/chenshuo/muduo.git
cd muduo
mkdir build && cd build
cmake .. && make && sudo make install
fi

if false ; then 
cd ${ROOT_DIR}
git clone https://github.com/haraldh/rust_echo_bench
fi

cd ${ROOT_DIR}
# make libhv && sudo make install
make echo-servers
# make webbench
