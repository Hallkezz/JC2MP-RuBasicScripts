class 'Killfeed'

function Killfeed:__init()
    self.active = true
    self.list = {}
    self.removal_time = 10

    self:CreateKillStrings()

    Network:Subscribe( "PlayerDeath", self, self.PlayerDeath )
    Events:Subscribe( "Render", self, self.Render )
    Events:Subscribe( "LocalPlayerChat", self, self.LocalPlayerChat )

    Events:Subscribe( "ModuleLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModulesLoad", self, self.ModulesLoad )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )
end

function Killfeed:PlayerDeath( args )
    if not IsValid( args.player ) then return end

    -- With the addition of player:Damage(), custom reasons may be passed around.
    -- We need to make sure we actually know how to handle them, otherwise we 
    -- should to override it to None.
    local reason = args.reason

    if args.killer then
        if not self.killer_msg[reason] then
            reason = DamageEntity.None
        end
    else
        if not self.no_killer_msg[reason] then
            reason = DamageEntity.None
        end
    end

    if args.killer then
        args.message = string.format( 
            self.killer_msg[reason][args.id], 
            args.player:GetName(), 
            "     " .. args.killer:GetName() )

        args.killer_name   = args.killer:GetName()
        args.killer_colour = args.killer:GetColor()
    else
        args.message = string.format( 
            self.no_killer_msg[reason][args.id], 
            args.player:GetName() )
    end

    args.player_name   = args.player:GetName()
    args.player_colour = args.player:GetColor()

    args.time = os.clock()

    table.insert( self.list, args )
end

function Killfeed:CreateKillStrings()
    self.no_killer_msg = {
        [DamageEntity.None] = { 
            "%s умер от неизвестной причины!",
            "%s случился сердечный приступ!",
            "%s скончался от естественных причин!"
        },

        [DamageEntity.Physics] = { 
            "%s был убит огромной силой физики!",
            "%s ударить что-то - смертельно!",
            "%s узнал, что законы физики ненавидят его!"
        },

        [DamageEntity.Bullet] = { 
            "%s был застрелен!",
            "%s был смертельно ранен!",
            "%s умер от отравления свинцом!"
        },

        [DamageEntity.Explosion] = { 
            "%s не смог выдержать силу ВЗРЫВОВ!",
            "%s был взрывоопасен.",
            "%s придется склеить. В АДУ!"
        },

        [DamageEntity.Vehicle] = {
            "%s забыл надеть свой ремень безопасности!",
            "%s попал под машину!",
            "%s подделал водительские права!"
        }
    }

    self.killer_msg = {
        [DamageEntity.None] = { 
            "%s был как-то убит %s!",
            "%s был тронут магией %s!",
            "%s почувствовал силу невозможного %s!"
        },

        [DamageEntity.Physics] = { 
            "%s не может справиться с физической силой %s!",
            "%s пострадал от массивной физической травмы %s!",
            "%s встретил физику, и ее посланник %s!"
        },

        [DamageEntity.Bullet] = { 
            "%s был скошен %s!",
            "%s был измельчен %s!",
            "%s был набит пулями %s!",
        },

        [DamageEntity.Explosion] = { 
            "%s был разорван на миллион кусочков %s!",
            "%s: теперь работает от взрывов, любезно предоставлено %s!",
            "%s был взорван %s!"
        },

        [DamageEntity.Vehicle] = {
            "%s был запущен %s!",
            "%s попался в ярость дороги %s!",
            "%s был убит в кармагеддоне %s!"
        }
    }
end

function Killfeed:CalculateAlpha( time )
    local difftime = os.clock() - time
    local removal_time_gap = self.removal_time - 1

    if difftime < removal_time_gap then
        return 255
    elseif difftime >= removal_time_gap and difftime < self.removal_time then
        local interval = difftime - removal_time_gap
        return 255 * (1 - interval)
    else
        return 0
    end
end

function Killfeed:LocalPlayerChat( args )
    if args.text == "/killfeed" then
        self.active = not self.active

        if self.active then
            Chat:Print( "Killfeed включен!", Color( 255, 255, 255 ) )
        else
            Chat:Print( "Killfeed отключен!", Color( 255, 255, 255 ) )
        end
    end
end

function Killfeed:ModulesLoad()
    Events:Fire( "HelpAddItem",
        {
            name = "Чат убийств",
            text = 
                "Чат убийств - это список смертей в правой части экрана.\n" ..
                "Он показывает только смерть рядом с вами.\n \n" ..
                "Чтобы включить/выключить его, введите /killfeed в чате."
        } )
end

function Killfeed:ModuleUnload()
    Events:Fire( "HelpRemoveItem",
        {
            name = "Чат убийств"
        } )
end

function Killfeed:Render( args )
    if Game:GetState() ~= GUIState.Game then return end
    if not self.active then return end

    local center_hint = Vector2( Render.Width - 5, Render.Height / 2 )
    local height_offset = 0

    for i,v in ipairs(self.list) do
        if os.clock() - v.time < self.removal_time then
            local text_width = Render:GetTextWidth( v.message )
            local text_height = Render:GetTextHeight( v.message )

            local pos = center_hint + Vector2( -text_width, height_offset )
            local alpha = self:CalculateAlpha( v.time )

            local shadow_colour = 
                Color( 20, 20, 20, alpha * 0.5 )

            Render:DrawText( pos + Vector2( 1, 1 ), v.message, shadow_colour )
            Render:DrawText( pos, v.message, 
                Color( 255, 255, 255, alpha ) )

            local player_colour = v.player_colour
            player_colour.a = alpha

            Render:DrawText( 
                pos, 
                v.player_name, 
                player_colour )

            local img_width = text_height

            if IsValid( v.player, false ) then
                Render:FillArea( pos - Vector2( img_width + 2, 0 ), Vector2( img_width - 1, img_width - 1 ), shadow_colour )
                v.player:GetAvatar():Draw( pos - Vector2( img_width + 3, 1 ), Vector2( img_width, img_width ), Vector2( 0, 0 ), Vector2( 1, 1 ) )
            end

            if v.killer_name ~= nil then
                local killer_colour = v.killer_colour
                killer_colour.a = alpha
                local name_text = v.killer_name .. "!"
                local name_width = Render:GetTextWidth( name_text )

                Render:DrawText( 
                    center_hint + Vector2( -name_width, height_offset ), 
                    v.killer_name, 
                    killer_colour )

                if IsValid( v.killer, false ) then
                    pos = center_hint + Vector2( -name_width, height_offset )
                    Render:FillArea( pos - Vector2( img_width + 2, 0 ), Vector2( img_width - 1, img_width - 1 ), shadow_colour )
                    v.killer:GetAvatar():Draw( pos - Vector2( img_width + 3, 1 ), Vector2( img_width, img_width ), Vector2( 0, 0 ), Vector2( 1, 1 ) )
                end
            end

            height_offset = height_offset + text_height + 4
        else
            table.remove( self.list, i )
        end
    end
end

local killfeed = Killfeed()