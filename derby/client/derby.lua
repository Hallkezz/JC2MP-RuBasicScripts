class 'Derby'

function Derby:__init()
	Network:Subscribe( "DerbyEnter", self, self.Enter )
	Network:Subscribe( "DerbyExit", self, self.Exit )
    Network:Subscribe( "DerbyEnterVehicle", self, self.EnterVehicle )
    Network:Subscribe( "DerbyExitVehicle", self, self.ExitVehicle )

    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "ModuleLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

    self.timer = nil
end

function Derby:Enter()
    self.timer = nil
end

function Derby:Exit()
    self.timer = nil
end

function Derby:EnterVehicle()
    self.timer = nil
end

function Derby:ExitVehicle()
    self.timer = Timer()
end

function Derby:ModulesLoad()
    Events:Fire( "HelpAddItem",
        {
            name = "Дерби",
            text = 
                "Дерби - это свободный для всех автомобилей Смертельный Матч на карте Блюдо.\n \n" ..
                "Для входа в дерби, введите /derby в чат и нажмите Enter. " ..
                "Вы перенесетесь в дерби, где вы будете возрождаться " ..
                "пока вы не выйдете с помощью команды еще раз.\n \n" ..
                "Если вы остаетесь вне своего автомобиля более 20 секунд, вы будете " ..
                "убиты."
        } )
end

function Derby:ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Дерби"
        } )
end

function Derby:Render()
    if self.timer == nil then return end
    if Game:GetState() ~= GUIState.Game then return end

    local time = 20 - math.floor(math.clamp( self.timer:GetSeconds(), 0, 20 ))

    if time <= 0 then return end

    local text = tostring(time)

    local text_width = Render:GetTextWidth( text, TextSize.Gigantic )
    local text_height = Render:GetTextHeight( text, TextSize.Gigantic )

    local pos = Vector2(    (Render.Width - text_width)/2, 
                            (Render.Height - text_height)/2 )

    Render:DrawText( pos, text, Color( 255, 255, 255 ), TextSize.Gigantic )
end

derby = Derby()