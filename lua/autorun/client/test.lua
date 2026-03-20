if SERVER then return end

local function LoadHTMLFile(panel, path)
    local html = file.Read(path, "GAME")
    if html then
        panel:SetHTML(html)
    else
        panel:SetHTML("<body style='color:red'>HTML не найден</body>")
    end
end

local frame_open
local html_open
local InFocus = false
local DefChat = false

hook.Add("StartChat", "MyChatOpenHook", function(teamChat)
    DefChat = true
end)

hook.Add("FinishChat", "MyChatCloseHook", function()
    DefChat = false
end)

hook.Add("InitPostEntity", "MyHTMLOverlay", function()
    local sizeX = ScrW()/5
    local sizeY = ScrH()/3
    frame_open = vgui.Create("DFrame")
    frame_open:SetSize(sizeX, sizeY)
    frame_open:SetPos(0, 0)
    frame_open:SetTitle("")
    frame_open:ShowCloseButton(false)
    frame_open:SetDraggable(false)
    //frame_open:MakePopup()
    frame_open:SetBackgroundBlur(false)
    frame_open.Paint = function() end

    html_open = vgui.Create("DHTML", frame_open)
    html_open:SetSize(sizeX, sizeY)
    html_open:SetPos(0, 0)
    LoadHTMLFile(html_open, "html/ui/enter.html")

    html_open:AddFunction("gmod", "setInFocus", function(inf)
        InFocus = inf
    end)
    html_open:AddFunction("gmod", "getPlayerInfo", function()
        local ply = LocalPlayer()
        
        local data = {
            name = ply:Nick(),
            steamid = ply:SteamID(),
            sid64 = ply:SteamID64()
        }
        
        local json = util.TableToJSON(data)
        html_open:Call("receivePlayerInfo(" .. json .. ");")
    end)
end)

hook.Add("PlayerBindPress", "PreventConsoleOpening", function(ply, bind, pressed)
    if string.find(bind, "toggleconsole") then
        return true 
    end
end)

hook.Add("PreRender", "DetectGameMenu", function()
    if gui.IsGameUIVisible() then
        frame_open:SetVisible(false)
    else
        frame_open:SetVisible(true)
    end
end)

local isOpen = false

local function ToggleMenu()
    isOpen = not isOpen

    if isOpen then
        frame_open:SetMouseInputEnabled(true)
        frame_open:SetKeyboardInputEnabled(true)
        frame_open:MakePopup()
        gui.EnableScreenClicker(true)
    else
        frame_open:SetMouseInputEnabled(false)
        frame_open:SetKeyboardInputEnabled(false)
        gui.EnableScreenClicker(false)
    end
    
    html_open:Call("hideBlock(" .. tostring(not isOpen) .. ");")
    
end


local wasPressed = false
hook.Add("Think", "CheckKeyComboOnce", function()
    if input.IsKeyDown(KEY_I) and not InFocus and not DefChat then
        if not wasPressed then
            ToggleMenu()
            wasPressed = true
        end
    else
        wasPressed = false
    end
end)