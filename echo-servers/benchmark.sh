#!/bin/bash

host=127.0.0.1
port=2000
client=2
time=10

while getopts 'h:p:c:t:' opt
do
    case $opt in
        h) host=$OPTARG;;
        p) port=$OPTARG;;
        c) client=$OPTARG;;
        t) time=$OPTARG;;
        *) exit -1;;
    esac
done

SCRIPT_DIR=$(cd `dirname $0`; pwd)
cd ${SCRIPT_DIR}/..

killall_echo_servers() {
    #sudo killall libevent_echo libev_echo libuv_echo libhv_echo asio_echo poco_echo muduo_echo
    if [ $(ps aux | grep _echo | grep -v grep | wc -l) -gt 0 ]; then
        ps aux | grep _echo | grep -v grep | awk '{print $2}' | xargs sudo kill -9
    fi
}

export LD_LIBRARY_PATH=lib:$LD_LIBRARY_PATH

killall_echo_servers

sport=$port

# if [ -x bin/libevent_echo ]; then
#     let port++
#     bin/libevent_echo $port &
#     echo "libevent running on port $port"
# fi

# if [ -x bin/libev_echo ]; then
#     let port++
#     bin/libev_echo $port &
#     echo "libev running on port $port"
# fi

# if [ -x bin/libuv_echo ]; then
#     let port++
#     bin/libuv_echo $port &
#     echo "libuv running on port $port"
# fi

if [ -x bin/libhv_echo ]; then
    let port++
    bin/libhv_echo $port &
    echo "libhv running on port $port"
fi

# if [ -x bin/asio_echo ]; then
#     let port++
#     bin/asio_echo $port &
#     echo "asio running on port $port"
# fi

# if [ -x bin/poco_echo ]; then
#     let port++
#     bin/poco_echo $port &
#     echo "poco running on port $port"
# fi

# if [ -x bin/muduo_echo ]; then
#     let port++
#     taskset -c 4 bin/muduo_echo $port &
#     echo "muduo running on port $port"
# fi

if [ -x bin/coio_echo ]; then
    let port++
    taskset -c 0,1 bin/coio_echo $port > bin/server_log.txt 2>&1 &
    echo "coio running on port $port"
fi

if [ -x bin/co_asio_echo ]; then
    let port++
    bin/co_asio_echo $port &
    echo "asio(coroutine) running on port $port"
fi

if [ -x bin/cio_uring_echo ]; then
    let port++
    bin/cio_uring_echo $port &
    echo "cio_uring_echo running on port $port"
fi

sleep 1
# cd ./rust_echo_bench

for ((p=$sport+1; p<=$port; ++p)); do
    echo -e "\n==============$p====================================="
    # bin/webbench -q -c $client -t $time $host:$p
    taskset -c 2,3 bin/pingpong_client -H $host -p $p -c 1000
    # cargo run --release -- --address "localhost:$port" --number 150 --duration 10 --length 1024 
    sleep 1
done

killall_echo_servers
