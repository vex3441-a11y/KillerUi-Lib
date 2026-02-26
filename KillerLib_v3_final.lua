--[[
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║    ██╗  ██╗██╗██╗     ██╗     ███████╗██████╗     ██╗     ██╗██████╗   ║
║    ██║ ██╔╝██║██║     ██║     ██╔════╝██╔══██╗    ██║     ██║██╔══██╗  ║
║    █████╔╝ ██║██║     ██║     █████╗  ██████╔╝    ██║     ██║██████╔╝  ║
║    ██╔═██╗ ██║██║     ██║     ██╔══╝  ██╔══██╗    ██║     ██║██╔══██╗  ║
║    ██║  ██╗██║███████╗███████╗███████╗██║  ██║    ███████╗██║██████╔╝  ║
║    ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝╚═════╝   ║
║                                                                          ║
║    v3.0.0  ·  Final Release  ·  Professional Roblox UI Framework        ║
║    ──────────────────────────────────────────────────────────────────   ║
║    Sistema de Temas Customizáveis:                                       ║
║      · 9 presets prontos: Dark, Crimson, Ocean, Neon, Synthwave,        ║
║        Rose, Mint, Sunset, Arctic                                        ║
║      · Win:RegisterTheme(nome, tabela) — salva tema próprio             ║
║      · Win:SetTheme("nome" ou tabela)  — aplica qualquer tema           ║
║      · Win:ExportTheme(nome)           — gera código copiável           ║
║      · Win:OnThemeChanged(fn)          — callback ao mudar tema         ║
║      · Win:AddThemeEditor()            — editor visual integrado        ║
║                                                                          ║
║    Componentes:                                                          ║
║      AddButton · AddToggle · AddSlider · AddDropdown · AddInput         ║
║      AddKeybind · AddColorPicker · AddLabel · AddSection · AddLinkCard  ║
║                                                                          ║
║    USO RÁPIDO:                                                           ║
║    ──────────────────────────────────────────────────────────────────   ║
║    local Lib = loadstring(game:HttpGet("URL"))()                         ║
║                                                                          ║
║    local Win = Lib.new({                                                 ║
║        Title    = "Meu Hub",                                             ║
║        SubTitle = "v1.0",                                                ║
║        Theme    = "Dark",   -- ou "Crimson", "Ocean", etc.              ║
║        -- Theme = { Accent = Color3.fromRGB(255,80,120), ... }          ║
║    })                                                                    ║
║                                                                          ║
║    -- Tema 100% customizado do zero:                                     ║
║    Win:RegisterTheme("MeuTema", {                                        ║
║        WindowBg = Color3.fromRGB(10,5,15),                              ║
║        Accent   = Color3.fromRGB(200,80,255),                           ║
║        -- os demais campos preenchidos automaticamente                   ║
║    })                                                                    ║
║    Win:SetTheme("MeuTema")                                               ║
║                                                                          ║
║    -- Editor visual de temas integrado na hub:                          ║
║    Win:AddThemeEditor()                                                  ║
╚══════════════════════════════════════════════════════════════════════════╝
--]]

-- ════════════════════════════════════════════════════════════════════════
--  MÓDULO
-- ════════════════════════════════════════════════════════════════════════
local KillerLib = {}
KillerLib.__index  = KillerLib
KillerLib._VERSION = "3.0.0"

-- ════════════════════════════════════════════════════════════════════════
--  SERVIÇOS
-- ════════════════════════════════════════════════════════════════════════
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local CoreGui      = game:GetService("CoreGui")
local LP           = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════
--  HELPERS INTERNOS
-- ════════════════════════════════════════════════════════════════════════
local function tween(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj, TweenInfo.new(
        t     or 0.22,
        style or Enum.EasingStyle.Quart,
        dir   or Enum.EasingDirection.Out
    ), props):Play()
end

