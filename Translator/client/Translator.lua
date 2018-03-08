class 'Translator'

function Translator:__init()
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function Translator:ModulesLoad()
    Events:Fire( "HelpAddItem",
        {
            name = "Перевод",
            text = 
                "Перевод сборки от Hallkezz\n" ..
                "Приятной игры :3"
        } )
end

function Translator:ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Перевод"
        } )
end

Translator = Translator()