# used the tutorial for the basic function from
# http://www.sitepoint.com/ruby-tcp-chat/
# created the functionality for users and other disconnect

require "socket"

class Server
  def initialize( port, ip )
    @server = TCPServer.open( ip, port )
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    run
  end

  def run
    loop {
      Thread.start(@server.accept) do | client |
        nick_name = client.gets.chomp.to_sym
        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exist"
            Thread.kill self
          end
        end
        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "Connection established, Thank you for joining! Happy chatting"
        listen_user_messages( nick_name, client )
      end
    }.join
  end

  def listen_user_messages( username, client )
  	
  	client.puts
    client.puts "Enter users to find the other users in the chat"
    client.puts "Enter disconnect to stop the chat server"
    client.puts "Otherwise enter message to other users"
    client.puts
    
    loop {
      
      msg = client.gets.chomp
      
      if msg == "users"
      	@connections[:clients].each do |other_name, other_client|
        	if other_name != username
         	 client.puts "#{other_name.to_s} "
       	 end
      	end
      elsif msg == "disconnect"
      	client.puts "Your thread has been disconnected. Open new window to reconnect"
      		@connections[:clients].each do |other_name, other_client|
        	unless other_name == username
          	other_client.puts "#{username.to_s} has killed the chat server"
        	end
      	end
      	@server.close
      else
      	@connections[:clients].each do |other_name, other_client|
        	unless other_name == username
          	other_client.puts "#{username.to_s}: #{msg}"
        	end
      	end
      end	
    }
  end
  
end

Server.new( 3000, "localhost" )