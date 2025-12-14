SMODS.Atlas({
    key = 'random_joker',
    path = 'Parts/randomjoker.png',
    px = '71',
    py = '95',
})
function aij_outline_image(imagedata, outline_color)
    local scale = G.SETTINGS.GRAPHICS.texture_scaling or 1
    local w, h = imagedata:getWidth(), imagedata:getHeight()

    local src = imagedata:clone()
    local out = imagedata:clone()

    local r,g,b,a =
        outline_color[1],
        outline_color[2],
        outline_color[3],
        outline_color[4] or 1

    for y = 0, h-1 do
        for x = 0, w-1 do
            local _,_,_,alpha = src:getPixel(x,y)
            alpha = alpha > 0.5 and 1 or 0

            if alpha == 0 then
                local hit = false

                -- search radius = scale
                for dy = -scale, scale do
                    for dx = -scale, scale do
                        -- optional: Manhattan distance for sharper corners
                        if math.abs(dx) + math.abs(dy) <= scale then
                            local nx, ny = x + dx, y + dy
                            if nx >= 0 and nx < w and ny >= 0 and ny < h then
                                local _,_,_,na = src:getPixel(nx, ny)
                                if na >= 0.99 then
                                    hit = true
                                    break
                                end
                            end
                        end
                    end
                    if hit then break end
                end

                if hit then
                    out:setPixel(x,y,r,g,b,a)
                end
            end
        end
    end

    return out
end


function aij_recolour_atlas(card, old_colour, new_colour, atlas)
    local image_data = atlas.image_data:clone()

    image_data:mapPixel(function(x, y, r, g, b, a)
        return aij_recolour_pixel(x, y, r, g, b, a, old_colour, new_colour)
    end)

    card.children.center.atlas = {
        px = atlas.px,
        py = atlas.py,
        name = atlas.name,
        image_data = image_data,
        image = love.graphics.newImage(image_data, {
            mipmaps = true,
            dpiscale = G.SETTINGS.GRAPHICS.texture_scaling
        })
    }
end

function aij_recolour_pixel(x, y, r, g, b, a, old_colour, new_colour, tolerance)
    tolerance = tolerance or 0.01

    if math.abs(r - old_colour[1]) <= tolerance
    and math.abs(g - old_colour[2]) <= tolerance
    and math.abs(b - old_colour[3]) <= tolerance then
        return new_colour[1], new_colour[2], new_colour[3], a
    end

    return r, g, b, a
end

local function pasteAlpha(base, layer, x, y)
    local w, h = layer:getWidth(), layer:getHeight()
    for i = 0, w-1 do
        for j = 0, h-1 do
            local r, g, b, a = layer:getPixel(i, j)
            if a > 0 then
                base:setPixel(x + i, y + j, r, g, b, a)
            end
        end
    end
end