local function make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do pcall(function() inst[k] = v end) end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(radius, parent)
    return make("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(color, thickness, transparency, parent)
    return make("UIStroke", {
        Color           = color,
        Thickness       = thickness    or 1,
        Transparency    = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function padding(t, b, l, r, parent)
    return make("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
    }, parent)
end

local function ripple(parent, color)
    if not parent or not parent.Parent then return end
    local sz = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    local rp = make("Frame", {
        Size                  = UDim2.new(0, 0, 0, 0),
        Position              = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint           = Vector2.new(0.5, 0.5),
        BackgroundColor3      = color or Color3.new(1, 1, 1),
        BackgroundTransparency = 0.74,
        BorderSizePixel       = 0,
        ZIndex                = parent.ZIndex + 10,
    }, parent)
    corner(999, rp)
    tween(rp, { Size = UDim2.new(0, sz, 0, sz), BackgroundTransparency = 1 }, 0.50, Enum.EasingStyle.Quad)
    task.delay(0.55, function() if rp then rp:Destroy() end end)
end

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local function deepCopy(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    return c
end

-- ════════════════════════════════════════════════════════════════════════
--  SISTEMA DE TEMAS
--  Cada campo é opcional — o sistema preenche o restante automaticamente
--  com base no Accent e no WindowBg informados.
-- ════════════════════════════════════════════════════════════════════════
KillerLib.Themes = {}

--[[
  Campos disponíveis no tema (todos são Color3 exceto os *Trans que são 0..1):

  FUNDO ─────────────────────────────────────────────────────────────────
  WindowBg, WindowBgTrans
  TopbarBg, TopbarBgTrans
  SidebarBg, SidebarBgTrans
  CardBg, CardBgTrans

  SUPERFÍCIES ───────────────────────────────────────────────────────────
  Surface, SurfaceTrans
  SurfaceAlt
  SurfaceHover, SurfaceHoverTrans

  BORDAS ────────────────────────────────────────────────────────────────
  Border, BorderTrans

  ACCENT ────────────────────────────────────────────────────────────────
  Accent          ← cor principal de destaque
  AccentDim       ← versão mais escura/apagada do accent

  TEXTO ─────────────────────────────────────────────────────────────────
  Text            ← texto principal
  TextSub         ← texto secundário
  TextMuted       ← texto desabilitado / placeholder
  TextAccent      ← texto na cor do accent

  ESTADOS ───────────────────────────────────────────────────────────────
  Success, Warning, Danger

  COMPONENTES ───────────────────────────────────────────────────────────
  ToggleOn, ToggleOff, ToggleKnob
  SliderTrack, SliderFill, SliderThumb
  NotifyBg, NotifyBgTrans
  ModalBg, ModalBgTrans, ModalBorder, ModalBorderTrans
  ShortcutBg, ShortcutBgTrans
  ShortcutBorder, ShortcutBorderTrans
  ShortcutText
--]]

local THEME_DEFAULTS = {
    WindowBgTrans       = 0.04,
    TopbarBgTrans       = 0.02,
    SidebarBgTrans      = 0.03,
    CardBgTrans         = 0.02,
    SurfaceTrans        = 0.00,
    SurfaceHoverTrans   = 0.00,
    BorderTrans         = 0.45,
    NotifyBgTrans       = 0.00,
    ModalBgTrans        = 0.00,
    ModalBorderTrans    = 0.38,
    ShortcutBgTrans     = 0.18,
    ShortcutBorderTrans = 0.32,
    ToggleKnob          = rgb(255, 255, 255),
    SliderThumb         = rgb(255, 255, 255),
    Success             = rgb(72,  200, 122),
    Warning             = rgb(242, 172,  52),
    Danger              = rgb(250,  70,  88),
}

-- Constrói um tema completo aplicando os campos sobre os defaults
local function buildTheme(fields)
    local t = deepCopy(THEME_DEFAULTS)

    -- aplica campos passados
    for k, v in pairs(fields) do t[k] = v end

    -- inferências: campos não informados derivados dos principais
    t.TopbarBg          = t.TopbarBg      or t.WindowBg
    t.SidebarBg         = t.SidebarBg     or t.WindowBg
    t.CardBg            = t.CardBg        or t.WindowBg
    t.ModalBg           = t.ModalBg       or t.WindowBg
    t.ShortcutBg        = t.ShortcutBg    or t.WindowBg
    t.SurfaceHover      = t.SurfaceHover  or t.SurfaceAlt
    t.AccentDim         = t.AccentDim     or t.Accent
    t.TextAccent        = t.TextAccent    or t.Accent
    t.ToggleOn          = t.ToggleOn      or t.Accent
    t.ToggleOff         = t.ToggleOff     or t.Surface
    t.SliderFill        = t.SliderFill    or t.Accent
    t.SliderTrack       = t.SliderTrack   or t.Surface
    t.ShortcutBorder    = t.ShortcutBorder or t.Accent
    t.ShortcutText      = t.ShortcutText  or t.Text
    t.NotifyBg          = t.NotifyBg      or t.Surface
    t.ModalBorder       = t.ModalBorder   or t.Border

    return t
end

-- ── 9 presets embutidos ─────────────────────────────────────────────────
KillerLib.Themes["Dark"] = buildTheme({
    WindowBg = rgb(10,10,16),   Surface    = rgb(18,18,28),  SurfaceAlt = rgb(22,22,34),
    Border   = rgb(38,38,62),   Accent     = rgb(100,130,255), AccentDim= rgb(60,80,185),
    Text     = rgb(230,230,245),TextSub    = rgb(148,148,178),TextMuted = rgb(85,85,115),
    TextAccent=rgb(120,148,255),ToggleOff  = rgb(28,28,44),  SliderTrack=rgb(24,24,38),
})
KillerLib.Themes["Crimson"] = buildTheme({
    WindowBg = rgb(14,5,5),     Surface    = rgb(22,8,10),   SurfaceAlt = rgb(28,10,12),
    Border   = rgb(80,22,28),   Accent     = rgb(255,55,75), AccentDim  = rgb(180,30,50),
    Text     = rgb(255,220,220),TextSub    = rgb(200,150,155),TextMuted = rgb(130,80,85),
    TextAccent=rgb(255,110,125),ToggleOff  = rgb(35,10,12),  SliderTrack=rgb(22,8,10),
})
KillerLib.Themes["Ocean"] = buildTheme({
    WindowBg = rgb(5,14,26),    Surface    = rgb(8,22,40),   SurfaceAlt = rgb(10,28,50),
    Border   = rgb(20,65,105),  Accent     = rgb(0,195,255), AccentDim  = rgb(0,125,205),
    Text     = rgb(210,240,255),TextSub    = rgb(140,190,220),TextMuted = rgb(80,120,160),
    TextAccent=rgb(80,215,255), ToggleOff  = rgb(10,30,55),  SliderTrack=rgb(8,22,40),
})
KillerLib.Themes["Neon"] = buildTheme({
    WindowBg = rgb(4,4,4),      Surface    = rgb(10,10,10),  SurfaceAlt = rgb(14,14,14),
    Border   = rgb(0,80,42),    Accent     = rgb(0,255,120), AccentDim  = rgb(0,185,80),
    Text     = rgb(200,255,220),TextSub    = rgb(120,200,155),TextMuted = rgb(60,130,90),
    TextAccent=rgb(80,255,165), ToggleOff  = rgb(10,16,12),  SliderTrack=rgb(10,10,10),
    WindowBgTrans=0.02,         ShortcutBgTrans=0.10,
})
KillerLib.Themes["Synthwave"] = buildTheme({
    WindowBg = rgb(12,6,22),    Surface    = rgb(20,10,36),  SurfaceAlt = rgb(26,14,44),
    Border   = rgb(80,30,100),  Accent     = rgb(220,80,255),AccentDim  = rgb(160,50,200),
    Text     = rgb(240,210,255),TextSub    = rgb(180,140,210),TextMuted = rgb(110,70,140),
    TextAccent=rgb(235,130,255),ToggleOff  = rgb(25,12,42),  SliderTrack=rgb(20,10,36),
})
KillerLib.Themes["Rose"] = buildTheme({
    WindowBg = rgb(18,8,12),    Surface    = rgb(26,10,18),  SurfaceAlt = rgb(32,12,22),
    Border   = rgb(90,30,55),   Accent     = rgb(255,100,160),AccentDim = rgb(200,55,115),
    Text     = rgb(255,220,235),TextSub    = rgb(200,150,175),TextMuted = rgb(130,80,105),
    TextAccent=rgb(255,140,190),ToggleOff  = rgb(34,12,22),
})
KillerLib.Themes["Mint"] = buildTheme({
    WindowBg = rgb(6,16,14),    Surface    = rgb(8,22,20),   SurfaceAlt = rgb(10,28,25),
    Border   = rgb(15,65,55),   Accent     = rgb(0,220,180), AccentDim  = rgb(0,160,130),
    Text     = rgb(210,255,248),TextSub    = rgb(130,210,195),TextMuted = rgb(70,140,125),
    TextAccent=rgb(80,235,200), ToggleOff  = rgb(10,26,22),
})
KillerLib.Themes["Sunset"] = buildTheme({
    WindowBg = rgb(16,8,5),     Surface    = rgb(24,11,7),   SurfaceAlt = rgb(30,14,9),
    Border   = rgb(90,38,15),   Accent     = rgb(255,120,50),AccentDim  = rgb(200,75,20),
    Text     = rgb(255,230,215),TextSub    = rgb(210,165,140),TextMuted = rgb(140,95,70),
    TextAccent=rgb(255,160,90), ToggleOff  = rgb(32,14,8),   SliderTrack=rgb(22,10,6),
})
KillerLib.Themes["Arctic"] = buildTheme({
    WindowBg = rgb(12,18,28),   Surface    = rgb(16,25,40),  SurfaceAlt = rgb(20,32,52),
    Border   = rgb(40,70,110),  Accent     = rgb(140,200,255),AccentDim = rgb(80,155,230),
    Text     = rgb(220,235,255),TextSub    = rgb(155,180,220),TextMuted = rgb(90,120,165),
    TextAccent=rgb(170,215,255),ToggleOff  = rgb(20,30,50),
})

-- Resolver tema: aceita string (nome) ou tabela (overrides ou preset + overrides)
local function resolveTheme(input)
    -- começa do Dark como base universal
    local base = deepCopy(KillerLib.Themes["Dark"])

    if type(input) == "string" then
        local preset = KillerLib.Themes[input]
        if preset then for k, v in pairs(preset) do base[k] = v end end

    elseif type(input) == "table" then
        -- suporte a { Preset="Nome", Accent=Color3... }
        if input.Preset and KillerLib.Themes[input.Preset] then
            for k, v in pairs(KillerLib.Themes[input.Preset]) do base[k] = v end
        end
        -- overrides diretos (buildTheme faz as inferências)
        local merged = buildTheme(input)
        for k, v in pairs(merged) do base[k] = v end
    end

    return base
end

-- ════════════════════════════════════════════════════════════════════════
--  CONSTRUCTOR
-- ════════════════════════════════════════════════════════════════════════
function KillerLib.new(cfg)
    cfg = cfg or {}
    local self            = setmetatable({}, KillerLib)
    self.Title            = cfg.Title    or "KillerLib"
    self.SubTitle         = cfg.SubTitle or "v3.0"
    self.Theme            = resolveTheme(cfg.Theme or "Dark")
    self._tabs            = {}
    self._active          = nil
    self._open            = true
    self._minimized       = false
    self._notifyQ         = {}
    self._themeCallbacks  = {}

    self:_buildRoot()
    self:_buildShortcut()
    self:_buildWindow()
    self:_buildCloseModal()

    task.delay(0.9, function()
        self:Notify({ Title=self.Title.." Carregado",
            Message="KillerLib "..KillerLib._VERSION.." pronto!",
            Type="Success", Duration=3 })
    end)
    return self
end

-- ════════════════════════════════════════════════════════════════════════
--  ROOT SCREENGUI
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_buildRoot()
    local ok, g = pcall(function()
        return make("ScreenGui", {
            Name           = "KillerLib_"..math.random(1e5, 9e5),
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
            DisplayOrder   = 999,
        }, CoreGui)
    end)
    if not ok then
        g = make("ScreenGui", {
            Name           = "KillerLib",
            ResetOnSpawn   = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            IgnoreGuiInset = true,
        }, LP:WaitForChild("PlayerGui"))
    end
    self._root = g
end

-- ════════════════════════════════════════════════════════════════════════
--  BARRA DE ATALHO (topo-centro)
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_buildShortcut()
    local T = self.Theme

    local bar = make("Frame", {
        Name                  = "KillerBar",
        Size                  = UDim2.new(0, 164, 0, 32),
        Position              = UDim2.new(0.5, -82, 0, 10),
        BackgroundColor3      = T.ShortcutBg,
        BackgroundTransparency = T.ShortcutBgTrans,
        BorderSizePixel       = 0,
        ZIndex                = 100,
        ClipsDescendants      = true,
    }, self._root)
    corner(20, bar)
    stroke(T.ShortcutBorder, 1.2, T.ShortcutBorderTrans, bar)

    -- brilho interno topo
    make("Frame", { Size=UDim2.new(1,0,0,1), BackgroundColor3=Color3.new(1,1,1),
        BackgroundTransparency=0.84, BorderSizePixel=0, ZIndex=102 }, bar)

    -- dot de status pulsante
    local dot = make("Frame", {
        Size=UDim2.new(0,7,0,7), Position=UDim2.new(0,12,0.5,-3.5),
        BackgroundColor3=T.Success, BorderSizePixel=0, ZIndex=103,
    }, bar)
    corner(99, dot)
    task.spawn(function()
        while bar and bar.Parent do
            tween(dot, {BackgroundTransparency=0.65}, 0.75, Enum.EasingStyle.Sine)
            task.wait(0.75)
            tween(dot, {BackgroundTransparency=0.0},  0.75, Enum.EasingStyle.Sine)
            task.wait(0.75)
        end
    end)

    -- ícone ◈
    make("TextLabel", {
        Size=UDim2.new(0,18,1,0), Position=UDim2.new(0,22,0,0),
        BackgroundTransparency=1, Text="◈", TextColor3=T.Accent,
        TextSize=11, Font=Enum.Font.GothamBold, ZIndex=103,
    }, bar)

    -- label Open/Close
    local lbl = make("TextLabel", {
        Size=UDim2.new(1,-76,1,0), Position=UDim2.new(0,42,0,0),
        BackgroundTransparency=1, Text="Close Hub",
        TextColor3=T.ShortcutText, TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=103,
    }, bar)

    -- separador vertical
    make("Frame", {
        Size=UDim2.new(0,1,0,16), Position=UDim2.new(1,-36,0.5,-8),
        BackgroundColor3=T.Border, BackgroundTransparency=T.BorderTrans,
        BorderSizePixel=0, ZIndex=103,
    }, bar)

    -- botão ✕ → modal
    local xBtn = make("TextButton", {
        Size=UDim2.new(0,32,1,0), Position=UDim2.new(1,-32,0,0),
        BackgroundTransparency=1, Text="✕", TextColor3=T.TextMuted,
        TextSize=11, Font=Enum.Font.GothamBold, ZIndex=104, AutoButtonColor=false,
    }, bar)
    xBtn.MouseEnter:Connect(function()  tween(xBtn, {TextColor3=T.Danger},   0.12) end)
    xBtn.MouseLeave:Connect(function()  tween(xBtn, {TextColor3=T.TextMuted}, 0.12) end)
    xBtn.MouseButton1Click:Connect(function() self:_showCloseModal() end)

    -- área clicável → toggle janela
    local clickArea = make("TextButton", {
        Size=UDim2.new(1,-32,1,0), BackgroundTransparency=1,
        Text="", ZIndex=105, AutoButtonColor=false,
    }, bar)
    clickArea.MouseButton1Click:Connect(function()
        ripple(bar, T.Accent); self:_toggleWindow()
    end)
    clickArea.MouseEnter:Connect(function()
        tween(bar, {BackgroundTransparency=math.max(0, T.ShortcutBgTrans-0.10)}, 0.14)
    end)
    clickArea.MouseLeave:Connect(function()
        tween(bar, {BackgroundTransparency=T.ShortcutBgTrans}, 0.14)
    end)

    self._shortcutBar = bar
    self._shortcutLbl = lbl
    self._shortcutDot = dot
end

-- ════════════════════════════════════════════════════════════════════════
--  TOGGLE JANELA
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_toggleWindow()
    local T   = self.Theme
    local win = self._windowHolder
    self._open = not self._open

    if self._open then
        self._shortcutLbl.Text = "Close Hub"
        tween(self._shortcutDot, {BackgroundColor3=T.Success}, 0.20)
        local p = win.Position
        win.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset-14)
        win.Visible  = true
        tween(win, {Position=p}, 0.30, Enum.EasingStyle.Back)
    else
        self._shortcutLbl.Text = "Open Hub"
        tween(self._shortcutDot, {BackgroundColor3=T.Warning}, 0.20)
        local p = win.Position
        tween(win, {Position=UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset-12)}, 0.22)
        task.delay(0.24, function() win.Visible=false; win.Position=p end)
    end
end

-- ════════════════════════════════════════════════════════════════════════
--  JANELA PRINCIPAL
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_buildWindow()
    local T = self.Theme

    local holder = make("Frame", {
        Name="KillerHolder", Size=UDim2.new(0,0,0,0),
        Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1, ZIndex=2,
    }, self._root)

    -- sombra
    make("ImageLabel", {
        Size=UDim2.new(1,90,1,90), Position=UDim2.new(0,-45,0,-45),
        BackgroundTransparency=1, Image="rbxassetid://6015897843",
        ImageColor3=Color3.new(0,0,0), ImageTransparency=0.44,
        ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(49,49,450,450), ZIndex=1,
    }, holder)

    local win = make("Frame", {
        Name="KillerWindow", Size=UDim2.new(1,0,1,0),
        BackgroundColor3=T.WindowBg, BackgroundTransparency=T.WindowBgTrans,
        BorderSizePixel=0, ZIndex=3,
    }, holder)
    corner(14, win)
    stroke(T.Border, 1, T.BorderTrans, win)

    self._windowHolder = holder
    self._winFrame     = win

    -- animação de entrada
    tween(holder, {
        Size     = UDim2.new(0,750,0,520),
        Position = UDim2.new(0.5,-375,0.5,-260),
        AnchorPoint = Vector2.new(0,0),
    }, 0.50, Enum.EasingStyle.Back)

    self:_buildTopbar(win)

    local body = make("Frame", {
        Size=UDim2.new(1,0,1,-46), Position=UDim2.new(0,0,0,46),
        BackgroundTransparency=1, ZIndex=3,
    }, win)

    self:_buildSidebar(body)
    self:_buildContent(body)
    self:_buildPlayerCard(win)
    self:_makeDraggable(self._topbar, holder)
end

-- ════════════════════════════════════════════════════════════════════════
--  TOPBAR
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_buildTopbar(parent)
    local T = self.Theme

    local tb = make("Frame", {
        Name="Topbar", Size=UDim2.new(1,0,0,46),
        BackgroundColor3=T.TopbarBg, BackgroundTransparency=T.TopbarBgTrans,
        BorderSizePixel=0, ZIndex=10,
    }, parent)
    corner(14, tb)
    -- cobre cantos redondos inferiores
    make("Frame", {
        Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14),
        BackgroundColor3=T.TopbarBg, BackgroundTransparency=T.TopbarBgTrans,
        BorderSizePixel=0, ZIndex=10,
    }, tb)
    -- divisor accent
    make("Frame", {
        Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,0),
        BackgroundColor3=T.Accent, BackgroundTransparency=0.60,
        BorderSizePixel=0, ZIndex=11,
    }, tb)

    -- título
    make("TextLabel", {
        Size=UDim2.new(0,280,1,0), Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1, Text="◈  "..self.Title,
        TextColor3=T.Text, TextSize=14, Font=Enum.Font.GothamBlack,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12,
    }, tb)

    -- badge versão
    local badge = make("Frame", {
        Size=UDim2.new(0,0,0,18), Position=UDim2.new(0,170,0.5,-9),
        AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=T.AccentDim, BackgroundTransparency=0.28,
        BorderSizePixel=0, ZIndex=12,
    }, tb)
    corner(6, badge)
    padding(0,0,6,6, badge)
    make("TextLabel", {
        Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1, Text="v"..KillerLib._VERSION,
        TextColor3=T.TextAccent, TextSize=9, Font=Enum.Font.GothamBold, ZIndex=13,
    }, badge)

    -- helper botão de controle
    local function ctrlBtn(xOff, bgColor, symbol, callback)
        local f = make("Frame", {
            Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,xOff,0.5,-13),
            BackgroundColor3=bgColor, BackgroundTransparency=0.24,
            BorderSizePixel=0, ZIndex=12,
        }, tb)
        corner(8, f)
        make("TextLabel", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text=symbol, TextColor3=Color3.new(1,1,1),
            TextSize=12, Font=Enum.Font.GothamBold, ZIndex=13,
        }, f)
        local btn = make("TextButton", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Text="", ZIndex=14, AutoButtonColor=false,
        }, f)
        btn.MouseButton1Click:Connect(function() ripple(f, Color3.new(1,1,1)); callback() end)
        btn.MouseEnter:Connect(function() tween(f, {BackgroundTransparency=0},    0.10) end)
        btn.MouseLeave:Connect(function() tween(f, {BackgroundTransparency=0.24}, 0.10) end)
        return f
    end

    ctrlBtn(-36,  rgb(242,58,72),  "✕", function() self:_showCloseModal() end)
    ctrlBtn(-68,  rgb(242,170,42), "−", function()
        self._minimized = not self._minimized
        local h = self._minimized and 46 or 520
        tween(self._winFrame,     {Size=UDim2.new(1,0,0,h)}, 0.30, Enum.EasingStyle.Quart)
        tween(self._windowHolder, {Size=UDim2.new(0,750,0,h)}, 0.30, Enum.EasingStyle.Quart)
    end)
    ctrlBtn(-100, rgb(48,172,96),  "◉", function() self:_toggleWindow() end)

    self._topbar = tb
