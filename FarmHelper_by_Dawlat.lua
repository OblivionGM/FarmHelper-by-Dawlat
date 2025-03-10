script_name("FarmHelper")
script_author("Dawlat")
script_version("v1.0.1")
require 'lib.moonloader'
local a = require "samp.events"
local b = require 'vkeys'
local c = require 'mimgui'
local d = require 'ffi'
local e = require("lfs")
local f = require 'encoding'
local g = require 'json'
local h = require 'inicfg'
local i = require 'mimhotkey'
f.default = 'CP1251'
local j = f.UTF8; local k = "v1.0.1"
local l = "FarmHelper " .. k .. " by Dawlat"
local m, n, o = c.new, d.string, d.sizeof; local p = "moonloader/farmhelper_logs"
local q = os.date("%Y-%m-%d")
local r = p .. "/progress_" .. q .. ".json"
local s; local t, u = getScreenResolution()
i.no_flood = false; local v = { prices = { ["Лён"] = 0, ["Хлопок"] = 0, ["Краситель"] = 0, ["Уголь"] = 0 }, settings = { showSyropInfo = false, showWarning = true, showServerTime = true, altEatMethod = false, usebinds = true, widgetPosX = 180, widgetPosY = u / 2, eatMethod = '/jmeat', healMethod = '/usedrugs 3' }, hotkey = { eatKey = "[69]", drugsKey = "[90]", beerKey = "[79]" } }
local w = 100; local x = c.new.bool(false)
local y = 260; local z = 340; local A = 180; local B = u / 2; local C = c.WindowFlags.NoResize + c.WindowFlags
.NoCollapse + c.WindowFlags.NoTitleBar; local D = c.new.bool(false)
local E = 0; local F; local G; local H; local I; local J, K; local L = 1; local M = false; local N = c.WindowFlags
.NoResize + c.WindowFlags.AlwaysAutoResize + c.WindowFlags.NoCollapse; local O = {}
local P = c.new.int(0)
local Q = c.new.int(0)
local R; local S; local T; local U; local V; local W; local X; local Y; local Z = { j "Данные за неделю", j "Данные за все время",
    j "Средние данные за неделю", j "Средние данные за все время" }