local random_joker = {
    object_type = "Joker",
    order = 762,

    key = "random_joker",
    config = {
        extra = {
            
        }
    },
    rarity = 1,
    pos = { x = 0, y = 0 },
    atlas = 'aij_random_joker',
    cost = 4,
    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                
            }
        }
    end,

    set_sprites = function(self, card, front)
        if not card.config.center.discovered then return end
        if card.ability and card.ability.random_atlas then
            card.children.center.atlas = card.ability.random_atlas
            return
        end
        local random_joker_files = {}
        for k, v in pairs(G.ASSET_ATLAS) do
            local prefix = 'aij_randomjoker_'
            if string.find(k, prefix..'eyes') then
                random_joker_files['Eyes'] = random_joker_files['Eyes'] or {}
                random_joker_files['Eyes'][#random_joker_files['Eyes']+1] = v
            elseif string.find(k, prefix..'facemisc') then
                random_joker_files['Facemiscs'] = random_joker_files['Facemiscs'] or {}
                random_joker_files['Facemiscs'][#random_joker_files['Facemiscs']+1] = v
            elseif string.find(k, prefix..'hat') then
                random_joker_files['Hats'] = random_joker_files['Hats'] or {}
                random_joker_files['Hats'][#random_joker_files['Hats']+1] = v
            elseif string.find(k, prefix..'mouth') then
                random_joker_files['Mouths'] = random_joker_files['Mouths'] or {}
                random_joker_files['Mouths'][#random_joker_files['Mouths']+1] = v
            elseif string.find(k, prefix..'nose') then
                random_joker_files['Noses'] = random_joker_files['Noses'] or {}
                random_joker_files['Noses'][#random_joker_files['Noses']+1] = v
            elseif string.find(k, prefix..'ruff') then
                random_joker_files['Ruffs'] = random_joker_files['Ruffs'] or {}
                random_joker_files['Ruffs'][#random_joker_files['Ruffs']+1] = v
            elseif string.find(k, prefix..'head') then
                random_joker_files['Heads'] = random_joker_files['Heads'] or {}
                random_joker_files['Heads'][#random_joker_files['Heads']+1] = v
            elseif string.find(k, prefix..'bodydecal') then
                random_joker_files['Bodydecals'] = random_joker_files['Bodydecals'] or {}
                random_joker_files['Bodydecals'][#random_joker_files['Bodydecals']+1] = v
            --One for othermisc
            end
        end
        local base = G.ASSET_ATLAS['aij_random_joker'].image_data:clone()
        
        local head = pseudorandom_element(random_joker_files['Heads'], pseudoseed('randomjoker')).image_data:clone()
        local ruff = pseudorandom_element(random_joker_files['Ruffs'], pseudoseed('randomjoker')).image_data:clone()
        local bodydecal = pseudorandom_element(random_joker_files['Bodydecals'], pseudoseed('randomjoker')).image_data:clone()
        local mouth = pseudorandom_element(random_joker_files['Mouths'], pseudoseed('randomjoker')).image_data:clone()
        local eyes = pseudorandom_element(random_joker_files['Eyes'], pseudoseed('randomjoker')).image_data:clone()
        local nose = pseudorandom_element(random_joker_files['Noses'], pseudoseed('randomjoker')).image_data:clone()
        local facemisc = pseudorandom_element(random_joker_files['Facemiscs'], pseudoseed('randomjoker')).image_data:clone()
        local hat = pseudorandom_element(random_joker_files['Hats'], pseudoseed('randomjoker')).image_data:clone()

        --First to Last {Head, Other Misc, Ruff, Body Decal, Mouth, Eyes, Nose, Face Misc, Hat}
        local has_facedecal = pseudoseed('randomjoker_facedecal')
        local has_bodydecal = pseudoseed('randomjoker_bodydecal')
        
        pasteAlpha(head, ruff, 0, 0)
        if has_bodydecal <= 0.5 then
            pasteAlpha(head, bodydecal, 0, 0)
        end
        pasteAlpha(head, mouth, 0, 0)
        pasteAlpha(head, eyes, 0, 0)
        pasteAlpha(head, nose, 0, 0)
        if has_facedecal <= 0.5 then
            pasteAlpha(head, facemisc, 0, 0)
        end
        pasteAlpha(head, hat, 0, 0)

        head = aij_outline_image(head, HEX('4f6367'))
        pasteAlpha(base, head, 0, 0)
        


        card.children.center.atlas = {
            px = 71, py = 95, name = 'aij_random_joker',
            image_data = base,
            image = love.graphics.newImage(base, {mipmaps = true, dpiscale = G.SETTINGS.GRAPHICS.texture_scaling})
        }
        local replace_colours = {HEX('ff0000'), HEX('00fff8'), HEX('00ff05')}
        local new_colours = All_in_Jest.get_random_joker_colours('skintone')
        for k, v in pairs(replace_colours) do
            aij_recolour_atlas(card, v, new_colours[k], card.children.center.atlas)
        end

        local replace_colours1 = {HEX('a2ff00'), HEX('8600ff'), HEX('ff5300'), HEX('0082ff'), HEX('ff006f')}
        local replace_colours2 = {HEX('eeff00'), HEX('ff00e5'), HEX('0a00ff')}
        local new_clothes_colours, new_makeup_colours = All_in_Jest.get_random_joker_colours('clothes_and_makeup')
        for k, v in pairs(replace_colours1) do
            aij_recolour_atlas(card, v, new_clothes_colours[k], card.children.center.atlas)
        end
        for k, v in pairs(replace_colours2) do
            aij_recolour_atlas(card, v, new_makeup_colours[k], card.children.center.atlas)
        end

        local dark_replace_colours1 = {HEX('528100'), HEX('330061'), HEX('5c1e00'), HEX('00386d'), HEX('790035')}
        local dark_replace_colours2 = {HEX('ff9900'), HEX('8c007e'), HEX('05007e')}
        local dark_new_clothes_colours, dark_new_makeup_colours = {}, {}
        for k, v in pairs(new_clothes_colours) do
            dark_new_clothes_colours[#dark_new_clothes_colours+1] = darken(v,0.31)
        end
        for k, v in pairs(new_makeup_colours) do
            dark_new_makeup_colours[#dark_new_makeup_colours+1] = darken(v,0.31)
        end
        for k, v in pairs(dark_replace_colours1) do
            aij_recolour_atlas(card, v, dark_new_clothes_colours[k], card.children.center.atlas)
        end
        for k, v in pairs(dark_replace_colours2) do
            aij_recolour_atlas(card, v, dark_new_makeup_colours[k], card.children.center.atlas)
        end

        local light_replace_colours1 = {HEX('d2ff84'), HEX('c17dff'), HEX('ff9e6f'), HEX('82c2ff'), HEX('ff6fae')}
        local light_new_clothes_colours = {}
        for k, v in pairs(new_clothes_colours) do
            light_new_clothes_colours[#light_new_clothes_colours+1] = lighten(v,0.26)
        end
        for k, v in pairs(light_replace_colours1) do
            aij_recolour_atlas(card, v, light_new_clothes_colours[k], card.children.center.atlas)
        end

    end,

    calculate = function(self, card, context)
        
    end

}
return { name = { "Jokers" }, items = { random_joker } }