--initial setup and built in functions
getgenv().Message = function(Player, Message)
    local args = {
        [1] = "/w " .. Player .. " " .. Message,
        [2] = "All"
    }
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
    print(Message)
end
getgenv().CommaSplit = function(string)
    local values = {}
    local inQuote = false
    local buffer = ""
    for i = 1, #string do
        local char = string:sub(i, i)
        if char == '"' or char == "(" or char == ")" then
            inQuote = not inQuote
        elseif char == "," and not inQuote then
            table.insert(values, buffer:match("^%s*(.-)%s*$"))
            buffer = ""
        else
            buffer = buffer .. char
        end
    end
    table.insert(values, buffer:match("^%s*(.-)%s*$"))
    return values
end
getgenv().SpaceSplit = function(string)
    local values = {}
    local inQuote = false
    local buffer = ""
    for i = 1, #string do
        local char = string:sub(i, i)
        if char == '"' or char == "(" or char == ")" then
            inQuote = not inQuote
        elseif char == " " and not inQuote then
            table.insert(values, buffer:match("^%s*(.-)%s*$"))
            buffer = ""
        else
            buffer = buffer .. char
        end
    end
    table.insert(values, buffer:match("^%s*(.-)%s*$"))
    return values
end
getgenv().AuthLevels = {}
getgenv().getplayer = function(Name)
    local Name, Len, Found = string.lower(Name), #Name, {}
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if Name:sub(0, 1) == "@" then
            if string.sub(string.lower(v.Name), 1, Len - 1) == Name:sub(2) then
                table.insert(Found, v)
            end
        else
            if
                string.sub(string.lower(v.Name), 1, Len) == Name or
                    string.sub(string.lower(v.DisplayName), 1, Len) == Name
             then
                table.insert(Found, v)
            end
        end
    end
    return Found[1]
end
getgenv().Whitelist = {Players = {[getgenv().Main] = {Authorization = "Owner", Prefix = ";", Timelimit = false}}}

--commands
local CommandNames = {}
getgenv().ServantCommands = {}
getgenv().AddCommand = function(commandname,commandfunction,commandaliases,commandauth)
   getgenv().ServantCommands[commandname] = {
       run = commandfunction,
       authorization = commandauth
   }
   for i,v in pairs(commandaliases) do
   CommandName[v] = commandname
   end
end
local CommandProcessor = function(command, speaker, arguments)
    if table.find(Commands[command].authorization, Whitelist.Players[speaker].Authorization) or Whitelist.Players[speaker].Authorization == "Owner" then
        Commands[command].run(speaker,arguments)
    else
        getgenv().Message(speaker, "You do not have proper authorization to use that command.")
    end
end
local function chatted(player)
        player.Chatted:Connect(function(msg)
            if getgenv().Whitelist.Players[player.Name] then
                local commandparts = getgenv().SpaceSplit(msg)
                local iscommand = false
                local Command
                for command, data in pairs(CommandNames) do
                    if getgenv().Whitelist.Players[player.Name].Prefix .. tostring(command) == commandparts[1]:lower() then
                        iscommand = true
                        Command = data
                    end
                end
                if iscommand == true then
                        local args = ""
                        local match = string.find(msg, "%s+")
                        if match then
                        local args = string.sub(msg, string.find(msg, "%s+") + 1)
                        args =
                            args:gsub(
                            "(%b())",
                            function(s)
                                return s:gsub("%s+", "\001")
                            end
                        )
                        args =
                            args:gsub(
                            "(%b[])",
                            function(s)
                                return s:gsub("%s+", "\002")
                            end
                        )
                        args =
                            args:gsub(
                            '(%b"")',
                            function(s)
                                return s:gsub("%s+", "\003")
                            end
                        )
                        args = args:gsub('([^%(%[%]"%s]+)%s+([^%(%[%]"%s]+)', "%1,%2")
                        args = args:gsub("%s+", ",")
                        args = args:gsub("\001", " ")
                        args = args:gsub("\002", " ")
                        args = args:gsub("\003", " ")
                        end
                        CommandProcessor(Command, player.Name, args)
                        end
            end
end)
    end
game:GetService("Players").PlayerAdded:Connect(function(player)
    chatted(player)
end)
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
    chatted(player)
end
