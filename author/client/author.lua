class 'Author'

function Author:__init()
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function Author:ModulesLoad()
    Events:Fire( "HelpAddItem",
        {
            name = "Локализация",
            text = 
                "Автор: Hallkezz"
        } )
end

function Author:ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Локализация"
        } )
end

author = Author()