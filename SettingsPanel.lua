local addonName, addon = ...

local _G = _G

local AceConfig = LibStub("AceConfig-3.0")

local importString = ""
local previousFrame = 0
local buffer = {}
local importFrame
local ProcessBuffer

addon.settings = addon:NewModule("Settings", "AceConsole-3.0")

if not addon.settings.gui then addon.settings.gui = {selectedDeleteGuide = ""} end
if not addon.settings.extras then addon.settings.extras = {} end

function addon.settings.ChatCommand(input)
    if not input then
        _G.InterfaceOptionsFrame_OpenToCategory(addon.RXPOptions)
        _G.InterfaceOptionsFrame_OpenToCategory(addon.RXPOptions)
    end

    input = input:trim()
    if input == "import" then
        _G.InterfaceOptionsFrame_OpenToCategory(addon.settings.gui.import)
        _G.InterfaceOptionsFrame_OpenToCategory(addon.settings.gui.import)
    elseif input == "extras" then
        _G.InterfaceOptionsFrame_OpenToCategory(addon.settings.gui.extras)
        _G.InterfaceOptionsFrame_OpenToCategory(addon.settings.gui.extras)
    elseif input == "debug" then
        addon.settings.db.profile.debug = not addon.settings.db.profile.debug

        if addon.settings.db.profile.debug then
            _G.InterfaceOptionsFrame_OpenToCategory(addon.settings.gui.extras)
            _G.InterfaceOptionsFrame_OpenToCategory(addon.settings.gui.extras)
        end
    elseif input == "beta" then
        addon.settings.db.profile.enableBetaFeatures = not addon.settings.db.profile.enableBetaFeatures

        if addon.settings.db.profile.enableBetaFeatures then
            _G.InterfaceOptionsFrame_OpenToCategory(addon.settings.gui.extras)
            _G.InterfaceOptionsFrame_OpenToCategory(addon.settings.gui.extras)
        end
    else
        _G.InterfaceOptionsFrame_OpenToCategory(addon.RXPOptions)
        _G.InterfaceOptionsFrame_OpenToCategory(addon.RXPOptions)
    end
end

function addon.settings:InitializeSettings()
    -- New character settings format
    -- Only set defaults for enabled = true
    local settingsDBDefaults = {
        profile = {
            enableTracker = true,
            enableTrackerReport = true,
            enableLevelUpAnnounceSolo = true,
            enableLevelUpAnnounceGroup = true,
            openTrackerReportOnCharOpen = true,
            enableFlyStepAnnouncements = true,
            alwaysSendBranded = true,
            checkVersions = true
        }
    }

    self.db = LibStub("AceDB-3.0"):New("RXPCSettings",
                                                 settingsDBDefaults)

    self.CreateOptionsPanel()
    self.CreateImportOptionsPanel()
    self.CreateExtrasOptionsPanel()

    self:RegisterChatCommand("rxp", self.ChatCommand)
    self:RegisterChatCommand("rxpg", self.ChatCommand)
    self:RegisterChatCommand("rxpguides", self.ChatCommand)
end