local _ = c.new['const char*'][#Z](Z)
local a0 = { ["Лён"] = 0, ["Хлопок"] = 0, ["Краситель"] = 0, ["Уголь"] = 0, ["Добыто ресурсов"] = 0 }
prices = { ["Лён"] = m.char[256]("0"), ["Хлопок"] = m.char[256]("0"), ["Краситель"] = m.char[256]("0"), ["Уголь"] = m
.char[256]("0") }
local a1 = { ["linen"] = "Лён", ["cotton"] = "Хлопок" }
local a2 = { "Лён", "Хлопок", "Уголь", "Краситель", "Добыто ресурсов" }
function main()
    repeat wait(100) until isSampAvailable()
    s = h.load(v, "farmhelper_config")
    loadPricesToBuffer()
    loadResources()
    getLogFiles()
    F = c.new.bool(s.settings.showWarning)
    showSyropInfo = c.new.bool(s.settings.showSyropInfo)
    H = c.new.bool(s.settings.altEatMethod)
    I = c.new.bool(s.settings.usebinds)
    A = s.settings.widgetPosX; B = s.settings.widgetPosY; eatMethod = s.settings.eatMethod; healMethod = s.settings
    .healMethod; J = m.char[256](s.settings.eatMethod)
    K = m.char[256](s.settings.healMethod)
    R = reverseArray(R)
    V = formatDates(R, V)
    S = c.new['const char*'][#V](V)
    W = getCurrentweekLogFiles(R)
    X = loadLogFilesByNames(W)
    Y = loadLogFilesByNames(R)
    chatMessage("Активация/деактивация - /farm, настройки - /fset")
    setBinds()
    i.RegisterCallback('Eat', O.Eat.keys, O.Eat.callback)
    i.RegisterCallback('Drugs', O.Drugs.keys, O.Drugs.callback)
    i.RegisterCallback('Beer', O.Beer.keys, O.Beer.callback)
    sampRegisterChatCommand("farm", toggleWidgetWindow)
    sampRegisterChatCommand("fset", toggleSettingWindow)
    while true do
        wait(1)
        if M then
            A, B = getCursorPos()
            if isKeyJustPressed(b.VK_RETURN) then
                M = false; chatMessage("Новая позиция виджета сохранена!")
                s.settings.widgetPosX = A; s.settings.widgetPosY = B; h.save(s, "farmhelper_config")
            end
        end; if q ~= os.date("%Y-%m-%d") then
            q = os.date("%Y-%m-%d")
            r = p .. "/progress_" .. q .. ".json"
            loadResources()
        end; if tonumber(w) <= 30 and x[0] and F[0] then createWarningSatietyDraw() else deleteWarningSatietyDraw() end
    end
end; function toggleWidgetWindow() if x[0] then
        x[0] = false; showMarks = false
    else
        loadResources()
        x[0] = true
    end end; function toggleSettingWindow() if D[0] then D[0] = false else D[0] = true end end; function calcTotalEarning(
    a3, prices)
    local a4 = 0; for a5, a6 in pairs(a3) do if prices[a5] then a4 = a4 + a6 * prices[a5] end end; return a4
end; function addResource(a5, a6) if a0[a5] then
        a0[a5] = a0[a5] + a6; a0["Добыто ресурсов"] = a0["Добыто ресурсов"] + 1; saveResources()
    end end; function loadPricesToBuffer() for a7, a8 in pairs(prices) do prices[a7] = numberToBuffer(s.prices[a7]) end end; function getSyropRemainingTime()
    local a9 = os.time()
    local aa = E + 1800 - a9; if aa <= 0 then return j "Не активирован" else
        local ab = math.floor(aa / 60)
        local ac = aa % 60; return string.format("%02d:%02d", ab, ac)
    end
end; function adjustWidgetSize()
    local ad = 0; ad = ad + 20; ad = ad + c.CalcTextSize(l).y; ad = ad + 32; ad = ad + 4; ad = ad +
    c.GetTextLineHeightWithSpacing() * (#a2 + 2)
    if showSyropInfo[0] then ad = ad + c.GetTextLineHeightWithSpacing() end; ad = ad + c.GetTextLineHeightWithSpacing()
    z = ad
end; c.OnFrame(function() return x[0] end,
    function(ae)
        adjustWidgetSize()
        ae.HideCursor = true; c.SetNextWindowPos(c.ImVec2(A, B), c.Cond.Always, c.ImVec2(0.5, 0.5))
        c.SetNextWindowSize(c.ImVec2(y, z), c.Cond.Always)
        c.Begin("FarmHelper Widget", x, C)
        c.PushStyleColor(c.Col.Text, toRGBVec(15, 105, 168))
        local af = c.GetWindowWidth()
        local ag = c.CalcTextSize(l).x; local ah = (af - ag) / 2; c.SetCursorPosX(ah)
        c.Text(l)
        c.Dummy(c.ImVec2(0, 3))
        c.Separator()
        c.Dummy(c.ImVec2(0, 3))
        c.PopStyleColor()
        c.Text(j "Статистика добытых ресурсов: ")
        c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
        for ai, a5 in ipairs(a2) do c.Text(j(a5) .. ": " .. a0[a5]) end; c.Dummy(c.ImVec2(0, 3))
        c.PopStyleColor()
        c.Separator()
        c.Dummy(c.ImVec2(0, 3))
        c.Text(j "Общая информация: ")
        c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
        if showSyropInfo[0] then c.Text(j "Сироп фермера: " .. getSyropRemainingTime()) end; c.Text(j "Общая стоимость: " ..
        formatCurrency(calcTotalEarning(a0, s.prices)))
        c.PopStyleColor()
        c.End()
    end)
c.OnFrame(function() return D[0] end,
    function(ae)
        c.SetNextWindowPos(c.ImVec2(t / 2, u / 2), c.Cond.FirstUseEver, c.ImVec2(0.5, 0.5))
        c.SetNextWindowSize(c.ImVec2(450, 350), c.Cond.Always)
        c.Begin(l, D, N)
        for aj, ak in pairs({ 'Цены', 'Логи', 'Статистика', 'Настройки', 'Информация' }) do if c.Button(j(ak), c.ImVec2(100, 30)) then L =
                aj end end; c.SetCursorPos(c.ImVec2(115, 28))
        if c.BeginChild('Name##' .. L, c.ImVec2(325, 310), true) then
            if L == 1 then
                c.PushStyleColor(c.Col.Text, toRGBVec(160, 160, 160))
                c.Text(j 'Цена продажи ресурсов:')
                c.PopStyleColor()
                for ai, a5 in ipairs(a2) do
                    c.SetNextItemWidth(120)
                    if prices[a5] then if c.InputText(j("$ продажа (" .. a5 .. ")"), prices[a5], 256) then
                            s.prices[a5] = bufferToNumber(prices[a5])
                            h.save(s, "farmhelper_config")
                        end end
                end
            elseif L == 2 then
                c.SetNextItemWidth(120)
                if c.Combo(j 'Выбрать дату', P, S, #V) then
                    U = R[P[0] + 1]
                    loadLogResources(U)
                end; c.Dummy(c.ImVec2(0, 3))
                if T then
                    c.Text(j "Статистика за " .. d.string(S[P[0]]) .. ": ")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    for ai, a5 in ipairs(a2) do c.Text(j(a5) .. ": " .. T[a5]) end; c.PopStyleColor()
                    c.Dummy(c.ImVec2(0, 3))
                    c.Text(j "Общая информация: ")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    c.Text(j "Общая стоимость: " .. formatCurrency(T["Общая стоимость"]))
                    c.PopStyleColor()
                else c.Text(j "Выберите файл для загрузки информации.") end
            elseif L == 3 then
                c.SetNextItemWidth(230)
                if c.Combo(j 'Период', Q, _, #Z) then
                    X = loadLogFilesByNames(W)
                    Y = loadLogFilesByNames(R)
                end; c.Dummy(c.ImVec2(0, 3))
                if Q[0] == 0 and X.count >= 1 then
                    c.Text(j "Статистика за текущую неделю [" .. X.count .. "]:")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    for ai, a5 in ipairs(a2) do c.Text(j(a5) .. ": " .. X.log[a5]) end; c.PopStyleColor()
                    c.Dummy(c.ImVec2(0, 2))
                    c.Text(j "Общая информация: ")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    c.Text(j "Общая стоимость: " .. formatCurrency(X.log["Общая стоимость"]))
                    c.PopStyleColor()
                elseif Q[0] == 1 and Y.count >= 1 then
                    c.Text(j "Статистика за весь период [" .. Y.count .. "]:")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    for ai, a5 in ipairs(a2) do c.Text(j(a5) .. ": " .. Y.log[a5]) end; c.PopStyleColor()
                    c.Dummy(c.ImVec2(0, 2))
                    c.Text(j "Общая информация: ")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    c.Text(j "Общая стоимость: " .. formatCurrency(Y.log["Общая стоимость"]))
                    c.PopStyleColor()
                elseif Q[0] == 2 and X.count >= 1 then
                    c.Text(j "Средние данные за текущую неделю [" .. X.count .. "]:")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    for ai, a5 in ipairs(a2) do c.Text(j(a5) .. ": " .. string.format("%.1f", X.log[a5] / X.count)) end; c
                        .PopStyleColor()
                    c.Dummy(c.ImVec2(0, 2))
                    c.Text(j "Общая информация: ")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    c.Text(j "Общая стоимость: " .. formatCurrency(math.floor(X.log["Общая стоимость"] / X.count + 0.5)))
                    c.PopStyleColor()
                elseif Q[0] == 3 and Y.count >= 1 then
                    c.Text(j "Средние данные за весь период [" .. Y.count .. "]:")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    for ai, a5 in ipairs(a2) do c.Text(j(a5) .. ": " .. string.format("%.1f", Y.log[a5] / Y.count)) end; c
                        .PopStyleColor()
                    c.Dummy(c.ImVec2(0, 2))
                    c.Text(j "Общая информация: ")
                    c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                    c.Text(j "Общая стоимость: " .. formatCurrency(math.floor(Y.log["Общая стоимость"] / Y.count + 0.5)))
                    c.PopStyleColor()
                else c.Text(j "Не достаточно информации для загрузки\nстатистики. Выберите другой период.") end
            elseif L == 4 then
                c.PushStyleColor(c.Col.Text, toRGBVec(160, 160, 160))
                c.Text(j 'Общие настройки:')
                c.PopStyleColor()
                c.SetNextItemWidth(120)
                if c.InputText(j("Команда еды"), J, 256) then
                    s.settings.eatMethod = d.string(J)
                    h.save(s, "farmhelper_config")
                end; c.SetNextItemWidth(120)
                if c.InputText(j("Команда лечения"), K, 256) then
                    s.settings.healMethod = d.string(K)
                    h.save(s, "farmhelper_config")
                end; if c.Checkbox(j "Отображать предупреждение о голоде", F) then
                    s.settings.showWarning = F[0]
                    h.save(s, "farmhelper_config")
                end; c.SameLine()
                c.TextDisabled("(?)")
                if c.IsItemHovered(0) then
                    c.BeginTooltip()
                    c.Text(j "Предупреждение появляется в нижней части экрана, отображаясь желтым цветом\nпри сытости ниже 30, красным при сытости ниже 25")
                    c.EndTooltip()
                end; if c.Checkbox(j "Комплексный обед вместо команды еды", H) then
                    s.settings.altEatMethod = H[0]
                    h.save(s, "farmhelper_config")
                end; c.SameLine()
                c.TextDisabled("(?)")
                if c.IsItemHovered(0) then
                    c.BeginTooltip()
                    c.Text(j "Вместо команды еды будет использоваться комплексный обед из инвентаря.\nДля работы данной функции необходимо, чтобы комплексный обед находился\nна первой странице инвентаря!")
                    c.EndTooltip()
                end; if c.Checkbox(j "Использовать бинды", I) then
                    s.settings.usebinds = I[0]
                    h.save(s, "farmhelper_config")
                end; c.Dummy(c.ImVec2(0, 10))
                c.PushStyleColor(c.Col.Text, toRGBVec(160, 160, 160))
                c.Text(j 'Виджет:')
                c.PopStyleColor()
                if c.Button(j 'Изменить позицию') then if x[0] then
                        M = true; chatMessage('Для сохранения позиции нажмите ENTER.')
                    else chatMessage('Чтобы изменить позицию, необходимо сначала включить виджет (/mine)!') end end; if c.Checkbox(j "Показывать информацию о сиропе", showSyropInfo) then
                    s.settings.showSyropInfo = showSyropInfo[0]
                    h.save(s, "farmhelper_config")
                end; c.Dummy(c.ImVec2(0, 10))
                c.PushStyleColor(c.Col.Text, toRGBVec(160, 160, 160))
                c.Text(j 'Настройка клавиш (при активации виджета):')
                c.PopStyleColor()
                local al = i.KeyEditor('Eat', 'Key', c.ImVec2(75, 25))
                if al then
                    s.hotkey.eatKey = encodeJson(al)
                    h.save(s, "farmhelper_config")
                end; c.SameLine()
                c.Text(j "Использование еды")
                local am = i.KeyEditor('Beer', 'Key', c.ImVec2(75, 25))
                if am then
                    s.hotkey.beerKey = encodeJson(am)
                    h.save(s, "farmhelper_config")
                end; c.SameLine()
                c.Text(j "Использование пива")
                local an = i.KeyEditor('Drugs', 'Key', c.ImVec2(75, 25))
                if an then
                    s.hotkey.drugsKey = encodeJson(an)
                    h.save(s, "farmhelper_config")
                end; c.SameLine()
                c.Text(j "Использование лечения")
            elseif L == 5 then
                c.PushStyleColor(c.Col.Text, toRGBVec(160, 160, 160))
                c.Text(j 'Разработано для Mercenari Family <3')
                c.PopStyleColor()
                c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                c.Text(j 'Автор скрипта:')
                c.SameLine()
                c.PopStyleColor()
                c.PushStyleColor(c.Col.Text, toRGBVec(255, 255, 255))
                c.Text(j 'Dawlat_Montgomery')
                c.PopStyleColor()
                c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                c.Text(j 'Сервер:')
                c.SameLine()
                c.PopStyleColor()
                c.PushStyleColor(c.Col.Text, toRGBVec(255, 255, 255))
                c.Text(j 'Scottdale[03]')
                c.PopStyleColor()
                c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                c.Text(j 'Больше скриптов:')
                c.SameLine()
                c.PopStyleColor()
                c.PushStyleColor(c.Col.Text, toRGBVec(255, 255, 255))
                c.Text(j 'https://github.com/OblivionGM')
                c.PopStyleColor()
                c.PushStyleColor(c.Col.Text, toRGBVec(255, 158, 0))
                c.Text(j 'Связь:')
                c.SameLine()
                c.PopStyleColor()
                c.PushStyleColor(c.Col.Text, toRGBVec(255, 255, 255))
                c.Text(j 'Telegram @oblivionGM')
                c.PopStyleColor()
            end; c.EndChild()
        end; c.End()
    end)
function createWarningSatietyDraw()
    local ao = 320; local ap = 400; local aq = "PRESS_BUTTON_TO_EAT"
    local ar = "0xFFC4A121"
    if tonumber(w) <= 25 then ar = "0xFFF80012" end; sampTextdrawCreate(251, aq, ao, ap)
    sampTextdrawSetLetterSizeAndColor(251, 0.6, 2.9, ar)
    sampTextdrawSetOutlineColor(251, 0.5, 0xFF000000)
    sampTextdrawSetAlign(251, 2)
    sampTextdrawSetStyle(251, 2)
end; function deleteWarningSatietyDraw() sampTextdrawDelete(251) end; c.OnInitialize(function() c.Theme() end)
function c.Theme()
    c.SwitchContext()
    c.GetStyle().FramePadding = c.ImVec2(5, 5)
    c.GetStyle().TouchExtraPadding = c.ImVec2(0, 0)
    c.GetStyle().IndentSpacing = 0; c.GetStyle().ScrollbarSize = 10; c.GetStyle().GrabMinSize = 10; c.GetStyle().WindowBorderSize = 1; c.GetStyle().ChildBorderSize = 1; c.GetStyle().PopupBorderSize = 1; c.GetStyle().FrameBorderSize = 1; c.GetStyle().TabBorderSize = 1; c.GetStyle().WindowRounding = 5; c.GetStyle().ChildRounding = 5; c.GetStyle().FrameRounding = 5; c.GetStyle().PopupRounding = 5; c.GetStyle().ScrollbarRounding = 5; c.GetStyle().GrabRounding = 5; c.GetStyle().TabRounding = 5; c.GetStyle().WindowTitleAlign =
    c.ImVec2(0.5, 0.5)
    c.GetStyle().ButtonTextAlign = c.ImVec2(0.5, 0.5)
    c.GetStyle().SelectableTextAlign = c.ImVec2(0.5, 0.5)
    c.GetStyle().Colors[c.Col.Text] = c.ImVec4(1.00, 1.00, 1.00, 1.00)
    c.GetStyle().Colors[c.Col.TextDisabled] = c.ImVec4(0.50, 0.50, 0.50, 1.00)
    c.GetStyle().Colors[c.Col.WindowBg] = c.ImVec4(0.07, 0.07, 0.07, 1.00)
    c.GetStyle().Colors[c.Col.ChildBg] = c.ImVec4(0.07, 0.07, 0.07, 1.00)
    c.GetStyle().Colors[c.Col.PopupBg] = c.ImVec4(0.07, 0.07, 0.07, 1.00)
    c.GetStyle().Colors[c.Col.Border] = c.ImVec4(0.25, 0.25, 0.25, 0.54)
    c.GetStyle().Colors[c.Col.BorderShadow] = c.ImVec4(0.00, 0.00, 0.00, 0.00)
    c.GetStyle().Colors[c.Col.FrameBg] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.FrameBgHovered] = c.ImVec4(0.25, 0.25, 0.25, 1.00)
    c.GetStyle().Colors[c.Col.FrameBgActive] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.TitleBg] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.TitleBgActive] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.TitleBgCollapsed] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.MenuBarBg] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.ScrollbarBg] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.ScrollbarGrab] = c.ImVec4(0.00, 0.00, 0.00, 1.00)
    c.GetStyle().Colors[c.Col.ScrollbarGrabHovered] = c.ImVec4(0.25, 0.25, 0.25, 1.00)
    c.GetStyle().Colors[c.Col.ScrollbarGrabActive] = c.ImVec4(0.00, 0.00, 0.00, 1.00)
    c.GetStyle().Colors[c.Col.CheckMark] = c.ImVec4(1.00, 1.00, 1.00, 1.00)
    c.GetStyle().Colors[c.Col.SliderGrab] = c.ImVec4(0.21, 0.20, 0.20, 1.00)
    c.GetStyle().Colors[c.Col.SliderGrabActive] = c.ImVec4(0.21, 0.20, 0.20, 1.00)
    c.GetStyle().Colors[c.Col.Button] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.ButtonHovered] = c.ImVec4(0.21, 0.20, 0.20, 1.00)
    c.GetStyle().Colors[c.Col.ButtonActive] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.Header] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.HeaderHovered] = c.ImVec4(0.20, 0.20, 0.20, 1.00)
    c.GetStyle().Colors[c.Col.HeaderActive] = c.ImVec4(0.47, 0.47, 0.47, 1.00)
    c.GetStyle().Colors[c.Col.Separator] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.SeparatorHovered] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.SeparatorActive] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.ResizeGrip] = c.ImVec4(1.00, 1.00, 1.00, 0.25)
    c.GetStyle().Colors[c.Col.ResizeGripHovered] = c.ImVec4(1.00, 1.00, 1.00, 0.67)
    c.GetStyle().Colors[c.Col.ResizeGripActive] = c.ImVec4(1.00, 1.00, 1.00, 0.95)
    c.GetStyle().Colors[c.Col.Tab] = c.ImVec4(0.12, 0.12, 0.12, 1.00)
    c.GetStyle().Colors[c.Col.TabHovered] = c.ImVec4(0.28, 0.28, 0.28, 1.00)
    c.GetStyle().Colors[c.Col.TabActive] = c.ImVec4(0.30, 0.30, 0.30, 1.00)
    c.GetStyle().Colors[c.Col.TabUnfocused] = c.ImVec4(0.07, 0.10, 0.15, 0.97)
    c.GetStyle().Colors[c.Col.TabUnfocusedActive] = c.ImVec4(0.14, 0.26, 0.42, 1.00)
    c.GetStyle().Colors[c.Col.PlotLines] = c.ImVec4(0.61, 0.61, 0.61, 1.00)
    c.GetStyle().Colors[c.Col.PlotLinesHovered] = c.ImVec4(1.00, 0.43, 0.35, 1.00)
    c.GetStyle().Colors[c.Col.PlotHistogram] = c.ImVec4(0.90, 0.70, 0.00, 1.00)
    c.GetStyle().Colors[c.Col.PlotHistogramHovered] = c.ImVec4(1.00, 0.60, 0.00, 1.00)
    c.GetStyle().Colors[c.Col.TextSelectedBg] = c.ImVec4(1.00, 1.00, 1.00, 0.25)
    c.GetStyle().Colors[c.Col.DragDropTarget] = c.ImVec4(1.00, 1.00, 0.00, 0.90)
    c.GetStyle().Colors[c.Col.NavHighlight] = c.ImVec4(0.26, 0.59, 0.98, 1.00)
    c.GetStyle().Colors[c.Col.NavWindowingHighlight] = c.ImVec4(1.00, 1.00, 1.00, 0.70)
    c.GetStyle().Colors[c.Col.NavWindowingDimBg] = c.ImVec4(0.80, 0.80, 0.80, 0.20)
    c.GetStyle().Colors[c.Col.ModalWindowDimBg] = c.ImVec4(0.00, 0.00, 0.00, 0.70)
