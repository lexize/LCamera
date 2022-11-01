if (lutils == nil) then return nil end

local TextComponent = {};

---@enum ClickAction
TextComponent.ClickActions = {
    ["open_url"         ] = "open_url"         ,
    ["run_command"      ] = "run_command"      ,
    ["suggest_command"  ] = "suggest_command"  ,
    ["copy_to_clipboard"] = "copy_to_clipboard"
};

---@class BaseTextBuilder
local BaseTextBuilder = {}

---@class TextBuilder: BaseTextBuilder
local TextBuilder = {}

---@return BaseTextBuilder
local function constructBase()
    local self = {};
    for key, value in pairs(BaseTextBuilder) do
        self[key] = value;
    end
    return self;
end

---@param text string
---@return TextBuilder
function TextComponent:text(text)
    local self = constructBase();
    self.text = text;
    for key, value in pairs(TextBuilder) do
        self[key] = value;
    end
    return self;
end

---@generic T: BaseTextBuilder
---@param color string
---@param self T
---@return T
function BaseTextBuilder:Color(color)
    self.color = color;
    return self;
end

---@generic T: BaseTextBuilder
---@param font string
---@param self T
---@return T
function BaseTextBuilder:Font(font)
    self.font = font;
    return font;
end

---@generic T: BaseTextBuilder
---@param bold boolean
---@param self T
---@return T
function BaseTextBuilder:Bold(bold)
    self.bold = bold;
    return self;
end

---@generic T: BaseTextBuilder
---@param italic boolean
---@param self T
---@return T
function BaseTextBuilder:Italic(italic)
    self.italic = italic;
    return self;
end

---@generic T: BaseTextBuilder
---@param underlined boolean
---@param self T
---@return T
function BaseTextBuilder:Underlined(underlined)
    self.underlined = underlined;
    return self;
end

---@generic T: BaseTextBuilder
---@param strikethrough boolean
---@param self T
---@return T
function BaseTextBuilder:Strikethrough(strikethrough)
    self.strikethrough = strikethrough;
    return self;
end

---@generic T: BaseTextBuilder
---@param obfuscated boolean
---@param self T
---@return T
function BaseTextBuilder:Obfuscated(obfuscated)
    self.obfuscated = obfuscated;
    return self;
end

---@generic T: BaseTextBuilder
---@param action ClickAction
---@param value string
---@param self T
---@return T
function BaseTextBuilder:ClickEvent(action, value)
    local clickEvent = {action = action, value = value};
    self.clickEvent = clickEvent;
    return self;
end

---@generic T: BaseTextBuilder
---@param self T
---@return T
function BaseTextBuilder:RemoveClickEvent()
    self.clickEvent = nil;
    return self;
end

---@generic T: BaseTextBuilder
---@param builder BaseTextBuilder
---@param self T
---@return T
function BaseTextBuilder:append(builder)
    if (self.extra == nil) then
        self.extra = {};
    end
    self.extra[#self.extra+1] = builder;
    return self;
end

---@param text string
---@return TextBuilder
function TextBuilder:Text(text)
    self.text = text;
    return self;
end

return TextComponent;