end

-- ════════════════════════════════════════════════════════════════════════
--  SIDEBAR
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_buildSidebar(parent)
    local T = self.Theme

    local sb = make("Frame", {
        Name="Sidebar", Size=UDim2.new(0,152,1,-76),
        BackgroundColor3=T.SidebarBg, BackgroundTransparency=T.SidebarBgTrans,
        BorderSizePixel=0, ZIndex=4, ClipsDescendants=true,
    }, parent)
    corner(14, sb)
    -- tampões de canto
    make("Frame", {Size=UDim2.new(0,14,1,0), Position=UDim2.new(1,-14,0,0),
        BackgroundColor3=T.SidebarBg, BackgroundTransparency=T.SidebarBgTrans,
        BorderSizePixel=0, ZIndex=5}, sb)
    make("Frame", {Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14),
        BackgroundColor3=T.SidebarBg, BackgroundTransparency=T.SidebarBgTrans,
        BorderSizePixel=0, ZIndex=5}, sb)
    stroke(T.Border, 1, T.BorderTrans+0.08, sb)
    -- divisor direito
    make("Frame", {Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=T.Border, BackgroundTransparency=T.BorderTrans,
        BorderSizePixel=0, ZIndex=6}, sb)

    local scroll = make("ScrollingFrame", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=0, ZIndex=6,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    }, sb)
    padding(10,10,8,8, scroll)
    make("UIListLayout", {
        FillDirection=Enum.FillDirection.Vertical,
        Padding=UDim.new(0,3), SortOrder=Enum.SortOrder.LayoutOrder,
    }, scroll)

    self._sidebar   = sb
    self._tabScroll = scroll
end

-- ════════════════════════════════════════════════════════════════════════
--  CONTENT AREA
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_buildContent(parent)
    self._content = make("Frame", {
        Name="Content", Size=UDim2.new(1,-152,1,0), Position=UDim2.new(0,152,0,0),
        BackgroundTransparency=1, ZIndex=3, ClipsDescendants=true,
    }, parent)
end

-- ════════════════════════════════════════════════════════════════════════
--  PLAYER CARD
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_buildPlayerCard(parent)
    local T = self.Theme

    local card = make("Frame", {
        Name="PlayerCard", Size=UDim2.new(0,152,0,76), Position=UDim2.new(0,0,1,-76),
        BackgroundColor3=T.CardBg, BackgroundTransparency=T.CardBgTrans,
        BorderSizePixel=0, ZIndex=15, ClipsDescendants=true,
    }, parent)
    corner(14, card)
    make("Frame", {Size=UDim2.new(1,0,0,14), BackgroundColor3=T.CardBg,
        BackgroundTransparency=T.CardBgTrans, BorderSizePixel=0, ZIndex=15}, card)
    make("Frame", {Size=UDim2.new(0,14,1,0), Position=UDim2.new(1,-14,0,0),
        BackgroundColor3=T.CardBg, BackgroundTransparency=T.CardBgTrans,
        BorderSizePixel=0, ZIndex=15}, card)
    -- divisor accent
    make("Frame", {Size=UDim2.new(1,0,0,2), BackgroundColor3=T.Accent,
        BackgroundTransparency=0.44, BorderSizePixel=0, ZIndex=16}, card)

    -- avatar
    local av = make("ImageLabel", {
        Size=UDim2.new(0,38,0,38), Position=UDim2.new(0,8,0,20),
        BackgroundColor3=T.Surface,
        Image="https://www.roblox.com/headshot-thumbnail/image?userId="..LP.UserId.."&width=60&height=60&format=png",
        ZIndex=17,
    }, card)
    corner(9, av)
    stroke(T.Accent, 1.5, 0.40, av)

    -- dot online
    local onDot = make("Frame", {
        Size=UDim2.new(0,10,0,10), Position=UDim2.new(1,-10,1,-10),
        BackgroundColor3=T.Success, BorderSizePixel=0, ZIndex=18,
    }, av)
    corner(99, onDot)
    stroke(T.CardBg, 1.5, 0, onDot)

    make("TextLabel", {Size=UDim2.new(1,-54,0,15), Position=UDim2.new(0,52,0,19),
        BackgroundTransparency=1, Text=LP.DisplayName, TextColor3=T.Text, TextSize=11,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=17}, card)
    make("TextLabel", {Size=UDim2.new(1,-54,0,12), Position=UDim2.new(0,52,0,35),
        BackgroundTransparency=1, Text="@"..LP.Name, TextColor3=T.TextSub, TextSize=9,
        Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=17}, card)
    make("TextLabel", {Size=UDim2.new(1,-54,0,12), Position=UDim2.new(0,52,0,50),
        BackgroundTransparency=1, Text="ID: "..LP.UserId, TextColor3=T.TextAccent, TextSize=9,
        Font=Enum.Font.Code, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=17}, card)
end

