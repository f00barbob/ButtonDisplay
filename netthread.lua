
print("entered networking thread!")


--local host, port = "192.168.1.50", 2222 -- was for testing
local host, port = "127.0.0.1", 22222
local socket = require("socket")
local tcp = assert(socket.tcp())
local moob
local retrycount = 0
local laststatus = "nil"
local msgcnt = 0
local recvcnt = 0

print("grabbing channel..")
local netchun = love.thread.getChannel("netchan")
print("got channel..")


function string:split( inSplitPattern, outResults )
  if not outResults then
    outResults = { }
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( self, theStart ) )
  return outResults
end




function connect_tcp()
	
	print("Attempting tcp connection: " .. host .. ":" .. port)
	tcp:settimeout(1)
	local condata, conerr = tcp:connect(host, port)
	if not conerr then
		retrycount = 0
	end
	print()
	io.write("condata: \t")
	io.write(condata or "nil")
	io.write("\tconerr: \t")
	io.write(conerr or "nil")
	io.write("\n")

	if conerr == "already connected" then
		tcp:close()
		tcp = assert(socket.tcp())
		connect_tcp()
	end

--	print("data:" .. condata)--or "nil...err:" .. conerr or "nil"  )
	tcp:send("hello...\n")	
	print("greeting sent ")

end



print("pro")
connect_tcp()

while true do
	io.write("\r") -- return the cursor to start of line
	local s, status, partial
	s, status, partial = tcp:receive()

	local nom = s or partial

	if s or partial and status ~= "timeout" then 
		recvcnt = recvcnt + 1
--		io.write("nom:" .. nom)
		local msg = nom:split(":")
		next_command 	= msg[1]
		next_value 	= msg[2]
--		print ("nc=" .. next_command)
--		print ( " nv=" .. next_value)
		if next_command == "COMMAND"
		or next_command == "PRESS"
		or next_command == "HOLD" then
			print("pushing" .. next_value)
			netchun:push(next_value)
		end
		tcp:send("ACK:" .. recvcnt)
	end

	if status == "closed"
	or status == "Socket is not connected"
	or status == "Transport endpoint is not connected" then
		retrycount = retrycount + 1	
		print("Attempting reconnect:" .. retrycount)
		socket.sleep(1)
		connect_tcp()

	elseif status == "timeout" then
		
	end
	--io.write("\trecvcnt:" .. recvcnt)
	io.flush()

--	socket.sleep(.01) -- prevent 100% core usage.

end





