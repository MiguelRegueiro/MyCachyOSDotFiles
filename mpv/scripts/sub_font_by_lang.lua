-- Set subtitle font by active subtitle language.
-- Keeps a safe default font for unknown/missing language tags.

local DEFAULT_FONT = "Noto Sans"

local FONT_BY_LANG = {
    -- Japanese
    ja = "Noto Sans CJK JP",
    jpn = "Noto Sans CJK JP",

    -- Chinese
    zh = "Noto Sans CJK SC",
    zho = "Noto Sans CJK SC",
    chi = "Noto Sans CJK SC",
    cmn = "Noto Sans CJK SC",
    chs = "Noto Sans CJK SC",
    cht = "Noto Sans CJK SC",

    -- Russian
    ru = "Noto Sans",
    rus = "Noto Sans",

    -- Portuguese
    pt = "Noto Sans",
    por = "Noto Sans",
    ["pt-br"] = "Noto Sans",
    ["pt-pt"] = "Noto Sans",

    -- English
    en = "Noto Sans",
    eng = "Noto Sans",

    -- Spanish
    es = "Noto Sans",
    spa = "Noto Sans",
    ["es-419"] = "Noto Sans",
    ["es-es"] = "Noto Sans",
}

local function normalize_lang(lang)
    if not lang then
        return nil
    end
    local code = string.lower(lang)
    code = code:gsub("_", "-")
    return code
end

local function find_active_sub_track()
    local sid = mp.get_property_number("sid", 0)
    if not sid or sid <= 0 then
        return nil
    end

    local tracks = mp.get_property_native("track-list")
    if type(tracks) ~= "table" then
        return nil
    end

    for _, tr in ipairs(tracks) do
        if tr.type == "sub" and tr.id == sid then
            return tr
        end
    end
    return nil
end

local function font_for_track(track)
    if not track then
        return DEFAULT_FONT
    end

    local lang = normalize_lang(track.lang)
    if lang and FONT_BY_LANG[lang] then
        return FONT_BY_LANG[lang]
    end

    -- Try base language for tags like en-US, pt-BR, etc.
    if lang then
        local base = lang:match("^([a-z]+)")
        if base and FONT_BY_LANG[base] then
            return FONT_BY_LANG[base]
        end
    end

    return DEFAULT_FONT
end

local function apply_sub_font()
    local track = find_active_sub_track()
    local target_font = font_for_track(track)

    if mp.get_property("sub-font") ~= target_font then
        mp.set_property("sub-font", target_font)
    end
end

mp.register_event("file-loaded", apply_sub_font)
mp.observe_property("sid", "number", apply_sub_font)
mp.observe_property("track-list", "native", apply_sub_font)