end; function a.onServerMessage(as, at)
    if at:find("Вам был добавлен предмет '([^']+)'") and as == -65281 and x[0] then
        local a3 = at:match("Вам был добавлен предмет '([^']+)'")
        addResource(a3, 1)
    end; if at:find("что вам выпадет на ферме дополнительный ресурс") and as == -65281 then E = os.time() end
end; function a.onDisplayGameText(au, av, at) if at:match('([%w%-А-Яа-я]+)%s*%+%s*(%d+)') then
        local a5, a6 = at:match('([%w%-А-Яа-я]+)%s*%+%s*(%d+)')
        addResource(a1[a5], a6)
    end end; function a.onShowTextDraw(aw, ax) if ax.modelId == 2219 and G then
        sampSendClickTextdraw(aw)
        sampSendClickTextdraw(2302)
        sampSendClickTextdraw(65535)
        G = false
    end end; function a.onSendClickTextDraw(aw) if aw == 2121 then G = false end end; function onReceivePacket(aw, ay) if aw == 220 then
        local at, az = bitStreamToString(ay)
        if at:match('playerSatiety\'%s*,%s*`%[(%d+)%]`%s*%)') then w = at:match('playerSatiety\'%s*,%s*`%[(%d+)%]`%s*%)') end
    end end; function bitStreamToString(ay)
    local at = ""
    raknetBitStreamIgnoreBits(ay, 8)
    if raknetBitStreamReadInt8(ay) == 17 then
        raknetBitStreamIgnoreBits(ay, 32)
        local aA = raknetBitStreamReadInt16(ay)
        local aB = raknetBitStreamReadInt8(ay)
        at = aB ~= 0 and raknetBitStreamDecodeString(ay, aA + aB) or raknetBitStreamReadString(ay, aA)
    end; return at