-- ════════════════════════════════════════════════════════════════════════
--  MODAL FECHAR
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_buildCloseModal()
    local T = self.Theme

    local overlay = make("Frame", {
        Size=UDim2.new(1,0,1,0), BackgroundColor3=rgb(0,0,0),
        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=200, Visible=false,
    }, self._root)
    self._modalOverlay = overlay

    local modal = make("Frame", {
        Size=UDim2.new(0,380,0,0), Position=UDim2.new(0.5,-190,0.5,-110),
        BackgroundColor3=T.ModalBg, BackgroundTransparency=T.ModalBgTrans,
        BorderSizePixel=0, ZIndex=201,
    }, overlay)
    corner(18, modal)
    stroke(T.ModalBorder, 1, T.ModalBorderTrans, modal)
    self._modal = modal

    -- glow topo
    local gl = make("Frame", {
        Size=UDim2.new(0.5,0,0,2), Position=UDim2.new(0.25,0,0,0),
        BackgroundColor3=T.Danger, BackgroundTransparency=0.04,
        BorderSizePixel=0, ZIndex=202,
    }, modal)
    corner(99, gl)

    -- ícone flutuante
    local ic = make("Frame", {
        Size=UDim2.new(0,52,0,52), Position=UDim2.new(0.5,-26,0,-26),
        BackgroundColor3=T.ModalBg, BorderSizePixel=0, ZIndex=203,
    }, modal)
    corner(99, ic)
    stroke(T.Danger, 2, 0.14, ic)
    make("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="⚠", TextColor3=T.Danger, TextSize=22, Font=Enum.Font.GothamBold, ZIndex=204,
    }, ic)

    make("TextLabel", {
        Size=UDim2.new(1,-32,0,26), Position=UDim2.new(0,16,0,40),
        BackgroundTransparency=1, Text="Fechar "..self.Title.."?",
        TextColor3=T.Text, TextSize=15, Font=Enum.Font.GothamBlack,
        TextXAlignment=Enum.TextXAlignment.Center, ZIndex=202,
    }, modal)
    make("TextLabel", {
        Size=UDim2.new(1,-44,0,50), Position=UDim2.new(0,22,0,70),
        BackgroundTransparency=1,
        Text="Todos os scripts ativos serão\nencerrados ao fechar.",
        TextColor3=T.TextSub, TextSize=11, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Center, TextWrapped=true, LineHeight=1.5, ZIndex=202,
    }, modal)
    make("Frame", {
        Size=UDim2.new(1,-32,0,1), Position=UDim2.new(0,16,0,130),
        BackgroundColor3=T.Border, BackgroundTransparency=T.BorderTrans,
        BorderSizePixel=0, ZIndex=202,
    }, modal)

    -- botão cancelar
    local cxF = make("Frame", {
        Size=UDim2.new(0.46,0,0,38), Position=UDim2.new(0.03,0,0,144),
        BackgroundColor3=T.Surface, BackgroundTransparency=0.06,
        BorderSizePixel=0, ZIndex=202,
    }, modal)
    corner(10, cxF)
    stroke(T.Border, 1, T.BorderTrans, cxF)
    local cxB = make("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="Cancelar", TextColor3=T.TextSub, TextSize=12, Font=Enum.Font.GothamBold,
        ZIndex=203, AutoButtonColor=false,
    }, cxF)
    cxB.MouseEnter:Connect(function() tween(cxF, {BackgroundTransparency=0},    0.12) end)
    cxB.MouseLeave:Connect(function() tween(cxF, {BackgroundTransparency=0.06}, 0.12) end)
    cxB.MouseButton1Click:Connect(function() ripple(cxF, T.TextSub); self:_hideCloseModal() end)

    -- botão confirmar fechar
    local cfF = make("Frame", {
        Size=UDim2.new(0.46,0,0,38), Position=UDim2.new(0.51,0,0,144),
        BackgroundColor3=T.Danger, BackgroundTransparency=0.10,
        BorderSizePixel=0, ZIndex=202,
    }, modal)
    corner(10, cfF)
    stroke(T.Danger, 1, 0.40, cfF)
    local cfB = make("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="✕  Fechar Hub", TextColor3=Color3.new(1,1,1), TextSize=12, Font=Enum.Font.GothamBold,
        ZIndex=203, AutoButtonColor=false,
    }, cfF)
    cfB.MouseEnter:Connect(function() tween(cfF, {BackgroundTransparency=0},    0.12) end)
    cfB.MouseLeave:Connect(function() tween(cfF, {BackgroundTransparency=0.10}, 0.12) end)
    cfB.MouseButton1Click:Connect(function()
        ripple(cfF, T.Danger)
        task.wait(0.18)
        self:_destroyAll()
    end)
end

function KillerLib:_showCloseModal()
    local o, m = self._modalOverlay, self._modal
    o.Visible=true; o.BackgroundTransparency=1; m.Size=UDim2.new(0,380,0,0)
    tween(o, {BackgroundTransparency=0.44}, 0.22)
    tween(m, {Size=UDim2.new(0,380,0,220)}, 0.35, Enum.EasingStyle.Back)
end

function KillerLib:_hideCloseModal()
    local o, m = self._modalOverlay, self._modal
    tween(m, {Size=UDim2.new(0,380,0,0)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tween(o, {BackgroundTransparency=1}, 0.25)
    task.delay(0.30, function() o.Visible=false end)
end

function KillerLib:_destroyAll()
    local flash = make("Frame", {
        Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.new(1,1,1),
        BackgroundTransparency=0.70, BorderSizePixel=0, ZIndex=500,
    }, self._root)
    tween(flash, {BackgroundTransparency=1}, 0.40)
    tween(self._windowHolder, {
        Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.5,0,0.5,0),
    }, 0.30, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tween(self._shortcutBar, {BackgroundTransparency=1, Size=UDim2.new(0,0,0,32)}, 0.28)
    task.delay(0.38, function() self._root:Destroy() end)
end

-- ════════════════════════════════════════════════════════════════════════
--  DRAG
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:_makeDraggable(handle, target)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = target.Position
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════
--  ADD TAB
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddTab(cfg)
    cfg = cfg or {}
    local T  = self.Theme
    local td = { Name=cfg.Name or "Tab", Icon=cfg.Icon or "•", _elements={} }

    local btn = make("Frame", {
        Size=UDim2.new(1,0,0,36), BackgroundColor3=T.Surface,
        BackgroundTransparency=1, BorderSizePixel=0, ZIndex=7,
        LayoutOrder=#self._tabs+1, ClipsDescendants=true,
    }, self._tabScroll)
    corner(9, btn)

    local accentBar = make("Frame", {
        Size=UDim2.new(0,3,0.54,0), Position=UDim2.new(0,0,0.23,0),
        BackgroundColor3=T.Accent, BackgroundTransparency=1,
        BorderSizePixel=0, ZIndex=8,
    }, btn)
    corner(99, accentBar)

    local icLbl = make("TextLabel", {
        Size=UDim2.new(0,24,1,0), Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1, Text=td.Icon, TextColor3=T.TextMuted,
        TextSize=13, Font=Enum.Font.GothamBold, ZIndex=8,
    }, btn)

    local nmLbl = make("TextLabel", {
        Size=UDim2.new(1,-36,1,0), Position=UDim2.new(0,34,0,0),
        BackgroundTransparency=1, Text=td.Name, TextColor3=T.TextMuted,
        TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8,
    }, btn)

    local clickBtn = make("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="", ZIndex=9, AutoButtonColor=false,
    }, btn)

    local page = make("ScrollingFrame", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=2, ScrollBarImageColor3=T.Accent, ScrollBarImageTransparency=0.45,
        Visible=false, ZIndex=3,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    }, self._content)
    padding(10,14,12,12, page)
    make("UIListLayout", {
        FillDirection=Enum.FillDirection.Vertical,
        Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder,
    }, page)

    td._btn=btn; td._bar=accentBar; td._ic=icLbl; td._nm=nmLbl; td._page=page

    clickBtn.MouseButton1Click:Connect(function()
        ripple(btn, T.Accent); self:_selectTab(td)
    end)
    clickBtn.MouseEnter:Connect(function()
        if self._active~=td then
            tween(btn,   {BackgroundTransparency=0.50}, 0.12)
            tween(nmLbl, {TextColor3=T.TextSub},        0.12)
        end
    end)
    clickBtn.MouseLeave:Connect(function()
        if self._active~=td then
            tween(btn,   {BackgroundTransparency=1},        0.12)
            tween(nmLbl, {TextColor3=T.TextMuted},          0.12)
        end
    end)

    table.insert(self._tabs, td)
    if #self._tabs == 1 then self:_selectTab(td) end
    return td
end

function KillerLib:_selectTab(td)
    local T = self.Theme
    if self._active and self._active ~= td then
        local p = self._active
        tween(p._btn, {BackgroundTransparency=1},     0.18)
        tween(p._bar, {BackgroundTransparency=1},     0.18)
        tween(p._nm,  {TextColor3=T.TextMuted},       0.18)
        tween(p._ic,  {TextColor3=T.TextMuted},       0.18)
        p._page.Visible = false
    end
    self._active = td
    tween(td._btn, {BackgroundTransparency=0.42}, 0.18)
    tween(td._bar, {BackgroundTransparency=0},    0.18)
    tween(td._nm,  {TextColor3=T.Text},           0.18)
    tween(td._ic,  {TextColor3=T.Accent},         0.18)
    td._page.Visible = true
end

-- ════════════════════════════════════════════════════════════════════════
--  SECTION
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddSection(tab, cfg)
    cfg = cfg or {}
    local T = self.Theme

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,26), BackgroundTransparency=1,
        ZIndex=4, LayoutOrder=#tab._elements+1,
    }, tab._page)

    make("TextLabel", {
        Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,4,0,0),
        BackgroundTransparency=1, Text=(cfg.Name or "Section"):upper(),
        TextColor3=T.Accent, TextSize=9, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    }, f)

    make("Frame", {
        Size=UDim2.new(1,-4,0,1), Position=UDim2.new(0,4,1,-1),
        BackgroundColor3=T.Accent, BackgroundTransparency=0.68,
        BorderSizePixel=0, ZIndex=5,
    }, f)

    table.insert(tab._elements, f)
end

