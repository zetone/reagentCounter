	-------------------------------------------------------------------------------
	local RCTooltip = CreateFrame("GameTooltip","RCTooltip",UIParent,"GameTooltipTemplate")
	RCTooltip:SetOwner(UIParent,"ANCHOR_NONE")
	
	resourceList = {}
	local reagentsString, emptyreagentsString = 'Reagents: (.+)', 'Reagents: |cffff2020(.+)|r'
	
	local actionBarNames = {'Action', 'BonusAction', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarLeft', 'MultiBarRight'}
	local actionButtonListRef = {}
	-------------------------------------------------------------------------------
	local function addText(this)
		this.text = this:CreateFontString(nil, 'ARTWORK', 'NumberFontNormal')
		this.text:SetTextColor(1, 1, 1)
		this.text:SetPoint('BOTTOMRIGHT', this, 'BOTTOMRIGHT', -2, 2)
		
		table.insert(actionButtonListRef, this:GetName())
	end
	-------------------------------------------------------------------------------
	-- add fontstring to all buttons
	for k, v in pairs(actionBarNames) do
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			addText(getglobal(v..'Button'..i))
		end
	end
	-------------------------------------------------------------------------------
	--local orig = {}
	local function RingMenu()
		--RCRingMenuFrame_ConfigureButtons = RingMenuFrame_ConfigureButtons
        --function --RingMenuFrame_ConfigureButtons()
           -- RCRingMenuFrame_ConfigureButtons()
			for i = 1, 24 do--RingMenu_settings.numButtons do
				if getglobal('RingMenuButton'..i) then 	addText(getglobal('RingMenuButton'..i))
				else return
				end
			end
		--end
	end	
	
	function bongosActionButtons()
		for i = 1, 120 do
			local bu = getglobal('BActionButton'..i)	
			if bu then 
			addText(bu) 
			else return	 end
		end
	end
	-------------------------------------------------------------------------------
	local function checkActionSlots()
		local lActionSlot = 0;
		resourceList = {}
		for lActionSlot = 1, 120 do--NUM_ACTIONBAR_BUTTONS*NUM_ACTIONBAR_PAGES do
			local lActionText = GetActionText(lActionSlot)
			local lActionTexture = GetActionTexture(lActionSlot)
			if lActionTexture then
				RCTooltip:ClearLines()
				RCTooltip:SetAction(lActionSlot)
				for i=1, RCTooltip:NumLines() do
					local rText = _G['RCTooltipTextLeft'..i]:GetText()
					local rs, ers = string.find(rText, reagentsString), string.find(rText, emptyreagentsString)
					if  rText and ( rs or ers )then
						local out = ers and gsub(rText, emptyreagentsString, '%1') or gsub(rText, reagentsString, '%1')
						resourceList[lActionSlot] = out
					end
				end
			end
		end
	end
	-------------------------------------------------------------------------------
	function getItemCount(itemName)
		local ct = 0
		for bag = 0, NUM_BAG_SLOTS do
			for slot = 0, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if(link) then
					local _,_,name = string.find(link, "^.*%[(.*)%].*$")
					if name == itemName then
						local _,itemCount = GetContainerItemInfo(bag, slot)
						ct = ct + itemCount
					end
				end
			end
		end		
		return ct
	end
	-------------------------------------------------------------------------------
	local function updateTexts()
		for k, v in pairs(actionButtonListRef) do
			local bu = getglobal(v)
			local id = ActionButton_GetPagedID(bu)
			bu.text:SetText(resourceList[id] and getItemCount(resourceList[id]) or '')
		end
	end
	-------------------------------------------------------------------------------
	local function eventHandler()
		if event == 'ADDON_LOADED' then
			-- bongos
			if arg1 == 'Bongos_ActionBar' then 	bongosActionButtons() 	end
			-- ringmenu
			if arg1 == 'RingMenu' then			RingMenu()			    end
		elseif event == 'PLAYER_LOGIN' then
			-- bongos
			if IsAddOnLoaded'Bongos_ActionBar' then 	bongosActionButtons() 	end
			-- ringmenu
			if IsAddOnLoaded'RingMenu' then				RingMenu()			    end
			--
			checkActionSlots()
			updateTexts()
		elseif event == 'ACTIONBAR_SLOT_CHANGED' then
			checkActionSlots()
			updateTexts()
		else
			updateTexts()
		end
	end
	-------------------------------------------------------------------------------
	local f = CreateFrame'Frame'
	f:RegisterEvent'ADDON_LOADED'
	f:RegisterEvent'PLAYER_LOGIN'
	f:RegisterEvent'BAG_UPDATE'
	f:RegisterEvent'ACTIONBAR_PAGE_CHANGED'
	f:RegisterEvent'ACTIONBAR_SLOT_CHANGED'

	f:SetScript('OnEvent', eventHandler)
	-------------------------------------------------------------------------------