end; function formatDates(aC, aD)
    aD = {}
    for aE, aF in ipairs(aC) do
        local aG = tostring(aF):match("_(%d+%-%d+%-%d+)%.json")
        aG = aG:gsub("(%d+)%-(%d+)%-(%d+)", "%3.%2.%1")
        table.insert(aD, aG)
    end; return aD
end; function getCurrentweekLogFiles(aH)
    local aI = os.date("*t")
    local q = os.date("*t", os.time()).wday; local aJ = (q - 2) % 7; local aK = os.time({ year = aI.year, month = aI
    .month, day = aI.day - aJ })
    local aL = aK + 6 * 86400; local W = {}
    for ai, aM in ipairs(aH) do
        local aN = aM:match("_(%d+%-%d+%-%d+)%.json")
        if aN then
            local aO, aP, aQ = aN:match("(%d+)%-(%d+)%-(%d+)")
            local aR = os.time({ year = tonumber(aO), month = tonumber(aP), day = tonumber(aQ) })
            if aR >= aK and aR <= aL then table.insert(W, aM) end
        end
    end; return W
end; function formatCurrency(a8)
    local aS = tostring(a8)
    local aA = #aS; local aT = ""
    local aU = 0; for aE = aA, 1, -1 do
        aT = aS:sub(aE, aE) .. aT; aU = aU + 1; if aU % 3 == 0 and aE ~= 1 then aT = "." .. aT end
    end; return aT .. "$"
