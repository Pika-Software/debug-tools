local NikNaks = NikNaks
local render = render
local hook = hook
local cam = cam

local identifier = gpm.Package:GetIdentifier( "world-bounds" )
local developer = GetConVar( "developer" )
local Material = Material
local Vector = Vector

function DevTools.WorldBoundsRendering()
    if developer:GetInt() < 5 then
        hook.Remove( "PreDrawEffects", identifier )
        return
    end

    local map = NikNaks.CurrentMap
    local mins, maxs = map:WorldMin(), map:WorldMax()

    local top = {
        Vector( mins.x, mins.y, maxs.z ),
        Vector( mins.x, maxs.y, maxs.z ),
        Vector( maxs.x, maxs.y, maxs.z ),
        Vector( maxs.x, mins.y, maxs.z )
    }

    local bottom = {
        Vector( mins.x, mins.y, mins.z ),
        Vector( mins.x, maxs.y, mins.z ),
        Vector( maxs.x, maxs.y, mins.z ),
        Vector( maxs.x, mins.y, mins.z )
    }

    local boundMaterial = DevTools.BoundBaterial
    if not boundMaterial then
        boundMaterial = Material( "sprites/gmdm_pickups/light" ); DevTools.BoundBaterial = boundMaterial
    end

    local beamMaterial = DevTools.BeamMaterial
    if not beamMaterial then
        beamMaterial = Material( "cable/new_cable_lit" ); DevTools.BeamMaterial = beamMaterial
    end

    local worldColor = DevTools.WorldColor
    if not worldColor then
        worldColor = Color( 225, 125, 25 )
    end

    hook.Add( "PreDrawEffects", identifier, function()
        cam.IgnoreZ( true )
            render.SetMaterial( boundMaterial )

            -- Top bounds
            for i = 1, 4 do
                render.DrawSprite( top[ i ], 512, 512, worldColor )
            end

            -- Bottom bounds
            for i = 1, 4 do
                render.DrawSprite( bottom[ i ], 512, 512, worldColor )
            end

            render.SetMaterial( beamMaterial )

            -- Top Lines
            render.DrawBeam( top[ 1 ], top[ 2 ], 8, 0, 12, worldColor )
            render.DrawBeam( top[ 2 ], top[ 3 ], 8, 0, 12, worldColor )
            render.DrawBeam( top[ 3 ], top[ 4 ], 8, 0, 12, worldColor )
            render.DrawBeam( top[ 4 ], top[ 1 ], 8, 0, 12, worldColor )

            -- Bottom Lines
            render.DrawBeam( bottom[ 1 ], bottom[ 2 ], 8, 0, 12, worldColor )
            render.DrawBeam( bottom[ 2 ], bottom[ 3 ], 8, 0, 12, worldColor )
            render.DrawBeam( bottom[ 3 ], bottom[ 4 ], 8, 0, 12, worldColor )
            render.DrawBeam( bottom[ 4 ], bottom[ 1 ], 8, 0, 12, worldColor )

            -- Vertical Lines
            render.DrawBeam( bottom[ 1 ], top[ 1 ], 8, 0, 12, worldColor )
            render.DrawBeam( bottom[ 2 ], top[ 2 ], 8, 0, 12, worldColor )
            render.DrawBeam( bottom[ 3 ], top[ 3 ], 8, 0, 12, worldColor )
            render.DrawBeam( bottom[ 4 ], top[ 4 ], 8, 0, 12, worldColor )
        cam.IgnoreZ( false )
    end )

end

cvars.AddChangeCallback( "developer", function()
    util.NextTick( DevTools.WorldBoundsRendering )
end, identifier )

DevTools.WorldBoundsRendering()