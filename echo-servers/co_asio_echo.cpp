#include <cstdlib>
#include <iostream>
#include <string>
#define BOOST_ASIO_HAS_CO_AWAIT
#include <boost/asio.hpp>

using boost::asio::awaitable ;
using boost::asio::ip::tcp;

awaitable<void> start_session(tcp::socket sock){
    std::string buffer(1024 , ' ');
    try{
        while(sock.is_open()){
            auto buff = boost::asio::buffer(buffer.data() , buffer.size());
            auto n = co_await sock.async_receive(buff , boost::asio::use_awaitable);
            co_await sock.async_send(boost::asio::buffer(buffer.data() , n) , boost::asio::use_awaitable);
        }
    }
    catch(const std::exception & e){
        // printf("server exception...\n");
    }
}

awaitable<void> server(boost::asio::io_context & ctx , uint16_t port){
    auto executor = co_await boost::asio::this_coro::executor;
    auto acceptor = tcp::acceptor{executor , {tcp::v4() , port}};
    while(true){
        auto socket = tcp::socket{executor};
        co_await acceptor.async_accept(socket , boost::asio::use_awaitable);
        // boost::asio::co_spawn( ctx , start_session(std::move(socket)) , boost::asio::detached);
        boost::asio::co_spawn(
            ctx ,
            [sock = std::move(socket)]()mutable->awaitable<void>{ 
                co_await start_session(std::move(sock)) ;
            },
            boost::asio::detached
        );
    }
}


int main(int argc , char** argv){
    if(argc < 2) {
        puts("Usage: cmd port\n");
        return -10;
    }

    uint16_t port = std::stoul(argv[1]);
    boost::asio::io_context ctx{1};
    // boost::asio::co_spawn(ctx , server(ctx , port) , boost::asio::detached);
    boost::asio::co_spawn(
        ctx , 
        [&]()->awaitable<void> {
            co_await server(ctx , port);
        } , 
        boost::asio::detached
    );
    ctx.run();
}