-- ════════════════════════════════════════════════════════════════════════
--  BUTTON
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddButton(tab, cfg)
    cfg = cfg or {}
    local T  = self.Theme
    local cb = cfg.Callback or function() end

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Surface,
        BackgroundTransparency=T.SurfaceTrans, BorderSizePixel=0,
        ZIndex=4, LayoutOrder=#tab._elements+1, ClipsDescendants=true,
    }, tab._page)
    corner(9, f)
    stroke(T.Border, 1, T.BorderTrans, f)

    local xOff = 10
    if cfg.Icon then
        make("TextLabel", {
            Size=UDim2.new(0,28,1,0), Position=UDim2.new(0,6,0,0),
            BackgroundTransparency=1, Text=cfg.Icon, TextColor3=T.Accent,
            TextSize=14, Font=Enum.Font.GothamBold, ZIndex=5,
        }, f)
        xOff = 36
    end

    make("TextLabel", {
        Size=UDim2.new(0.60,-xOff,1,0), Position=UDim2.new(0,xOff,0,0),
        BackgroundTransparency=1, Text=cfg.Name or "Button",
        TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    }, f)

    if cfg.Description then
        make("TextLabel", {
            Size=UDim2.new(0.36,0,1,0), Position=UDim2.new(0.64,0,0,0),
            BackgroundTransparency=1, Text=cfg.Description,
            TextColor3=T.TextMuted, TextSize=10, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Right, ZIndex=5,
        }, f)
    end

    make("TextLabel", {
        Size=UDim2.new(0,18,1,0), Position=UDim2.new(1,-20,0,0),
        BackgroundTransparency=1, Text="›", TextColor3=T.TextMuted,
        TextSize=16, Font=Enum.Font.GothamBold, ZIndex=5,
    }, f)

    local btn = make("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="", ZIndex=6, AutoButtonColor=false,
    }, f)
    btn.MouseButton1Click:Connect(function()
        ripple(f, T.Accent)
        tween(f, {BackgroundColor3=T.SurfaceHover, BackgroundTransparency=0}, 0.06)
        task.delay(0.15, function()
            tween(f, {BackgroundColor3=T.Surface, BackgroundTransparency=T.SurfaceTrans}, 0.22)
        end)
        task.spawn(cb)
    end)
    btn.MouseEnter:Connect(function()
        tween(f, {BackgroundColor3=T.SurfaceHover, BackgroundTransparency=T.SurfaceHoverTrans}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        tween(f, {BackgroundColor3=T.Surface, BackgroundTransparency=T.SurfaceTrans}, 0.12)
    end)

    table.insert(tab._elements, f)
    return f
end

-- ════════════════════════════════════════════════════════════════════════
--  TOGGLE
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddToggle(tab, cfg)
    cfg = cfg or {}
    local T   = self.Theme
    local val = cfg.Default == true
    local cb  = cfg.Callback or function() end

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Surface,
        BackgroundTransparency=T.SurfaceTrans, BorderSizePixel=0,
        ZIndex=4, LayoutOrder=#tab._elements+1,
    }, tab._page)
    corner(9, f)
    stroke(T.Border, 1, T.BorderTrans, f)

    make("TextLabel", {
        Size=UDim2.new(0.65,0,0,16), Position=UDim2.new(0,10,0,7),
        BackgroundTransparency=1, Text=cfg.Name or "Toggle",
        TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    }, f)

    if cfg.Description then
        make("TextLabel", {
            Size=UDim2.new(0.65,0,0,13), Position=UDim2.new(0,10,0,22),
            BackgroundTransparency=1, Text=cfg.Description,
            TextColor3=T.TextMuted, TextSize=9, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
        }, f)
    end

    local pill = make("Frame", {
        Size=UDim2.new(0,44,0,22), Position=UDim2.new(1,-54,0.5,-11),
        BackgroundColor3=val and T.ToggleOn or T.ToggleOff,
        BackgroundTransparency=0.05, BorderSizePixel=0, ZIndex=5,
    }, f)
    corner(99, pill)
    local pillStroke = stroke(
        val and T.Accent or T.Border, 1,
        val and 0.32 or T.BorderTrans, pill
    )

    local knob = make("Frame", {
        Size=UDim2.new(0,16,0,16),
        Position=val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
        BackgroundColor3=T.ToggleKnob, BorderSizePixel=0, ZIndex=6,
    }, pill)
    corner(99, knob)

    local stateLbl = make("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=val and "ON" or "OFF",
        TextColor3=val and T.ToggleOn or T.TextMuted,
        TextSize=7, Font=Enum.Font.GothamBold, ZIndex=4,
    }, pill)

    local btn = make("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="", ZIndex=7, AutoButtonColor=false,
    }, f)

    local function setValue(v)
        val = v
        tween(pill,       {BackgroundColor3=v and T.ToggleOn or T.ToggleOff}, 0.20)
        tween(knob,       {Position=v and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)},
              0.20, Enum.EasingStyle.Back)
        tween(pillStroke, {Color=v and T.Accent or T.Border,
              Transparency=v and 0.32 or T.BorderTrans}, 0.20)
        stateLbl.Text      = v and "ON" or "OFF"
        stateLbl.TextColor3 = v and T.ToggleOn or T.TextMuted
        task.spawn(cb, v)
    end

    btn.MouseButton1Click:Connect(function() ripple(f, T.Accent); setValue(not val) end)
    btn.MouseEnter:Connect(function()
        tween(f, {BackgroundColor3=T.SurfaceHover, BackgroundTransparency=T.SurfaceHoverTrans}, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        tween(f, {BackgroundColor3=T.Surface, BackgroundTransparency=T.SurfaceTrans}, 0.12)
    end)

    table.insert(tab._elements, f)
    return {
        Set   = setValue,
        Get   = function() return val end,
        _frame = f,
    }
end

-- ════════════════════════════════════════════════════════════════════════
--  SLIDER
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddSlider(tab, cfg)
    cfg = cfg or {}
    local T      = self.Theme
    local minV   = cfg.Min     or 0
    local maxV   = cfg.Max     or 100
    local suffix = cfg.Suffix  or ""
    local cb     = cfg.Callback or function() end
    local val    = math.clamp(cfg.Default or minV, minV, maxV)

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,52), BackgroundColor3=T.Surface,
        BackgroundTransparency=T.SurfaceTrans, BorderSizePixel=0,
        ZIndex=4, LayoutOrder=#tab._elements+1,
    }, tab._page)
    corner(9, f)
    stroke(T.Border, 1, T.BorderTrans, f)

    make("TextLabel", {
        Size=UDim2.new(0.58,0,0,20), Position=UDim2.new(0,10,0,5),
        BackgroundTransparency=1, Text=cfg.Name or "Slider",
        TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    }, f)

    local valLbl = make("TextLabel", {
        Size=UDim2.new(0.38,0,0,20), Position=UDim2.new(0.62,0,0,5),
        BackgroundTransparency=1, Text=tostring(val)..suffix,
        TextColor3=T.TextAccent, TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=5,
    }, f)

    local track = make("Frame", {
        Size=UDim2.new(1,-20,0,4), Position=UDim2.new(0,10,0,36),
        BackgroundColor3=T.SliderTrack, BackgroundTransparency=0.06,
        BorderSizePixel=0, ZIndex=5,
    }, f)
    corner(99, track)

    local pct  = (val-minV)/(maxV-minV)
    local fill = make("Frame", {
        Size=UDim2.new(pct,0,1,0), BackgroundColor3=T.SliderFill,
        BorderSizePixel=0, ZIndex=6,
    }, track)
    corner(99, fill)

    local thumb = make("Frame", {
        Size=UDim2.new(0,14,0,14), Position=UDim2.new(pct,-7,0.5,-7),
        BackgroundColor3=T.SliderThumb, BorderSizePixel=0, ZIndex=7,
    }, track)
    corner(99, thumb)
    stroke(T.SliderFill, 2, 0.08, thumb)

    local hitbox = make("TextButton", {
        Size=UDim2.new(1,0,1,18), Position=UDim2.new(0,0,0,-9),
        BackgroundTransparency=1, Text="", ZIndex=8, AutoButtonColor=false,
    }, track)

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local nv  = math.floor(minV + (maxV-minV)*rel)
        if nv == val then return end
        val = nv
        valLbl.Text = tostring(val)..suffix
        tween(fill,  {Size=UDim2.new(rel,0,1,0)},          0.04)
        tween(thumb, {Position=UDim2.new(rel,-7,0.5,-7)},   0.04)
        task.spawn(cb, val)
    end

    hitbox.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true; update(inp.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement
        or inp.UserInputType==Enum.UserInputType.Touch) then update(inp.Position.X) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    table.insert(tab._elements, f)
    return {
        Set = function(v)
            val = math.clamp(v, minV, maxV)
            local r = (val-minV)/(maxV-minV)
            valLbl.Text = tostring(val)..suffix
            tween(fill,  {Size=UDim2.new(r,0,1,0)},         0.20)
            tween(thumb, {Position=UDim2.new(r,-7,0.5,-7)}, 0.20)
        end,
        Get    = function() return val end,
        _frame = f,
    }
end

-- ════════════════════════════════════════════════════════════════════════
--  DROPDOWN
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddDropdown(tab, cfg)
    cfg = cfg or {}
    local T      = self.Theme
    local opts   = cfg.Options or {}
    local sel    = cfg.Default or opts[1] or "Selecionar"
    local cb     = cfg.Callback or function() end
    local isOpen = false

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Surface,
        BackgroundTransparency=T.SurfaceTrans, BorderSizePixel=0,
        ZIndex=4, LayoutOrder=#tab._elements+1, ClipsDescendants=false,
    }, tab._page)
    corner(9, f)
    stroke(T.Border, 1, T.BorderTrans, f)

    make("TextLabel", {
        Size=UDim2.new(0.50,0,1,0), Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1, Text=cfg.Name or "Dropdown",
        TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    }, f)

    local selLbl = make("TextLabel", {
        Size=UDim2.new(0.36,0,1,0), Position=UDim2.new(0.55,0,0,0),
        BackgroundTransparency=1, Text=sel, TextColor3=T.TextAccent, TextSize=11,
        Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Right,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=5,
    }, f)

    local arrow = make("TextLabel", {
        Size=UDim2.new(0,18,1,0), Position=UDim2.new(1,-20,0,0),
        BackgroundTransparency=1, Text="⌄", TextColor3=T.TextMuted,
        TextSize=14, Font=Enum.Font.GothamBold, ZIndex=5,
    }, f)

    local listH = math.min(#opts,5)*30 + 8
    local list  = make("Frame", {
        Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,1,4),
        BackgroundColor3=T.SurfaceAlt, BackgroundTransparency=0.0,
        BorderSizePixel=0, ZIndex=30, ClipsDescendants=true, Visible=false,
    }, f)
    corner(9, list)
    stroke(T.Border, 1, T.BorderTrans-0.14, list)
    padding(4,4,4,4, list)
    make("UIListLayout", {Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder}, list)

    local function refreshAll()
        for _, ch in ipairs(list:GetChildren()) do
            if ch:IsA("TextButton") then
                local active = ch.Text == sel
                tween(ch, {
                    BackgroundColor3    = active and T.AccentDim or T.Surface,
                    BackgroundTransparency = active and 0.28 or 0.5,
                }, 0.10)
                ch.TextColor3 = active and T.Text or T.TextSub
                ch.Font       = active and Enum.Font.GothamBold or Enum.Font.Gotham
            end
        end
    end

    for _, opt in ipairs(opts) do
        local ob = make("TextButton", {
            Size=UDim2.new(1,0,0,26),
            BackgroundColor3=opt==sel and T.AccentDim or T.Surface,
            BackgroundTransparency=opt==sel and 0.28 or 0.5,
            Text=opt, TextColor3=opt==sel and T.Text or T.TextSub,
            TextSize=11, Font=opt==sel and Enum.Font.GothamBold or Enum.Font.Gotham,
            BorderSizePixel=0, ZIndex=31, AutoButtonColor=false,
        }, list)
        corner(7, ob)
        ob.MouseButton1Click:Connect(function()
            sel=opt; selLbl.Text=opt; refreshAll(); task.spawn(cb, sel)
            isOpen=false
            tween(list, {Size=UDim2.new(1,0,0,0)}, 0.20)
            tween(arrow, {Rotation=0}, 0.20)
            task.delay(0.22, function() list.Visible=false end)
        end)
        ob.MouseEnter:Connect(function()
            if ob.Text~=sel then tween(ob, {BackgroundTransparency=0.20}, 0.10) end
        end)
        ob.MouseLeave:Connect(function()
            if ob.Text~=sel then tween(ob, {BackgroundTransparency=0.50}, 0.10) end
        end)
    end

    local togBtn = make("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="", ZIndex=6, AutoButtonColor=false,
    }, f)
    togBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            list.Visible=true
            tween(list,  {Size=UDim2.new(1,0,0,listH)}, 0.26, Enum.EasingStyle.Back)
            tween(arrow, {Rotation=180}, 0.20)
        else
            tween(list,  {Size=UDim2.new(1,0,0,0)}, 0.20)
            tween(arrow, {Rotation=0}, 0.20)
            task.delay(0.22, function() list.Visible=false end)
        end
    end)

    table.insert(tab._elements, f)
    return {
        Set    = function(v) sel=v; selLbl.Text=v end,
        Get    = function() return sel end,
        _frame = f,
    }
end

