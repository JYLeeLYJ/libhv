#include <atomic>
#include <thread>
#include <iostream>
#include "ioutils/tcp.hpp"
#include "future.hpp"

using coio::future , coio::io_context ;
using coio::tcp_sock , coio::ipv4 , coio::acceptor ;
using coio::to_bytes , coio::to_const_bytes;

// std::atomic<uint64_t> cnt{};

future<void> start_session(tcp_sock<> sock) {
    uint64_t read_cnt {};
    try{
    auto buff = std::vector<std::byte>(1024);
    while(true){
        auto n = co_await sock.recv(buff);
        if(n == 0) break;
        [[maybe_unused]]
        auto m = co_await sock.send(std::span{buff.begin() , n});
        assert(m == n);
        read_cnt += n;
    }
    }catch(const std::exception & e){
        std::cout << "exception : " <<  e.what() << std::endl ;
    }
    // cnt+= read_cnt ;
}

future<void> server(io_context & ctx , uint16_t port ){
    try{
        auto accpt = acceptor{};
        accpt.bind(ipv4::address{port,"127.0.0.1"});
        accpt.listen();
        while(true){
            auto sock = co_await accpt.accept();
            ctx.co_spawn(start_session(std::move(sock)));
        }
    }catch(const std::exception & e){
        std::cout << "exception : " <<  e.what() << std::endl ;
    }
}

int main(int argc , char * argv[]){
    if (argc < 2) {
        puts("Usage: cmd port\n");
        return -10;
    }

    uint16_t port = std::stoul(argv[1]);
    std::cout << "port = " << port << std::endl;
    
    coio::io_context ctx{
        // coio::ctx_opt{.sq_polling = true}
    };
    auto _ = ctx.bind_this_thread();
    ctx.co_spawn(server(ctx , port));
    ctx.run();
}