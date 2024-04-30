--initial setup and built in functions
getgenv().RemoveOuterQuotes = function(str)
    local content = str:match('^"(.*)"$')
    return content or str
end

getgenv().Message = function(Player, Message)
    local args = {
        [1] = "/w " .. Player .. " " .. Message,
        [2] = "All"
    }
    pcall(
        function()
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
        end
    )
    local name = game:GetService("Players"):FindFirstChild(Player).DisplayName
    name = string.split(name, "")
    local command = "/"
    game:GetService("CoreGui").ExperienceChat.appLayout.chatInputBar.Background.Container.TextContainer.TextBoxContainer.TextBox.Text =
        command
    command = "/w"
    game:GetService("CoreGui").ExperienceChat.appLayout.chatInputBar.Background.Container.TextContainer.TextBoxContainer.TextBox.Text =
        command
    command = "/w "
    game:GetService("CoreGui").ExperienceChat.appLayout.chatInputBar.Background.Container.TextContainer.TextBoxContainer.TextBox.Text =
        command
    for i, v in name do
        command = command .. v
        game:GetService("CoreGui").ExperienceChat.appLayout.chatInputBar.Background.Container.TextContainer.TextBoxContainer.TextBox.Text =
            command
    end
    repeat
        task.wait()
    until game:GetService("TextChatService").TextChannels:FindFirstChild(
        "RBXWhisper:" ..
            tostring(game:GetService("Players"):FindFirstChild(Player).UserId) ..
                "_" .. tostring(game:GetService("Players").LocalPlayer.UserId)
    )
    game:GetService("TextChatService").TextChannels:FindFirstChild(
        "RBXWhisper:" ..
            tostring(game:GetService("Players"):FindFirstChild(Player).UserId) ..
                "_" .. tostring(game:GetService("Players").LocalPlayer.UserId)
    ):SendAsync(Message)
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
getgenv().AddCommand = function(commandname, commandfunction, commandaliases, commandauth)
    commandname = commandname:lower()
    getgenv().ServantCommands[commandname] = {
        run = commandfunction,
        authorization = commandauth
    }
    for i, v in pairs(commandaliases) do
        CommandNames[v:lower()] = commandname
    end
end
local CommandProcessor = function(command, speaker, arguments)
    if
        table.find(getgenv().ServantCommands[command].authorization, getgenv().Whitelist.Players[speaker].Authorization) or
            getgenv().Whitelist.Players[speaker].Authorization == "Owner"
     then
        getgenv().ServantCommands[command].run(speaker, arguments)
    else
        print("no :(")
        getgenv().Message(speaker, "You do not have proper authorization to use that command.")
    end
end
local function chatted(player)
    player.Chatted:Connect(
        function(msg)
            if getgenv().Whitelist.Players[player.Name] then
                print(player.Name)
                for i, v in getgenv().Whitelist.Players do
                    print(i, v)
                end
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
                    local command, args = msg:match("^(%S+)%s*(.-)$")
                    CommandProcessor(Command, player.Name, args)
                end
            end
        end
    )
end
game:GetService("Players").PlayerAdded:Connect(
    function(player)
        chatted(player)
    end
)
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
    chatted(player)
end