local function GetProfileOption(info)
    return addon.settings.db.profile[info[#info]]
end

local function SetProfileOption(info, value)
    addon.settings.db.profile[info[#info]] = value
end


function addon.settings.CreateOptionsPanel()
    addon.RXPOptions = CreateFrame("Frame", "RXPOptions")
    addon.RXPOptions.name = "RXP Guides"
    _G.InterfaceOptions_AddCategory(addon.RXPOptions)

    addon.RXPOptions.title = addon.RXPOptions:CreateFontString(nil, "ARTWORK",
                                                               "GameFontNormalLarge")
    addon.RXPOptions.title:SetPoint("TOPLEFT", 16, -16)
    addon.RXPOptions.title:SetText("RestedXP Guides")

    addon.RXPOptions.subtext = addon.RXPOptions:CreateFontString(nil, "ARTWORK",
                                                                 "GameFontHighlightSmall")
    addon.RXPOptions.subtext:SetPoint("TOPLEFT", addon.RXPOptions.title,
                                      "BOTTOMLEFT", 0, -8)
    addon.RXPOptions.subtext:SetText(addon.versionText)

    addon.RXPOptions.icon = addon.RXPOptions:CreateTexture()
    addon.RXPOptions.icon:SetTexture("Interface/AddOns/" .. addonName ..
                                         "/Textures/rxp_logo-64")
    addon.RXPOptions.icon:SetPoint("TOPRIGHT", -5, -5)

    -- panel.icon:SetSize(64,64)
    local index = 0
    local options = {}
    local button = CreateFrame("CheckButton", "$parentQuestTurnIn",
                               addon.RXPOptions, "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    index = index + 1
    button:SetPoint("TOPLEFT", addon.RXPOptions.title, "BOTTOMLEFT", 0, -25)
    button:SetScript("PostClick", function(self)
        RXPData.disableQuestAutomation = not self:GetChecked()
    end)
    button:SetChecked(not RXPData.disableQuestAutomation)
    button.Text:SetText("Quest auto accept/turn in")
    button.tooltip =
        "Holding the Control key modifier also toggles the quest the quest auto accept feature on and off"

    button = CreateFrame("CheckButton", "$parentTrainer", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        RXPData.disableTrainerAutomation = not self:GetChecked()
    end)
    button:SetChecked(not RXPData.disableTrainerAutomation)
    button.Text:SetText("Trainer automation")
    button.tooltip =
        "Allows the guide to buy useful leveling spells automatically"

    button = CreateFrame("CheckButton", "$parentFP", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        RXPData.disableFPAutomation = not self:GetChecked()
    end)
    button:SetChecked(not RXPData.disableFPAutomation)
    button.Text:SetText("Flight Path automation")
    button.tooltip =
        "Allows the guide to automatically fly you to your destination"

    button = CreateFrame("CheckButton", "$parentArrow", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        local checkbox = self:GetChecked()
        addon.arrowFrame:SetShown(addon.currentGuide and checkbox)
        RXPData.disableArrow = not checkbox
    end)
    button:SetChecked(not RXPData.disableArrow)
    button.Text:SetText("Enable waypoint arrow")
    button.tooltip = "Show/Hide the waypoint arrow"

    button = CreateFrame("CheckButton", "$parentMiniMapPin", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        RXPData.hideMiniMapPins = self:GetChecked()
        addon.UpdateMap()
    end)
    button:SetChecked(RXPData.hideMiniMapPins)
    button.Text:SetText("Hide Mini Map Pins")
    -- button.tooltip = ""

    button = CreateFrame("CheckButton", "$parentUnusedGuides", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        RXPData.hideUnusedGuides = not self:GetChecked()
        addon.RXPFrame.GenerateMenuTable()
    end)
    button:SetChecked(not RXPData.hideUnusedGuides)
    button.Text:SetText("Show unused guides")
    button.tooltip =
        "Displays guides that are not applicable for your class/race such as starting zones for other races"

    button = CreateFrame("CheckButton", "$parentAutoLoad", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        RXPData.autoLoadGuides = self:GetChecked()
    end)
    button:SetChecked(RXPData.autoLoadGuides)
    button.Text:SetText("Auto load starting zone guides")
    button.tooltip =
        "Automatically picks a suitable guide whenever you log in for the first time on a character"
    --
    button = CreateFrame("CheckButton", "$parentHideWindow", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        local hide = self:GetChecked()
        RXPCData.hideWindow = hide
        addon.RXPFrame:SetShown(not hide)
    end)
    button:SetChecked(RXPCData.hideWindow)
    button.Text:SetText("Hide Window")
    button.tooltip = "Hides the main window"

    button = CreateFrame("CheckButton", "$parentLock", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick",
                     function(self) RXPData.lockFrames = self:GetChecked() end)
    button:SetChecked(RXPData.lockFrames)
    button.Text:SetText("Lock Frames")
    button.tooltip =
        "Disable dragging/resizing, use alt+left click on the main window to resize it"
    --
    button = CreateFrame("CheckButton", "$parentShowUpcoming", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        if addon.currentGuide and addon.currentGuide.hidewindow then
            return
        end
        local show = self:GetChecked()
        if show then
            addon.RXPFrame:SetHeight(addon.height)
            RXPCData.frameHeight = addon.height
        else
            addon.RXPFrame:SetHeight(10)
            RXPCData.frameHeight = 10
        end
        addon.updateBottomFrame = true
    end)
    button:SetChecked(addon.RXPFrame.BottomFrame:GetHeight() >= 35)
    button.Text:SetText("Show step list")
    button.tooltip =
        "Show/Hide the bottom frame listing all the steps of the current guide"
    --
    button = CreateFrame("CheckButton", "$parentHideCompleted",
                         addon.RXPOptions, "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        RXPData.hideCompletedSteps = self:GetChecked()
        addon.RXPFrame.ScrollFrame.ScrollBar:SetValue(0)
    end)
    button:SetChecked(RXPData.hideCompletedSteps)
    button.Text:SetText("Hide completed steps")
    button.tooltip =
        "Only shows current and future steps on the step list window"
    --
    button = CreateFrame("CheckButton", "$parentMapCircle", addon.RXPOptions,
                         "ChatConfigCheckButtonTemplate");
    table.insert(options, button)
    button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
    index = index + 1
    button:SetScript("PostClick", function(self)
        RXPData.mapCircle = self:GetChecked()
        addon.updateMap = true
    end)
    button:SetChecked(RXPData.mapCircle)
    button.Text:SetText("Highlight active map pins")
    button.tooltip = "Show a targeting circle around active map pins"
    --[[
    if QuestieLoader then
        button = CreateFrame("CheckButton", "$parentSkipPreReqs", addon.RXPOptions, "ChatConfigCheckButtonTemplate");
        table.insert(options,button)
        button:SetPoint("TOPLEFT",options[index],"BOTTOMLEFT",0,0)
        index = index + 1
        button:SetScript("PostClick",function(self)
            RXPData.skipMissingPreReqs = self:GetChecked()
        end)
        button:SetChecked(RXPData.skipMissingPreReqs)
        button.Text:SetText("Skip quests with missing pre-requisites")
        button.tooltip = "Automatically skip tasks in which you don't have the required quest pre-requisites\n(Requires Questie)"
    end]]
    --
    if _G.unitscan_targets then
        button = CreateFrame("CheckButton", "$parentUnitscan", addon.RXPOptions,
                             "ChatConfigCheckButtonTemplate");
        table.insert(options, button)
        button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
        index = index + 1
        button:SetScript("PostClick", function(self)
            RXPData.disableUnitscan = not self:GetChecked()
        end)
        button:SetChecked(not RXPData.disableUnitscan)
        button.Text:SetText("Unitscan integration")
        button.tooltip =
            "Automatically adds important npcs to your unitscan list"
    end

    if addon.game == "CLASSIC" then
        button = CreateFrame("CheckButton", "$parentHC", addon.RXPOptions,
                             "ChatConfigCheckButtonTemplate");
        addon.hardcoreButton = button
        table.insert(options, button)
        button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
        index = index + 1
        button:SetScript("PostClick", function(self)
            RXPCData.hardcore = self:GetChecked()
            addon.RenderFrame()
        end)
        button:SetChecked(RXPCData.hardcore)
        button.Text:SetText("Hardcore mode")
        button.tooltip = "Adjust the leveling routes to the deathless ruleset"

        button = CreateFrame("CheckButton", "$parentSoM", addon.RXPOptions,
                             "ChatConfigCheckButtonTemplate");
        table.insert(options, button)
        button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
        index = index + 1
        button:SetScript("PostClick", function(self)
            RXPCData.SoM = self:GetChecked()
            addon.RXPFrame.GenerateMenuTable()
            addon.ReloadGuide()
        end)
        button:SetChecked(RXPCData.SoM)
        button.Text:SetText("Season of Mastery")
        button.tooltip =
            "Adjust the leveling routes to the Season of Mastery changes (40/100% quest xp)"
    elseif addon.gameVersion > 30000 then
        button = CreateFrame("CheckButton", "$parentNorthrendLM",
                             addon.RXPOptions, "ChatConfigCheckButtonTemplate");
        table.insert(options, button)
        button:SetPoint("TOPLEFT", options[index], "BOTTOMLEFT", 0, 0)
        index = index + 1
        button:SetScript("PostClick", function(self)
            RXPCData.northrendLM = self:GetChecked()
            addon.ReloadGuide()
        end)
        button:SetChecked(RXPCData.northrendLM)
        button.Text:SetText("Northrend Loremaster")
        button.tooltip =
            "Adjust the routes to include almost every quest in the Northrend zones"
    end

    local SliderUpdate = function(self, value)
        self.ref[self.key] = value
        local updateFunc = self.updateFunc or string.format
        self.Text:SetText(updateFunc(self.defaultText, value))
        addon.RXPFrame:SetScale(RXPData.windowSize)
        local size = RXPData.arrowSize
        addon.arrowFrame:SetSize(32 * size, 32 * size)
        addon.arrowFrame.text:SetFont(addon.font, RXPData.arrowText)
        RXPData.numMapPins = math.floor(RXPData.numMapPins)
        addon.updateMap = true
        if (self.key == "phase" or self.key == "xprate") and addon.currentGuide then
            addon.ReloadGuide()
            addon.RXPFrame.GenerateMenuTable()
        end
        addon.RXPFrame.SetStepFrameAnchor()
    end

    local CreateSlider = function(ref, key, smin, smax, text, tooltip, anchor,
                                  x, y, steps, minText, maxText, updateFunc)
        local slider, dvalue

        slider = CreateFrame("Slider", "$parentArrowSlider", addon.RXPOptions,
                             "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", x, y)
        slider:SetOrientation('HORIZONTAL')
        if steps then
            slider:SetValueStep(steps)
            slider:SetStepsPerPage(steps)
            slider:SetObeyStepOnDrag(true)
        end
        slider:SetThumbTexture(
            "Interface/Buttons/UI-SliderBar-Button-Horizontal")
        slider.ref = ref
        slider.key = key
        dvalue = ref[key] or smin

        slider.defaultText = text
        slider.tooltipText = tooltip
        slider:SetScript("OnValueChanged", SliderUpdate)

        slider:SetMinMaxValues(smin, smax)
        SliderUpdate(slider, dvalue)
        slider:SetValue(dvalue)

        slider.Low:SetText(minText or tostring(smin));
        slider.High:SetText(maxText or tostring(smax));

        slider.updateFunc = updateFunc

        return slider
    end
    local slider
    slider = CreateSlider(RXPData, "arrowSize", 0.2, 2, "Arrow Scale: %.2f",
                          "Scale of the Waypoint Arrow", addon.RXPOptions.title,
                          315, -25, 0.05)
    slider = CreateSlider(RXPData, "arrowText", 5, 20, "Arrow Text Size: %d",
                          "Size of the waypoint arrow text", slider, 0, -25, 1)
    slider = CreateSlider(RXPData, "windowSize", 0.2, 2, "Window Scale: %.2f",
                          "Scale of the Main Window, use alt+left click on the main window to resize it",
                          slider, 0, -25, 0.05)
    slider = CreateSlider(RXPData, "numMapPins", 1, 20,
                          "Number of Map Pins: %d",
                          "Number of map pins shown on the world map", slider,
                          0, -25, 1, "1", "20")
    slider = CreateSlider(RXPData, "worldMapPinScale", 0.05, 1,
                          "Map Pin Scale: %.2f",
                          "Adjusts the size of the world map pins", slider, 0,
                          -25, 0.05, "0.05", "1")
    slider = CreateSlider(RXPData, "distanceBetweenPins", 0.05, 2,
                          "Distance Between Pins: %.2f",
                          "If two or more steps are very close together, this addon will group them into a single pin on the map. Adjust this range to determine how close together two steps must be to form a group.",
                          slider, 0, -25, 0.05, "0.05", "2")
    slider = CreateSlider(RXPData, "worldMapPinBackgroundOpacity", 0, 1,
                          "Map Pin Background Opacity: %.2f",
                          "The opacity of the black circles on the map and mini map",
                          slider, 0, -25, 0.05, "0", "1")
    slider = CreateSlider(RXPData, "anchorOrientation", -1, 1,
                          "Current step frame anchor",
                          "Sets the current step frame to grow from bottom to top or top to bottom by default",
                          slider, 0, -25, 2, "Bottom", "Top")

    slider = CreateSlider(RXPData, "batchSize", 1, 100,
                          "Batching window size: %d ms",
                          "Adjusts the batching window tolerance, used for hearthstone batching",
                          slider, 0, -25, 1, "1", "100")

    if addon.game == "CLASSIC" then
        slider = CreateSlider(RXPCData, "phase", 1, 6, "Content phase: %d",
                              "Adjusts the guide routes to match the content phase\nPhase 2: Dire Maul quests\nPhase 3: 100% quest XP (SoM)\nPhase 4: ZG/Silithus quests\nPhase 5: AQ quests\nPhase 6: Eastern Plaguelands quests",
                              slider, 0, -25, 1, "1", "6")
    elseif addon.gameVersion < 40000 then
        slider = CreateSlider(RXPCData, "xprate", 1, 1.5,
                              "Experience rates: %.1fx",
                              "Adjusts the guide routes to match increased xp rate bonuses",
                              slider, 0, -25, 0.5, "1x", "1.5x")
    end
    --[[
    if addon.farmGuides > 0 then
        local GApanel = CreateFrame("Frame", "RXPGAOptions")
        GApanel.name = "Gold Assistant"
        GApanel.parent = "RXP Guides"
        _G.InterfaceOptions_AddCategory(GApanel)

        GApanel.title = GApanel:CreateFontString(nil, "ARTWORK",
                                                 "GameFontNormalLarge")
        GApanel.title:SetPoint("TOPLEFT", 16, -16)
        GApanel.title:SetText("RestedXP Gold Assistant")

        GApanel.subtext = GApanel:CreateFontString(nil, "ARTWORK",
                                                   "GameFontHighlightSmall")
        GApanel.subtext:SetPoint("TOPLEFT", GApanel.title, "BOTTOMLEFT", 0, -8)
        GApanel.subtext:SetText(addon.versionText)

        GApanel.icon = GApanel:CreateTexture()
        GApanel.icon:SetTexture("Interface/AddOns/" .. addonName ..
                                    "/Textures/rxp_logo-64")
        GApanel.icon:SetPoint("TOPRIGHT", -5, -5)

    end]]

end

function addon.settings.ImportBoxValidate()

    local guidesLoaded, errorMsg = addon.RXPG.ImportString(importString,
                                                           addon.RXPFrame)
    if guidesLoaded then
        addon.settings.gui.selectedDeleteGuide = "mustReload"
        return true
    else
        local relog = ""
        if not RXPData.cache then
            relog = "\nPlease restart your game client and try again"
        end
        importFrame.textFrame:SetScript('OnUpdate', ProcessBuffer)
        return errorMsg or ("Failed to Import Guides: Invalid Import String" .. relog)
    end
end

function addon.settings.GetImportedGuides()
    local display = {empty = ""}
    local importedGuidesFound = false

    if addon.settings.gui.selectedDeleteGuide == "mustReload" then
        return {mustReload = "Must reload UI"}
    end

    for _, guide in ipairs(addon.guides) do
        if guide.imported or guide.cache then
            importedGuidesFound = true
            local group, subgroup, name = guide.key:match("^(.*)|(.*)|(.*)")
            if subgroup ~= "" then group = group .. "/" .. subgroup end
            display[guide.key] = string.format("%s/%s - version %s", group,
                                               name, guide.version)
        end
    end

    table.sort(display)

    if importedGuidesFound then
        return display
    else
        addon.settings.gui.selectedDeleteGuide = "none"
        return {none = "none"}
    end

end

function addon.settings.CreateImportOptionsPanel()
    local importOptionsTable = {
        type = "group",
        name = "RestedXP Guide Import",
        handler = addon.settings,
        args = {
            buffer = { -- Buffer hacked in right-aligned icon
                order = 1,
                name = "Paste encoded strings",
                type = "description",
                width = "full",
                fontSize = "medium",

            },
            importBox = {
                order = 10,
                type = 'input',
                name = 'Guides to import',
                width = "full",
                multiline = 5,
                validate = function(_, val)
                    return addon.settings.ImportBoxValidate(val)
                end
            },
            currentGuides = {
                order = 11,
                type = 'select',
                style = 'dropdown',
                name = "Currently loaded imported guides",
                width = 'full',
                values = function()
                    return addon.settings.GetImportedGuides()
                end,
                disabled = function()
                    return addon.settings.gui.selectedDeleteGuide ==
                               "mustReload" or
                               addon.settings.gui.selectedDeleteGuide == "none" or
                               not addon.settings.gui.selectedDeleteGuide
                end,
                get = function()
                    return addon.settings.gui.selectedDeleteGuide
                end,
                set = function(_, value)
                    addon.settings.gui.selectedDeleteGuide = value
                end
            },
            deleteSelectedGuide = {
                order = 12,
                type = 'execute',
                name = "Delete imported guide",
                confirm = function(_, key)
                    if not addon.settings.gui.selectedDeleteGuide or
                        addon.settings.gui.selectedDeleteGuide == "none" then
                        return false
                    end
                    return string.format("Remove %s?",
                                         addon.settings.gui.selectedDeleteGuide)
                end,
                disabled = function()
                    return addon.settings.gui.selectedDeleteGuide ==
                               "mustReload" or
                               addon.settings.gui.selectedDeleteGuide == "none" or
                               not addon.settings.gui.selectedDeleteGuide
                end,
                func = function(_)
                    if addon.db.profile.guides[addon.settings.gui
                        .selectedDeleteGuide] then
                        addon.db.profile.guides[addon.settings.gui
                            .selectedDeleteGuide] = nil
                    end

                    addon.settings.gui.selectedDeleteGuide = "mustReload"
                end
            },
            purge = {
                order = 13,
                type = 'execute',
                name = "Purge All Data",
                confirm = function(_, key)
                    return string.format("This action will remove ALL guides from the database\nAre you sure?")
                end,
                disabled = function()
                    return addon.settings.gui.selectedDeleteGuide ==
                               "mustReload"
                end,
                func = function(_)
                    addon.db.profile.guides = {}
                    addon.settings.gui.selectedDeleteGuide = "mustReload"
                end
            },
            reloadGuides = {
                order = 14,
                name = "Reload guides and UI",
                type = 'execute',
                func = function() _G.ReloadUI() end,
                disabled = function()
                    return addon.settings.gui.selectedDeleteGuide ~=
                               "mustReload"
                end
            },
        }
    }

    AceConfig:RegisterOptionsTable("RXP Guides/Import", importOptionsTable)

    addon.settings.gui.import = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
                                    "RXP Guides/Import", "Import", "RXP Guides")

    -- Ace3 ConfigDialog doesn't support embedding icons in header
    -- Directly references Ace3 built frame object
    -- Hackery ahead

    importFrame = addon.settings.gui.import.obj.frame
    importFrame.icon = importFrame:CreateTexture()
    importFrame.icon:SetTexture("Interface\\AddOns\\" .. addonName ..
                                    "\\Textures\\rxp_logo-64")
    importFrame.icon:SetPoint("TOPRIGHT", -5, -5)

    importFrame.text = importFrame:CreateFontString(nil, "OVERLAY")
    importFrame.text:ClearAllPoints()
    importFrame.text:SetPoint("CENTER", importFrame, 1, 1)
    importFrame.text:SetJustifyH("LEFT")
    importFrame.text:SetJustifyV("CENTER")
    importFrame.text:SetTextColor(1, 1, 1)
    importFrame.text:SetFont(addon.font, 14)
    importFrame.text:SetText("")
    addon.RXPG.LoadText = importFrame.text


    local function EditBoxHook(self)
        if importFrame:IsShown() then
            self.isMaxBytesSet = true
            self:SetMaxBytes(1)
        elseif self.isMaxBytesSet then
            self.isMaxBytesSet = false
            self:SetMaxBytes(0)
        end
    end

    function ProcessBuffer(self)
        self:SetScript('OnUpdate', nil)
        self = importFrame.textFrame
        if #buffer > 16 then
            importString = table.concat(buffer)
            self:ClearHistory()
            self:SetMaxBytes(0)
            self:Insert(importString:sub(1, 500))
            self:ClearFocus()
            buffer = {}
        else
            -- self:ClearHistory()
            self:SetText(" ")
            self:SetMaxBytes(1)
        end
    end

    local function PasteHook(self, char)
        if not importFrame:IsShown() then return end

        local time = GetTime()
        if previousFrame ~= time then
            previousFrame = time
            importFrame.textFrame = self
            importFrame:SetScript('OnUpdate', ProcessBuffer)
        end

        table.insert(buffer, char)
    end

    local isHooked = {}

    importFrame:HookScript("OnShow", function(self)
        local n = 1
        local editBox = true

        while editBox do
            -- editBox = _G["AceGUI-3.0EditBox" .. n]
            editBox = _G["MultiLineEditBox" .. n .. "ScrollFrame"]
            if not isHooked[n] and editBox then
                editBox = editBox.obj.editBox
                isHooked[n] = true
                editBox:HookScript("OnEditFocusGained", EditBoxHook)
                editBox:HookScript("OnChar", PasteHook)
            end
            n = n + 1
        end
    end)

end

function addon.settings.CreateExtrasOptionsPanel()
    local extraOptionsTable = {
        type = "group",
        name = "RestedXP Extras",
        get = GetProfileOption,
        set = SetProfileOption,
        childGroups = "tab",
        args = {
            buffer = { -- Buffer hacked in right-aligned icon
                order = 1,
                name = "Optional extras",
                type = "description",
                width = "full",
                fontSize = "medium"
            },
            levelingTracker = {
                type = "group",
                name = "Leveling Tracker",
                order = 2,
                args = {
                    trackerOptionsHeader = {
                        name = "Leveling Tracker",
                        type = "header",
                        width = "full",
                        order = 1
                    },
                    enableTracker = {
                        name = "Track Leveling Data",
                        type = "toggle",
                        width = "full",
                        order = 2
                    },
                    enableTrackerReport = {
                        name = "Enable Leveling Report",
                        type = "toggle",
                        width = "full",
                        order = 3
                    }, -- TODO add reload UI if changes made
                    openTrackerReportOnCharOpen = {
                        name = "Always Open Leveling Report With Character Panel",
                        type = "toggle",
                        width = "full",
                        order = 4
                    },
                },
            },
            communications = {
                type = "group",
                name = "Communications",
                order = 3,
                args = {
                    commsLevelUpOptionsHeader = {
                        name = "Announcements",
                        type = "header",
                        width = "full",
                        order = 1
                    },
                    enableLevelUpAnnounceSolo = {
                        name = "Announce Level Ups (Emote)",
                        type = "toggle",
                        width = "full",
                        order = 6
                    },
                    enableLevelUpAnnounceGroup = {
                        name = "Announce Level Ups (Party Chat)",
                        type = "toggle",
                        width = "full",
                        order = 7
                    },
                    enableLevelUpAnnounceGuild = {
                        name = "Announce Level Ups (Guild Chat)",
                        type = "toggle",
                        width = "full",
                        order = 8
                    },
                    groupCoordinationHeader = {
                        name = "Group coordination",
                        type = "header",
                        width = "full",
                        order = 9
                    },
                    alwaysSendBranded = {
                        name = "Send announcements without another RXP user in group",
                        type = "toggle",
                        width = "full",
                        order = 10
                    },
                    enableCompleteStepAnnouncements = {
                        name = "Announce when Quest Step is completed",
                        type = "toggle",
                        width = "full",
                        order = 11
                    },
                    enableCollectStepAnnouncements = {
                        name = "Announce when all Step items are Collected",
                        type = "toggle",
                        width = "full",
                        order = 12
                    },
                    enableFlyStepAnnouncements = {
                        name = "Announce Flying Step timers",
                        type = "toggle",
                        width = "full",
                        order = 13
                    },
                    checkVersions = {
                        name = "Enable Addon Version Checks",
                        desc = "Advertises and compares addon versions with all RXP users in party",
                        type = "toggle",
                        width = "full",
                        order = 14,
                    },
                    ignoreQuestieConflicts = {
                        name = "Ignore Questie announcements",
                        type = "toggle",
                        width = "full",
                        order = 15,
                        hidden = not _G.Questie
                    },
                }
            },
            betaSettings = {
                type = "group",
                name = "Beta Settings",
                order = 4,
                hidden = function ()
                    return addon.release ~= 'Development' or not addon.settings.db.profile.enableBetaFeatures
                end,
                args = {
                    betaFeaturesHeader = {
                        name = "Beta features",
                        type = "header",
                        width = "full",
                        order = 1
                    },
                    enableBetaFeatures = {
                        name = "Enable Beta Features",
                        type = "toggle",
                        width = "full",
                        order = 2,
                    },
                    debug = {
                        name = "Enable Debug",
                        type = "toggle",
                        width = "full",
                        order = 3,
                    },
                }
            }
        }
    }

    AceConfig:RegisterOptionsTable("RXP Guides/Extras", extraOptionsTable)

    addon.settings.gui.extras = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
                                    "RXP Guides/Extras", "Extras", "RXP Guides")

    -- Ace3 ConfigDialog doesn't support embedding icons in header
    -- Directly references Ace3 built frame object
    -- Hackery ahead

    local extrasFrame = addon.settings.gui.extras.obj.frame
    extrasFrame.icon = extrasFrame:CreateTexture()
    extrasFrame.icon:SetTexture("Interface\\AddOns\\" .. addonName ..
                                    "\\Textures\\rxp_logo-64")
    extrasFrame.icon:SetPoint("TOPRIGHT", -5, -5)

end