-- ════════════════════════════════════════════════════════════════════════
--  INPUT
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddInput(tab, cfg)
    cfg = cfg or {}
    local T  = self.Theme
    local cb = cfg.Callback or function() end

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Surface,
        BackgroundTransparency=T.SurfaceTrans, BorderSizePixel=0,
        ZIndex=4, LayoutOrder=#tab._elements+1,
    }, tab._page)
    corner(9, f)
    stroke(T.Border, 1, T.BorderTrans, f)

    make("TextLabel", {
        Size=UDim2.new(0.36,0,1,0), Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1, Text=cfg.Name or "Input",
        TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    }, f)

    local boxFrame = make("Frame", {
        Size=UDim2.new(0.60,0,0,26), Position=UDim2.new(0.40,0,0.5,-13),
        BackgroundColor3=T.SurfaceAlt, BackgroundTransparency=0.10,
        BorderSizePixel=0, ZIndex=5,
    }, f)
    corner(7, boxFrame)
    local boxStroke = stroke(T.Border, 1, T.BorderTrans, boxFrame)

    local box = make("TextBox", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=cfg.Default or "", PlaceholderText=cfg.Placeholder or "...",
        TextColor3=T.Text, PlaceholderColor3=T.TextMuted,
        TextSize=12, Font=Enum.Font.Gotham,
        ClearTextOnFocus=false, BorderSizePixel=0, ZIndex=6,
    }, boxFrame)
    padding(0,0,8,8, box)

    box.Focused:Connect(function()
        tween(boxStroke, {Color=T.Accent, Transparency=0.26}, 0.15)
    end)
    box.FocusLost:Connect(function(enter)
        tween(boxStroke, {Color=T.Border, Transparency=T.BorderTrans}, 0.15)
        task.spawn(cb, box.Text, enter)
    end)

    table.insert(tab._elements, f)
    return {
        Set    = function(v) box.Text=tostring(v) end,
        Get    = function() return box.Text end,
        _frame = f,
    }
end

-- ════════════════════════════════════════════════════════════════════════
--  KEYBIND
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddKeybind(tab, cfg)
    cfg = cfg or {}
    local T         = self.Theme
    local key       = cfg.Default or Enum.KeyCode.F
    local cb        = cfg.Callback or function() end
    local listening = false

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Surface,
        BackgroundTransparency=T.SurfaceTrans, BorderSizePixel=0,
        ZIndex=4, LayoutOrder=#tab._elements+1,
    }, tab._page)
    corner(9, f)
    stroke(T.Border, 1, T.BorderTrans, f)

    make("TextLabel", {
        Size=UDim2.new(0.60,0,1,0), Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1, Text=cfg.Name or "Keybind",
        TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    }, f)

    local kFrame = make("Frame", {
        Size=UDim2.new(0,80,0,26), Position=UDim2.new(1,-90,0.5,-13),
        BackgroundColor3=T.SurfaceAlt, BackgroundTransparency=0.08,
        BorderSizePixel=0, ZIndex=5,
    }, f)
    corner(7, kFrame)
    stroke(T.Accent, 1, 0.50, kFrame)

    local kLbl = make("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=key.Name, TextColor3=T.TextAccent,
        TextSize=11, Font=Enum.Font.GothamBold, ZIndex=6,
    }, kFrame)

    local kBtn = make("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="", ZIndex=7, AutoButtonColor=false,
    }, kFrame)

    kBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening       = true
        kLbl.Text       = "…"
        kLbl.TextColor3 = T.TextMuted
        tween(kFrame, {BackgroundColor3=T.Warning}, 0.10)
    end)

    UIS.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if listening then
            key             = inp.KeyCode
            kLbl.Text       = key.Name
            kLbl.TextColor3 = T.TextAccent
            tween(kFrame, {BackgroundColor3=T.SurfaceAlt}, 0.10)
            listening = false
        elseif inp.KeyCode == key then
            task.spawn(cb, key)
        end
    end)

    table.insert(tab._elements, f)
    return {
        Get    = function() return key end,
        _frame = f,
    }
end

-- ════════════════════════════════════════════════════════════════════════
--  LABEL
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddLabel(tab, cfg)
    cfg = cfg or {}
    local T = self.Theme

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, ZIndex=4, LayoutOrder=#tab._elements+1,
    }, tab._page)

    local lbl = make("TextLabel", {
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, Text=cfg.Text or "",
        TextColor3=cfg.Color or T.TextSub,
        TextSize=cfg.Size or 11,
        Font=cfg.Bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, ZIndex=5,
    }, f)
    padding(2,2,4,4, lbl)

    table.insert(tab._elements, f)
    return {
        Set    = function(v) lbl.Text=v end,
        Get    = function() return lbl.Text end,
        _frame = f,
    }
end

-- ════════════════════════════════════════════════════════════════════════
--  COLOR PICKER
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddColorPicker(tab, cfg)
    cfg = cfg or {}
    local T  = self.Theme
    local cb = cfg.Callback or function() end
    local h, s, v2 = 0.6, 1, 1
    local isOpen   = false

    if cfg.Default then h, s, v2 = Color3.toHSV(cfg.Default) end
    local curColor = Color3.fromHSV(h, s, v2)

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=T.Surface,
        BackgroundTransparency=T.SurfaceTrans, BorderSizePixel=0,
        ZIndex=4, LayoutOrder=#tab._elements+1, ClipsDescendants=false,
    }, tab._page)
    corner(9, f)
    stroke(T.Border, 1, T.BorderTrans, f)

    make("TextLabel", {
        Size=UDim2.new(0.60,0,1,0), Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1, Text=cfg.Name or "Color",
        TextColor3=T.Text, TextSize=12, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=5,
    }, f)

    local preview = make("Frame", {
        Size=UDim2.new(0,28,0,20), Position=UDim2.new(1,-38,0.5,-10),
        BackgroundColor3=curColor, BorderSizePixel=0, ZIndex=5,
    }, f)
    corner(6, preview)
    stroke(T.Border, 1, T.BorderTrans, preview)

    local panel = make("Frame", {
        Size=UDim2.new(1,0,0,0), Position=UDim2.new(0,0,1,4),
        BackgroundColor3=T.SurfaceAlt, BackgroundTransparency=0.0,
        BorderSizePixel=0, ZIndex=30, ClipsDescendants=true, Visible=false,
    }, f)
    corner(9, panel)
    stroke(T.Border, 1, T.BorderTrans-0.10, panel)
    padding(8,8,8,8, panel)
    make("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder}, panel)

    local function makeSliderRow(label, startVal, onUpdate)
        local row = make("Frame", {
            Size=UDim2.new(1,0,0,28), BackgroundTransparency=1, ZIndex=31,
        }, panel)
        make("TextLabel", {
            Size=UDim2.new(0,30,1,0), BackgroundTransparency=1, Text=label,
            TextColor3=T.TextMuted, TextSize=10, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=32,
        }, row)
        local trk = make("Frame", {
            Size=UDim2.new(1,-60,0,4), Position=UDim2.new(0,34,0.5,-2),
            BackgroundColor3=T.SliderTrack, BorderSizePixel=0, ZIndex=32,
        }, row)
        corner(99, trk)
        local fil = make("Frame", {
            Size=UDim2.new(startVal,0,1,0), BackgroundColor3=T.SliderFill,
            BorderSizePixel=0, ZIndex=33,
        }, trk)
        corner(99, fil)
        local thb = make("Frame", {
            Size=UDim2.new(0,12,0,12), Position=UDim2.new(startVal,-6,0.5,-6),
            BackgroundColor3=T.SliderThumb, BorderSizePixel=0, ZIndex=34,
        }, trk)
        corner(99, thb)
        local numLbl = make("TextLabel", {
            Size=UDim2.new(0,24,1,0), Position=UDim2.new(1,0,0,0),
            BackgroundTransparency=1, Text=tostring(math.floor(startVal*100)),
            TextColor3=T.TextAccent, TextSize=10, Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Right, ZIndex=32,
        }, row)
        local hit = make("TextButton", {
            Size=UDim2.new(1,0,1,10), Position=UDim2.new(0,0,0,-5),
            BackgroundTransparency=1, Text="", ZIndex=35, AutoButtonColor=false,
        }, trk)
        local drag2 = false
        local function upd(x)
            local r = math.clamp((x-trk.AbsolutePosition.X)/trk.AbsoluteSize.X, 0, 1)
            tween(fil, {Size=UDim2.new(r,0,1,0)}, 0.04)
            tween(thb, {Position=UDim2.new(r,-6,0.5,-6)}, 0.04)
            numLbl.Text = tostring(math.floor(r*100))
            onUpdate(r)
        end
        hit.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1
            or inp.UserInputType==Enum.UserInputType.Touch then drag2=true; upd(inp.Position.X) end
        end)
        UIS.InputChanged:Connect(function(inp)
            if drag2 and (inp.UserInputType==Enum.UserInputType.MouseMovement
            or inp.UserInputType==Enum.UserInputType.Touch) then upd(inp.Position.X) end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1
            or inp.UserInputType==Enum.UserInputType.Touch then drag2=false end
        end)
    end

    local function updateColor()
        curColor = Color3.fromHSV(h, s, v2)
        preview.BackgroundColor3 = curColor
        task.spawn(cb, curColor)
    end

    makeSliderRow("H", h,  function(r) h=r;  updateColor() end)
    makeSliderRow("S", s,  function(r) s=r;  updateColor() end)
    makeSliderRow("V", v2, function(r) v2=r; updateColor() end)

    local panelH = 3*32 + 20
    local togBtn = make("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="", ZIndex=6, AutoButtonColor=false,
    }, f)
    togBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            panel.Visible=true
            tween(panel, {Size=UDim2.new(1,0,0,panelH)}, 0.25, Enum.EasingStyle.Back)
        else
            tween(panel, {Size=UDim2.new(1,0,0,0)}, 0.20)
            task.delay(0.22, function() panel.Visible=false end)
        end
    end)

    table.insert(tab._elements, f)
    return {
        Set = function(c) h,s,v2=Color3.toHSV(c); updateColor() end,
        Get = function() return curColor end,
        _frame = f,
    }
end