end; function reverseArray(aV)
    local aW = {}
    for aE = #aV, 1, -1 do table.insert(aW, aV[aE]) end; return aW
end; function isInArray(a8, aX)
    for ai, aY in ipairs(aX) do if aY == a8 then return true end end; return false
end; function bufferToNumber(aZ)
    local aS = d.string(aZ)
    aS = aS:gsub("[^%d]", "")
    return tonumber(aS) or 0
end; function numberToBuffer(a_)
    local aS = tostring(a_)
    return m.char[256](aS)
end; function toRGBVec(b0, b1, b2) return c.ImVec4(b0 / 255, b1 / 255, b2 / 255, 1) end; function chatMessage(b3, ...)
    b3 = ("[" .. l .. "]" .. "{EEEEEE} " .. b3):format(...)
    return sampAddChatMessage(b3, 0xff0f69a8)
end; d.cdef [[
    int CreateDirectoryA(const char *lpPathName, void *lpSecurityAttributes);
]]
local function b4()
    local b5 = d.new("char[?]", #p + 1)
    d.copy(b5, p)
    local b6 = d.C.CreateDirectoryA(b5, nil)
end; function getLogFiles()
    R = {}
    for aM in e.dir(p) do if aM:match("%.json$") then table.insert(R, aM) end end
end; function loadLogResources(U)
    local aM = io.open(p .. "/" .. U, "r")
    if aM then
        local ax = aM:read("*a")
        T = g.decode(ax)
        aM:close()
    end
end; function loadLogFilesByNames(b7)
    local a0 = { count = 0, log = {} }
    for aE, U in ipairs(b7) do
        local aM = io.open(p .. "/" .. U, "r")
        if aM then
            local ax = aM:read("*a")
            local b8 = g.decode(ax)
            aM:close()
            if b8["Добыто ресурсов"] ~= 0 then
                a0.count = a0.count + 1; for a5, a6 in pairs(b8) do
                    if not a0.log[a5] then a0.log[a5] = 0 end; a0.log[a5] = a0.log[a5] + a6
                end
            end
        end
    end; return a0
end; function loadResources()
    b4()
    local aM = io.open(r, "r")
    if aM then
        local ax = aM:read("*a")
        a0 = g.decode(ax)
        aM:close()
    else
        for a5, a6 in pairs(a0) do a0[a5] = 0 end; saveResources()
    end
end; function saveResources()
    b4()
    a0["Общая стоимость"] = calcTotalEarning(a0, s.prices)
    local aM = io.open(r, "w")
    if aM then
        aM:write(g.encode(a0))
        aM:close()
    end
end; function setBinds() O = { Eat = { keys = decodeJson(s.hotkey.eatKey), callback = function() if x[0] and I[0] and not sampIsChatInputActive() and not sampIsDialogActive() then if H[0] then
                sampSendChat("/invent")
                G = true
            else sampSendChat(s.settings.eatMethod) end end end }, Drugs = { keys = decodeJson(s.hotkey.drugsKey), callback = function() if x[0] and I[0] and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat(s.settings.healMethod) end end }, Beer = { keys = decodeJson(s.hotkey.beerKey), callback = function() if x[0] and I[0] and not sampIsChatInputActive() and not sampIsDialogActive() then
            sampSendChat("/beer") end end } } end
