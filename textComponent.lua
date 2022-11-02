--[[
    Script by Lexize#0765
    Was made for LCamera (github.com/lexize/LCamera)
]]
if (lutils == nil) then return nil end

local json = lutils.json;

local TextComponent = {};

---@enum ClickAction
TextComponent.ClickActions = {
    ["open_url"         ] = "open_url"         ,
    ["run_command"      ] = "run_command"      ,
    ["suggest_command"  ] = "suggest_command"  ,
    ["copy_to_clipboard"] = "copy_to_clipboard"
};

---@class BaseComponentBuilder
---@field color string Color name or hex color
---@field extra BaseComponentBuilder[] Children of this builder
---@field font string Font used by text
---@field bold boolean Is text Bold
---@field italic boolean Is text Italic
---@field underlined boolean Is text Underlined
---@field strikethrough boolean Is text Strikethrough
---@field obfuscated boolean Is text Obfuscated
local BaseComponentBuilder = {}

---@class TextComponentBuilder: BaseComponentBuilder
---@field text string Text of this TextComponent
local TextComponentBuilder = {}

---@return BaseComponentBuilder
local function constructBase()
    local self = {};
    for key, value in pairs(BaseComponentBuilder) do
        self[key] = value;
    end
    return self;
end

---Creates base text component
---@param text string
---@return TextComponentBuilder
function TextComponent:text(text)
    local self = constructBase();
    self.text = text;
    for key, value in pairs(TextComponentBuilder) do
        self[key] = value;
    end
    return self;
end

---Sets color of this component
---@generic T: BaseComponentBuilder
---@param color string
---@param self T
---@return T
function BaseComponentBuilder:Color(color)
    self.color = color;
    return self;
end

---Sets font of this component
---@generic T: BaseComponentBuilder
---@param font string
---@param self T
---@return T
function BaseComponentBuilder:Font(font)
    self.font = font;
    return font;
end

---Sets Bold state of this component
---@generic T: BaseComponentBuilder
---@param bold boolean
---@param self T
---@return T
function BaseComponentBuilder:Bold(bold)
    self.bold = bold;
    return self;
end

---Sets Italic state of this component
---@generic T: BaseComponentBuilder
---@param italic boolean
---@param self T
---@return T
function BaseComponentBuilder:Italic(italic)
    self.italic = italic;
    return self;
end

---Sets Underlined state of this component
---@generic T: BaseComponentBuilder
---@param underlined boolean
---@param self T
---@return T
function BaseComponentBuilder:Underlined(underlined)
    self.underlined = underlined;
    return self;
end

---Sets Strikethrough state of this component
---@generic T: BaseComponentBuilder
---@param strikethrough boolean
---@param self T
---@return T
function BaseComponentBuilder:Strikethrough(strikethrough)
    self.strikethrough = strikethrough;
    return self;
end

---Sets Obfuscated state of this component
---@generic T: BaseComponentBuilder
---@param obfuscated boolean
---@param self T
---@return T
function BaseComponentBuilder:Obfuscated(obfuscated)
    self.obfuscated = obfuscated;
    return self;
end

---Sets click event of this component
---@generic T: BaseComponentBuilder
---@param action ClickAction
---@param value string
---@param self T
---@return T
function BaseComponentBuilder:ClickEvent(action, value)
    local clickEvent = {action = action, value = value};
    self.clickEvent = clickEvent;
    return self;
end

---Removes click event from this component
---@generic T: BaseComponentBuilder
---@param self T
---@return T
function BaseComponentBuilder:RemoveClickEvent()
    self.clickEvent = nil;
    return self;
end

---Appends another builder to children of this builder
---@generic T: BaseComponentBuilder
---@param builder BaseComponentBuilder
---@param self T
---@return T
function BaseComponentBuilder:append(builder)
    if (self.extra == nil) then
        self.extra = {};
    end
    self.extra[#self.extra+1] = builder;
    return self;
end

---Builds json text from this builder
---@generic T: BaseComponentBuilder
---@param self T
---@return string
function BaseComponentBuilder:build()
    return json:toJson(self);
end

---Sets text of this component
---@param text string
---@return TextComponentBuilder
function TextComponentBuilder:Text(text)
    self.text = text;
    return self;
end

return TextComponent;