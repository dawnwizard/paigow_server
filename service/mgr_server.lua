local skynet = require "skynet"
local socket = require "skynet.socket"
local websocket = require "websocket"
local httpd = require "http.httpd"
local urllib = require "http.url"
local sockethelper = require "http.sockethelper"

local tcode = require "tcode"



local handler = {}
function handler.on_open(ws)
    print(string.format("%d::open", ws.id))
end

local switch = {
    [1] = function ( ws, t_msg )
        print(string.format("%d receive:%s", ws.id, t_msg.msg_type))
        -- ws:send_text(message)
    end,
}
function handler.on_message(ws, message)
    -- print(string.format("%d receive:%s", ws.id, message.type))
    local t_msg = tcode.decode(message)
    local fswitch = switch[t_msg.type]
    if fswitch then
        fswitch(ws, t_msg)
    else
        print("error message type:" .. message.type)
        require 'json'
        ws:send_text(json.encode(message))
    end
    ws:close()
end

function handler.on_close(ws, code, reason)
    print(string.format("%d close:%s  %s", ws.id, code, reason))
end

local function handle_socket(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
    if code then
        if header.upgrade == "websocket" then
            local ws = websocket.new(id, header, handler)
            ws:start()
        end
    end
end

skynet.start(function()
    local address = "0.0.0.0:8080"
    skynet.error("Listening "..address)
    local id = assert(socket.listen(address))
    socket.start(id , function(id, addr)
       socket.start(id)
       pcall(handle_socket, id)
    end)
end)