-- ════════════════════════════════════════════════════════════════════════
--  LINK CARD
--  Detecta automaticamente discord/youtube/github/image
--  Clique expande o banner se tiver imagem, ou notifica o URL
--  Botão Copy copia o URL para o clipboard
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddLinkCard(tab, cfg)
    cfg = cfg or {}
    local T   = self.Theme
    local url = cfg.URL or ""

    -- detecção automática de tipo pelo domínio
    local lurl = url:lower()
    local dtype = "generic"
    if     lurl:find("discord%.gg") or lurl:find("discord%.com") then dtype="discord"
    elseif lurl:find("youtube%.com") or lurl:find("youtu%.be")   then dtype="youtube"
    elseif lurl:find("github%.com")                               then dtype="github"
    elseif lurl:find("%.png") or lurl:find("%.jpg") or lurl:find("%.jpeg")
        or lurl:find("%.gif") or lurl:find("%.webp")
        or lurl:find("imgur%.com") or lurl:find("i%.gyazo")       then dtype="image"
    end

    -- paleta e ícone por tipo
    local tColor = cfg.Color or (
        dtype=="discord" and rgb(88,101,242)  or
        dtype=="youtube" and rgb(255,0,0)     or
        dtype=="github"  and rgb(180,180,180) or T.Accent
    )
    local tIcon = cfg.Icon or (
        dtype=="discord" and "💬" or
        dtype=="youtube" and "▶"  or
        dtype=="github"  and "⬡"  or
        dtype=="image"   and "🖼"  or "🔗"
    )
    local tTitle = cfg.Title or (
        dtype=="discord" and "Discord" or
        dtype=="youtube" and "YouTube" or
        dtype=="github"  and "GitHub"  or
        dtype=="image"   and "Imagem"  or "Link"
    )

    local hasImg  = (cfg.Image and cfg.Image~="") or dtype=="image"
    local baseH   = 72
    local imgH    = 140
    local isOpen  = false

    local f = make("Frame", {
        Size=UDim2.new(1,0,0,baseH), BackgroundColor3=T.Surface,
        BackgroundTransparency=T.SurfaceTrans, BorderSizePixel=0,
        ZIndex=4, LayoutOrder=#tab._elements+1, ClipsDescendants=false,
    }, tab._page)
    corner(12, f)
    stroke(tColor, 1.5, 0.36, f)

    -- barra lateral colorida
    local sideBar = make("Frame", {
        Size=UDim2.new(0,4,1,0), BackgroundColor3=tColor,
        BorderSizePixel=0, ZIndex=5,
    }, f)
    corner(99, sideBar)

    -- brilho topo interno
    make("Frame", {
        Size=UDim2.new(1,0,0,1), BackgroundColor3=Color3.new(1,1,1),
        BackgroundTransparency=0.88, BorderSizePixel=0, ZIndex=5,
    }, f)

    -- ícone
    local iconBg = make("Frame", {
        Size=UDim2.new(0,36,0,36), Position=UDim2.new(0,14,0,18),
        BackgroundColor3=tColor, BackgroundTransparency=0.80,
        BorderSizePixel=0, ZIndex=6,
    }, f)
    corner(10, iconBg)
    stroke(tColor, 1, 0.48, iconBg)
    make("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=tIcon, TextColor3=tColor, TextSize=16, Font=Enum.Font.GothamBold, ZIndex=7,
    }, iconBg)

    -- título
    make("TextLabel", {
        Size=UDim2.new(1,-134,0,18), Position=UDim2.new(0,58,0,14),
        BackgroundTransparency=1, Text=tTitle, TextColor3=T.Text, TextSize=13,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=6,
    }, f)

    -- descrição
    local desc = (cfg.Description and cfg.Description~="") and cfg.Description or url
    make("TextLabel", {
        Size=UDim2.new(1,-134,0,14), Position=UDim2.new(0,58,0,34),
        BackgroundTransparency=1, Text=desc,
        TextColor3=T.TextMuted, TextSize=10, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=6,
    }, f)

    -- url abreviado
    make("TextLabel", {
        Size=UDim2.new(1,-134,0,12), Position=UDim2.new(0,58,0,51),
        BackgroundTransparency=1,
        Text=url:gsub("https?://",""):sub(1,38)..(#url>38 and "…" or ""),
        TextColor3=tColor, TextSize=9, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=6,
    }, f)

    -- botão COPY
    local cpFrame = make("Frame", {
        Size=UDim2.new(0,62,0,26), Position=UDim2.new(1,-72,0,23),
        BackgroundColor3=tColor, BackgroundTransparency=0.76,
        BorderSizePixel=0, ZIndex=7,
    }, f)
    corner(7, cpFrame)
    stroke(tColor, 1, 0.46, cpFrame)
    local cpLbl = make("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="📋 Copy", TextColor3=tColor, TextSize=10, Font=Enum.Font.GothamBold, ZIndex=8,
    }, cpFrame)
    local cpBtn = make("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text="", ZIndex=9, AutoButtonColor=false,
    }, cpFrame)
    cpBtn.MouseEnter:Connect(function() tween(cpFrame, {BackgroundTransparency=0.40}, 0.12) end)
    cpBtn.MouseLeave:Connect(function() tween(cpFrame, {BackgroundTransparency=0.76}, 0.12) end)
    cpBtn.MouseButton1Click:Connect(function()
        ripple(cpFrame, tColor)
        pcall(function() game:GetService("Clipboard"):SetText(url) end)
        cpLbl.Text = "✓ Copiado!"
        tween(cpFrame, {BackgroundTransparency=0.20}, 0.10)
        task.delay(1.8, function()
            cpLbl.Text = "📋 Copy"
            tween(cpFrame, {BackgroundTransparency=0.76}, 0.30)
        end)
        self:Notify({Title="Link copiado!", Message=url:sub(1,48), Type="Success", Duration=2})
    end)

    -- painel de imagem expansível
    local imgPanel
    if hasImg then
        imgPanel = make("Frame", {
            Size=UDim2.new(1,-8,0,0), Position=UDim2.new(0,4,0,baseH+4),
            BackgroundColor3=T.SurfaceAlt, BackgroundTransparency=0.04,
            BorderSizePixel=0, ZIndex=6, ClipsDescendants=true, Visible=false,
        }, f)
        corner(10, imgPanel)
        stroke(tColor, 1, 0.52, imgPanel)

        local imgSrc = (cfg.Image and cfg.Image~="") and cfg.Image or url
        make("ImageLabel", {
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=0.0,
            BackgroundColor3=T.Surface,
            Image=imgSrc, ScaleType=Enum.ScaleType.Crop, ZIndex=7,
        }, imgPanel)

        -- seta indicadora
        make("TextLabel", {
            Size=UDim2.new(0,18,0,18), Position=UDim2.new(1,-22,0,27),
            BackgroundTransparency=1, Text="▼", TextColor3=tColor,
            TextSize=10, Font=Enum.Font.GothamBold, ZIndex=9,
        }, f)
    end

    -- área clicável principal
    local mainBtn = make("TextButton", {
        Size=UDim2.new(1,0,0,baseH), BackgroundTransparency=1,
        Text="", ZIndex=8, AutoButtonColor=false,
    }, f)
    mainBtn.MouseEnter:Connect(function()
        tween(f, {BackgroundColor3=T.SurfaceHover, BackgroundTransparency=T.SurfaceHoverTrans}, 0.12)
    end)
    mainBtn.MouseLeave:Connect(function()
        tween(f, {BackgroundColor3=T.Surface, BackgroundTransparency=T.SurfaceTrans}, 0.12)
    end)
    mainBtn.MouseButton1Click:Connect(function()
        ripple(f, tColor)
        if cfg.OnClick then task.spawn(cfg.OnClick, url) end
        if hasImg then
            isOpen = not isOpen
            if isOpen then
                imgPanel.Visible=true
                tween(f,        {Size=UDim2.new(1,0,0,baseH+imgH+8)}, 0.30, Enum.EasingStyle.Back)
                tween(imgPanel, {Size=UDim2.new(1,-8,0,imgH)},         0.30, Enum.EasingStyle.Back)
            else
                tween(f,        {Size=UDim2.new(1,0,0,baseH)}, 0.22)
                tween(imgPanel, {Size=UDim2.new(1,-8,0,0)},    0.20)
                task.delay(0.24, function() if imgPanel then imgPanel.Visible=false end end)
            end
        else
            self:Notify({Title=tTitle, Message=url:sub(1,52), Type="Info", Duration=3})
        end
    end)

    table.insert(tab._elements, f)
    return {
        SetURL = function(u) url=u end,
        GetURL = function() return url end,
        _frame = f,
    }
end

-- ════════════════════════════════════════════════════════════════════════
--  NOTIFY  (stack no canto inferior direito)
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:Notify(cfg)
    cfg = cfg or {}
    local T     = self.Theme
    local dur   = cfg.Duration or 3
    local ntype = cfg.Type or "Info"
    local color = ntype=="Success" and T.Success
               or ntype=="Warning" and T.Warning
               or ntype=="Danger"  and T.Danger
               or T.Accent

    local idx = #self._notifyQ
    local n = make("Frame", {
        Size=UDim2.new(0,302,0,64),
        Position=UDim2.new(1,16,1,-(20+idx*74)),
        BackgroundColor3=T.NotifyBg, BackgroundTransparency=T.NotifyBgTrans,
        BorderSizePixel=0, ZIndex=150,
    }, self._root)
    corner(12, n)
    stroke(color, 1.5, 0.26, n)

    -- barra lateral colorida
    local strip = make("Frame", {
        Size=UDim2.new(0,3,1,0), BackgroundColor3=color, BorderSizePixel=0, ZIndex=151,
    }, n)
    corner(99, strip)

    -- ícone
    local icons = {Success="✓", Warning="⚠", Danger="✕", Info="ℹ"}
    local iF = make("Frame", {
        Size=UDim2.new(0,28,0,28), Position=UDim2.new(0,12,0.5,-14),
        BackgroundColor3=color, BackgroundTransparency=0.74,
        BorderSizePixel=0, ZIndex=152,
    }, n)
    corner(8, iF)
    make("TextLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Text=icons[ntype] or "ℹ", TextColor3=color,
        TextSize=13, Font=Enum.Font.GothamBold, ZIndex=153,
    }, iF)

    make("TextLabel", {
        Size=UDim2.new(1,-52,0,18), Position=UDim2.new(0,48,0,8),
        BackgroundTransparency=1, Text=cfg.Title or "Notificação",
        TextColor3=T.Text, TextSize=12, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=152,
    }, n)
    make("TextLabel", {
        Size=UDim2.new(1,-52,0,16), Position=UDim2.new(0,48,0,28),
        BackgroundTransparency=1, Text=cfg.Message or "",
        TextColor3=T.TextSub, TextSize=10, Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=152,
    }, n)

    -- barra de progresso
    local bar = make("Frame", {
        Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=color, BackgroundTransparency=0.28,
        BorderSizePixel=0, ZIndex=153,
    }, n)
    corner(99, bar)

    table.insert(self._notifyQ, n)
    local targetY = -(72 + idx*74)
    tween(n, {Position=UDim2.new(1,-312,1,targetY)}, 0.42, Enum.EasingStyle.Back)
    tween(bar, {Size=UDim2.new(0,0,0,2)}, dur, Enum.EasingStyle.Linear)

    task.delay(dur, function()
        tween(n, {Position=UDim2.new(1,16,1,targetY)}, 0.28)
        task.delay(0.32, function()
            if n then n:Destroy() end
            for i, v in ipairs(self._notifyQ) do
                if v==n then table.remove(self._notifyQ,i); break end
            end
        end)
    end)
end

-- ════════════════════════════════════════════════════════════════════════
--  SET THEME
--  Aceita:
--    Win:SetTheme("Crimson")                        → preset por nome
--    Win:SetTheme({ Accent=Color3... })             → override parcial
--    Win:SetTheme({ Preset="Ocean", Accent=... })   → preset + override
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:SetTheme(input)
    self.Theme = resolveTheme(input)
    local pos  = self._windowHolder.Position
    local open = self._open

    self._root:Destroy()
    self._tabs={};self._active=nil;self._notifyQ={};self._minimized=false
    self:_buildRoot()
    self:_buildShortcut()
    self:_buildWindow()
    self:_buildCloseModal()

    self._windowHolder.Position = pos
    if not open then
        self._open = true
        self:_toggleWindow()
    end

    for _, fn in ipairs(self._themeCallbacks) do
        task.spawn(fn, self.Theme)
    end
end

-- ════════════════════════════════════════════════════════════════════════
--  REGISTER THEME  — registra tema personalizado reutilizável por nome
--  Win:RegisterTheme("MeuTema", { Accent=Color3, WindowBg=Color3, ... })
--  Win:SetTheme("MeuTema")
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:RegisterTheme(name, overrides)
    assert(type(name)=="string",  "[KillerLib] RegisterTheme: nome deve ser string")
    assert(type(overrides)=="table", "[KillerLib] RegisterTheme: overrides deve ser tabela")
    local full = resolveTheme(overrides)
    KillerLib.Themes[name] = full
    return full
end

-- ════════════════════════════════════════════════════════════════════════
--  GET THEME NAMES  — lista todos os temas disponíveis (embutidos + custom)
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:GetThemeNames()
    local names = {}
    for k in pairs(KillerLib.Themes) do table.insert(names, k) end
    table.sort(names)
    return names
end

-- ════════════════════════════════════════════════════════════════════════
--  ON THEME CHANGED  — registra callback disparado ao mudar tema
--  Win:OnThemeChanged(function(theme) print(theme.Accent) end)
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:OnThemeChanged(fn)
    assert(type(fn)=="function", "[KillerLib] OnThemeChanged: esperava uma função")
    table.insert(self._themeCallbacks, fn)
end

-- ════════════════════════════════════════════════════════════════════════
--  EXPORT THEME  — serializa tema atual em código Lua copiável
--  Retorna a string e tenta copiar para o clipboard automaticamente.
--  Win:ExportTheme("MeuTema") → gera Win:RegisterTheme("MeuTema", {...})
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:ExportTheme(name)
    local T = self.Theme
    name = name or "MeuTema"

    local function c3(c)
        return string.format("Color3.fromRGB(%d,%d,%d)",
            math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
    end

    -- ordem de saída legível
    local ORDER = {
        -- fundos
        "WindowBg","TopbarBg","SidebarBg","CardBg",
        -- superfícies
        "Surface","SurfaceAlt","SurfaceHover",
        -- bordas
        "Border",
        -- accent
        "Accent","AccentDim",
        -- texto
        "Text","TextSub","TextMuted","TextAccent",
        -- estados
        "Success","Warning","Danger",
        -- toggle
        "ToggleOn","ToggleOff","ToggleKnob",
        -- slider
        "SliderTrack","SliderFill","SliderThumb",
        -- atalho
        "ShortcutBg","ShortcutBorder","ShortcutText",
        -- notify / modal
        "NotifyBg","ModalBg","ModalBorder",
        -- transparências (numérico)
        "WindowBgTrans","TopbarBgTrans","SidebarBgTrans","CardBgTrans",
        "SurfaceTrans","SurfaceHoverTrans",
        "BorderTrans",
        "ShortcutBgTrans","ShortcutBorderTrans",
        "NotifyBgTrans","ModalBgTrans","ModalBorderTrans",
    }

    local lines = { 'Win:RegisterTheme("'..name..'", {' }
    for _, k in ipairs(ORDER) do
        local v = T[k]
        if v ~= nil then
            local vStr
            if type(v) == "number" then
                vStr = string.format("%.4f", v)
            else
                vStr = c3(v)
            end
            table.insert(lines, string.format("    %-22s= %s,", k, vStr))
        end
    end
    table.insert(lines, "})")
    table.insert(lines, 'Win:SetTheme("'..name..'")')

    local result = table.concat(lines, "\n")
    pcall(function() game:GetService("Clipboard"):SetText(result) end)

    print("━━━━━━━━━━━━━━━━ KillerLib Theme Export ━━━━━━━━━━━━━━━━")
    print(result)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    return result
end

-- ════════════════════════════════════════════════════════════════════════
--  ADD THEME EDITOR
--  Injeta uma aba completa de editor visual de temas na hub.
--  Inclui: seletor de preset, color pickers para todas as cores,
--  sliders de transparência, pré-visualizar, salvar, exportar e reset.
--
--  Win:AddThemeEditor()
-- ════════════════════════════════════════════════════════════════════════
function KillerLib:AddThemeEditor()
    local tab = self:AddTab({ Name="Tema", Icon="🎨" })

    -- rascunho editável (não afeta o tema real até aplicar)
    local draft = deepCopy(self.Theme)

    -- ── Seção: Presets ─────────────────────────────────────────────────
    self:AddSection(tab, { Name="Presets embutidos" })
    self:AddLabel(tab, {
        Text="Selecione um preset como ponto de partida. Os campos abaixo serão atualizados automaticamente.",
    })

    self:AddDropdown(tab, {
        Name    = "Preset",
        Options = self:GetThemeNames(),
        Default = "Dark",
        Callback = function(name)
            local preset = KillerLib.Themes[name]
            if preset then
                for k, v in pairs(preset) do draft[k]=v end
                self:SetTheme(name)
                -- atualiza o draft também
                draft = deepCopy(self.Theme)
                self:Notify({Title="Preset aplicado",Message=name,Type="Success",Duration=2})
            end
        end,
    })

    -- ── Seção: Cores principais ─────────────────────────────────────────
    self:AddSection(tab, { Name="Cores principais" })
    self:AddLabel(tab, {
        Text="Clique em qualquer picker para abrir os sliders HSV. As alterações ficam em rascunho até clicar em Pré-visualizar ou Salvar.",
    })

    local pickers = {}
    local function addPicker(label, key)
        pickers[key] = self:AddColorPicker(tab, {
            Name     = label,
            Default  = draft[key] or rgb(100,130,255),
            Callback = function(c) draft[key]=c end,
        })
    end

    addPicker("Fundo da janela (WindowBg)",   "WindowBg")
    addPicker("Accent — destaque principal",  "Accent")
    addPicker("Accent escuro (AccentDim)",    "AccentDim")
    addPicker("Superfície dos elementos",     "Surface")
    addPicker("Superfície alternativa",       "SurfaceAlt")
    addPicker("Borda",                        "Border")
    addPicker("Texto principal",              "Text")
    addPicker("Texto secundário",             "TextSub")
    addPicker("Texto muted / placeholder",    "TextMuted")
    addPicker("Texto com cor de Accent",      "TextAccent")
    addPicker("Toggle — estado ON",           "ToggleOn")
    addPicker("Toggle — estado OFF",          "ToggleOff")
    addPicker("Slider — preenchimento",       "SliderFill")
    addPicker("Slider — trilha",              "SliderTrack")
    addPicker("Barra de atalho — fundo",      "ShortcutBg")
    addPicker("Barra de atalho — borda",      "ShortcutBorder")
    addPicker("Notificação — fundo",          "NotifyBg")
    addPicker("Modal — fundo",                "ModalBg")
    addPicker("Modal — borda",                "ModalBorder")

    -- ── Seção: Transparências ──────────────────────────────────────────
    self:AddSection(tab, { Name="Transparências" })

    local function addTransSlider(label, key)
        return self:AddSlider(tab, {
            Name     = label,
            Min=0, Max=95,
            Default  = math.floor((draft[key] or 0)*100),
            Suffix   = "%",
            Callback = function(v) draft[key]=v/100 end,
        })
    end

    addTransSlider("Fundo da janela",    "WindowBgTrans")
    addTransSlider("Borda",              "BorderTrans")
    addTransSlider("Superfície",         "SurfaceTrans")
    addTransSlider("Atalho — fundo",     "ShortcutBgTrans")
    addTransSlider("Atalho — borda",     "ShortcutBorderTrans")
    addTransSlider("Notificação",        "NotifyBgTrans")
    addTransSlider("Modal",              "ModalBgTrans")

    -- ── Seção: Salvar & Exportar ───────────────────────────────────────
    self:AddSection(tab, { Name="Salvar & Exportar" })

    local nameInput = self:AddInput(tab, {
        Name        = "Nome do tema",
        Placeholder = "MeuTema, RoxoEscuro...",
        Default     = "MeuTema",
    })

    -- pré-visualizar (aplica rascunho sem salvar como preset)
    self:AddButton(tab, {
        Name        = "Pré-visualizar",
        Icon        = "👁",
        Description = "Aplica sem salvar",
        Callback    = function()
            self:SetTheme(draft)
            draft = deepCopy(self.Theme) -- sincroniza
            self:Notify({Title="Pré-visualizando",Message="Rascunho aplicado.",Type="Info",Duration=2})
        end,
    })

    -- salvar como preset nomeado
    self:AddButton(tab, {
        Name        = "Salvar como preset",
        Icon        = "💾",
        Description = "Usa o nome acima",
        Callback    = function()
            local n = nameInput.Get()
            if n=="" or n=="MeuTema" then
                self:Notify({Title="Digite um nome",Message="Escolha um nome único para o tema.",Type="Warning",Duration=3})
                return
            end
            self:RegisterTheme(n, draft)
            self:SetTheme(n)
            draft = deepCopy(self.Theme)
            self:Notify({
                Title   = "Tema salvo!",
                Message = '"'..n..'" disponível nos presets.',
                Type    = "Success",
                Duration = 4,
            })
        end,
    })

    -- exportar código copiável
    self:AddButton(tab, {
        Name        = "Exportar código",
        Icon        = "📋",
        Description = "Copia RegisterTheme() pro clipboard",
        Callback    = function()
            local n = nameInput.Get()
            if n=="" then n="MeuTema" end
            self:ExportTheme(n)
            self:Notify({
                Title   = "Código copiado!",
                Message = 'Cole no seu script e chame SetTheme("'..n..'").',
                Type    = "Success",
                Duration = 4,
            })
        end,
    })

    -- reset para Dark
    self:AddButton(tab, {
        Name     = "Resetar para Dark",
        Icon     = "↺",
        Callback = function()
            self:SetTheme("Dark")
            draft = deepCopy(self.Theme)
            self:Notify({Title="Reset",Message="Tema Dark restaurado.",Type="Info",Duration=2})
        end,
    })

    self:AddSection(tab, { Name="Como usar no seu script" })
    self:AddLabel(tab, {
        Text='1. Clique em "Exportar código"\n2. O código é copiado pro clipboard\n3. Cole no script antes de criar a janela\n4. Chame Win:SetTheme("NomeDoTema")',
    })
    self:AddLabel(tab, {
        Text='Ou use um tema inline:\nWin:SetTheme({ Accent = Color3.fromRGB(255,80,120) })',
        Color = Color3.fromRGB(120,148,255),
    })

    return tab
end

-- ════════════════════════════════════════════════════════════════════════
--  RETORNO
-- ════════════════════════════════════════════════════════════════════════
return KillerLib
