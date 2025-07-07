-- ==============================================================================
--
--  Roland D-05 Comprehensive Ctrlr Panel Script (v2 - Complete Generation)
--
-- ==============================================================================

-- Core variables
midiDeviceID = 0 -- Default to Channel 1 (0-indexed)
addressMap = {}  -- Will be populated at runtime by populateAddressMap()

-- ==============================================================================
--  CORE FUNCTIONS
-- ==============================================================================

-- Called when the panel is first loaded
function panelLoaded()
    local mod = panel:getModulatorByName("Patch_MIDIDevice")
    if mod then
        midiDeviceID = mod:getModulatorValue()
    end
    console("D-05 Panel Loaded. MIDI Device ID set to: "..(midiDeviceID + 1))

    -- Populate the address map for receiving data from the synth
    populateAddressMap()
    console("Address map populated with " .. table.getn(addressMap) .. " entries.")
end

-- Calculates the standard Roland checksum
function calculateChecksum(bytes)
    local sum = 0
    for i, b in ipairs(bytes) do
        sum = sum + b
    end
    return (128 - (sum % 128)) % 128
end

-- Central function to send a parameter change SysEx message
function sendParameterChange(addr, value)
    local checksum_data = {addr[1], addr[2], addr[3], value}
    local checksum = calculateChecksum(checksum_data)

    local sysex_message = {
        0xF0, 0x41, midiDeviceID, 0x14, 0x12,
        addr[1], addr[2], addr[3],
        value,
        checksum,
        0xF7
    }

    panel:sendMidiMessage(sysex_message)
end

-- Function to request a full patch dump from the D-05 edit buffer
function requestPatchDump()
    local addr = {0x00, 0x00, 0x00}
    local size = {0x00, 0x04, 0x00} -- Requesting 1k block covers the whole temp area
    local checksum = calculateChecksum({addr[1], addr[2], addr[3], size[1], size[2], size[3]})
    local request_message = {
        0xF0, 0x41, midiDeviceID, 0x14, 0x11,
        addr[1], addr[2], addr[3],
        size[1], size[2], size[3],
        checksum, 0xF7
    }
    panel:sendMidiMessage(request_message)
    console("D-05 Patch dump requested.")
end

-- Function to handle incoming MIDI messages for bi-directional updates
function receiveMidiMessage(midiMessage)
    if midiMessage:isSysEx() and midiMessage:getByte(2) == 0x41 and midiMessage:getByte(4) == 0x14 and midiMessage:getByte(5) == 0x12 then
        local addrH = midiMessage:getByte(6)
        local addrM = midiMessage:getByte(7)
        local addrL_start = midiMessage:getByte(8)

        -- Loop through received data bytes and update panel
        for i = 9, midiMessage:getSize() - 2 do
            local value = midiMessage:getByte(i)
            -- Calculate the full address for this byte
            local fullOffset = (addrH * 256 * 256) + (addrM * 256) + addrL_start + (i - 9)
            local h = math.floor(fullOffset / (256*256))
            local m = math.floor((fullOffset % (256*256)) / 256)
            local l = fullOffset % 256
            local addrString = string.format("%02X%02X%02X", h, m, l)

            local modName = addressMap[addrString]
            if modName then
                local mod = panel:getModulatorByName(modName)
                if mod then
                    mod:setValue(value, false) -- Set value without triggering callback
                end
            end
        end
    end
end


-- ==============================================================================
--  GENERATED CALLBACK FUNCTIONS
--  Assign these to the 'LUA modulatorValueChangeCbk' property of each modulator
-- ==============================================================================

--- PARTIAL PARAMETERS (x4)
function UP1_WGPitch_Coarse_Changed(mod, value) sendParameterChange({0x00,0x00,0x00}, value) end
function UP2_WGPitch_Coarse_Changed(mod, value) sendParameterChange({0x00,0x00,0x40}, value) end
function LP1_WGPitch_Coarse_Changed(mod, value) sendParameterChange({0x00,0x01,0x40}, value) end
function LP2_WGPitch_Coarse_Changed(mod, value) sendParameterChange({0x00,0x02,0x00}, value) end
function UP1_WGPitch_Fine_Changed(mod, value) sendParameterChange({0x00,0x00,0x01}, value) end
function UP2_WGPitch_Fine_Changed(mod, value) sendParameterChange({0x00,0x00,0x41}, value) end
function LP1_WGPitch_Fine_Changed(mod, value) sendParameterChange({0x00,0x01,0x41}, value) end
function LP2_WGPitch_Fine_Changed(mod, value) sendParameterChange({0x00,0x02,0x01}, value) end
function UP1_WGPitch_Keyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x02}, value) end
function UP2_WGPitch_Keyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x42}, value) end
function LP1_WGPitch_Keyfollow_Changed(mod, value) sendParameterChange({0x00,0x01,0x42}, value) end
function LP2_WGPitch_Keyfollow_Changed(mod, value) sendParameterChange({0x00,0x02,0x02}, value) end
function UP1_WGMod_LFOMode_Changed(mod, value) sendParameterChange({0x00,0x00,0x03}, value) end
function UP2_WGMod_LFOMode_Changed(mod, value) sendParameterChange({0x00,0x00,0x43}, value) end
function LP1_WGMod_LFOMode_Changed(mod, value) sendParameterChange({0x00,0x01,0x43}, value) end
function LP2_WGMod_LFOMode_Changed(mod, value) sendParameterChange({0x00,0x02,0x03}, value) end
function UP1_WGMod_PENVMode_Changed(mod, value) sendParameterChange({0x00,0x00,0x04}, value) end
function UP2_WGMod_PENVMode_Changed(mod, value) sendParameterChange({0x00,0x00,0x44}, value) end
function LP1_WGMod_PENVMode_Changed(mod, value) sendParameterChange({0x00,0x01,0x44}, value) end
function LP2_WGMod_PENVMode_Changed(mod, value) sendParameterChange({0x00,0x02,0x04}, value) end
function UP1_WGMod_BenderMode_Changed(mod, value) sendParameterChange({0x00,0x00,0x05}, value) end
function UP2_WGMod_BenderMode_Changed(mod, value) sendParameterChange({0x00,0x00,0x45}, value) end
function LP1_WGMod_BenderMode_Changed(mod, value) sendParameterChange({0x00,0x01,0x45}, value) end
function LP2_WGMod_BenderMode_Changed(mod, value) sendParameterChange({0x00,0x02,0x05}, value) end
function UP1_WGForm_WaveformSynth_Changed(mod, value) sendParameterChange({0x00,0x00,0x06}, value) end
function UP2_WGForm_WaveformSynth_Changed(mod, value) sendParameterChange({0x00,0x00,0x46}, value) end
function LP1_WGForm_WaveformSynth_Changed(mod, value) sendParameterChange({0x00,0x01,0x46}, value) end
function LP2_WGForm_WaveformSynth_Changed(mod, value) sendParameterChange({0x00,0x02,0x06}, value) end
function UP1_WGForm_WaveformPCM_Changed(mod, value) sendParameterChange({0x00,0x00,0x07}, value) end
function UP2_WGForm_WaveformPCM_Changed(mod, value) sendParameterChange({0x00,0x00,0x47}, value) end
function LP1_WGForm_WaveformPCM_Changed(mod, value) sendParameterChange({0x00,0x01,0x47}, value) end
function LP2_WGForm_WaveformPCM_Changed(mod, value) sendParameterChange({0x00,0x02,0x07}, value) end
function UP1_WGPW_PulseWidth_Changed(mod, value) sendParameterChange({0x00,0x00,0x08}, value) end
function UP2_WGPW_PulseWidth_Changed(mod, value) sendParameterChange({0x00,0x00,0x48}, value) end
function LP1_WGPW_PulseWidth_Changed(mod, value) sendParameterChange({0x00,0x01,0x48}, value) end
function LP2_WGPW_PulseWidth_Changed(mod, value) sendParameterChange({0x00,0x02,0x08}, value) end
function UP1_WGPW_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x09}, value) end
function UP2_WGPW_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x49}, value) end
function LP1_WGPW_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x01,0x49}, value) end
function LP2_WGPW_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x02,0x09}, value) end
function UP1_WGPW_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x00,0x0A}, value) end
function UP2_WGPW_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x00,0x4A}, value) end
function LP1_WGPW_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x01,0x4A}, value) end
function LP2_WGPW_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x02,0x0A}, value) end
function UP1_WGPW_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x00,0x0B}, value) end
function UP2_WGPW_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x00,0x4B}, value) end
function LP1_WGPW_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x01,0x4B}, value) end
function LP2_WGPW_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x02,0x0B}, value) end
function UP1_WGPW_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x0C}, value) end
function UP2_WGPW_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x4C}, value) end
function LP1_WGPW_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x01,0x4C}, value) end
function LP2_WGPW_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x02,0x0C}, value) end
function UP1_TVF_Cutoff_Changed(mod, value) sendParameterChange({0x00,0x00,0x0D}, value) end
function UP2_TVF_Cutoff_Changed(mod, value) sendParameterChange({0x00,0x00,0x4D}, value) end
function LP1_TVF_Cutoff_Changed(mod, value) sendParameterChange({0x00,0x01,0x4D}, value) end
function LP2_TVF_Cutoff_Changed(mod, value) sendParameterChange({0x00,0x02,0x0D}, value) end
function UP1_TVF_Resonance_Changed(mod, value) sendParameterChange({0x00,0x00,0x0E}, value) end
function UP2_TVF_Resonance_Changed(mod, value) sendParameterChange({0x00,0x00,0x4E}, value) end
function LP1_TVF_Resonance_Changed(mod, value) sendParameterChange({0x00,0x01,0x4E}, value) end
function LP2_TVF_Resonance_Changed(mod, value) sendParameterChange({0x00,0x02,0x0E}, value) end
function UP1_TVF_Keyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x0F}, value) end
function UP2_TVF_Keyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x4F}, value) end
function LP1_TVF_Keyfollow_Changed(mod, value) sendParameterChange({0x00,0x01,0x4F}, value) end
function LP2_TVF_Keyfollow_Changed(mod, value) sendParameterChange({0x00,0x02,0x0F}, value) end
function UP1_TVF_BiasPoint_Changed(mod, value) sendParameterChange({0x00,0x00,0x10}, value) end
function UP2_TVF_BiasPoint_Changed(mod, value) sendParameterChange({0x00,0x00,0x50}, value) end
function LP1_TVF_BiasPoint_Changed(mod, value) sendParameterChange({0x00,0x01,0x50}, value) end
function LP2_TVF_BiasPoint_Changed(mod, value) sendParameterChange({0x00,0x02,0x10}, value) end
function UP1_TVF_BiasLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x11}, value) end
function UP2_TVF_BiasLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x51}, value) end
function LP1_TVF_BiasLevel_Changed(mod, value) sendParameterChange({0x00,0x01,0x51}, value) end
function LP2_TVF_BiasLevel_Changed(mod, value) sendParameterChange({0x00,0x02,0x11}, value) end
function UP1_TVFENV_Depth_Changed(mod, value) sendParameterChange({0x00,0x00,0x12}, value) end
function UP2_TVFENV_Depth_Changed(mod, value) sendParameterChange({0x00,0x00,0x52}, value) end
function LP1_TVFENV_Depth_Changed(mod, value) sendParameterChange({0x00,0x01,0x52}, value) end
function LP2_TVFENV_Depth_Changed(mod, value) sendParameterChange({0x00,0x02,0x12}, value) end
function UP1_TVFENV_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x13}, value) end
function UP2_TVFENV_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x53}, value) end
function LP1_TVFENV_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x01,0x53}, value) end
function LP2_TVFENV_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x02,0x13}, value) end
function UP1_TVFENV_DepthKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x14}, value) end
function UP2_TVFENV_DepthKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x54}, value) end
function LP1_TVFENV_DepthKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x01,0x54}, value) end
function LP2_TVFENV_DepthKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x02,0x14}, value) end
function UP1_TVFENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x15}, value) end
function UP2_TVFENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x55}, value) end
function LP1_TVFENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x01,0x55}, value) end
function LP2_TVFENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x02,0x15}, value) end
function UP1_TVFENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x00,0x16}, value) end
function UP2_TVFENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x00,0x56}, value) end
function LP1_TVFENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x01,0x56}, value) end
function LP2_TVFENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x02,0x16}, value) end
function UP1_TVFENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x00,0x17}, value) end
function UP2_TVFENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x00,0x57}, value) end
function LP1_TVFENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x01,0x57}, value) end
function LP2_TVFENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x02,0x17}, value) end
function UP1_TVFENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x00,0x18}, value) end
function UP2_TVFENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x00,0x58}, value) end
function LP1_TVFENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x01,0x58}, value) end
function LP2_TVFENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x02,0x18}, value) end
function UP1_TVFENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x00,0x19}, value) end
function UP2_TVFENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x00,0x59}, value) end
function LP1_TVFENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x01,0x59}, value) end
function LP2_TVFENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x02,0x19}, value) end
function UP1_TVFENVTime_T5_Changed(mod, value) sendParameterChange({0x00,0x00,0x1A}, value) end
function UP2_TVFENVTime_T5_Changed(mod, value) sendParameterChange({0x00,0x00,0x5A}, value) end
function LP1_TVFENVTime_T5_Changed(mod, value) sendParameterChange({0x00,0x01,0x5A}, value) end
function LP2_TVFENVTime_T5_Changed(mod, value) sendParameterChange({0x00,0x02,0x1A}, value) end
function UP1_TVFENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x00,0x1B}, value) end
function UP2_TVFENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x00,0x5B}, value) end
function LP1_TVFENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x01,0x5B}, value) end
function LP2_TVFENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x02,0x1B}, value) end
function UP1_TVFENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x00,0x1C}, value) end
function UP2_TVFENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x00,0x5C}, value) end
function LP1_TVFENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x01,0x5C}, value) end
function LP2_TVFENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x02,0x1C}, value) end
function UP1_TVFENVLevel_L3_Changed(mod, value) sendParameterChange({0x00,0x00,0x1D}, value) end
function UP2_TVFENVLevel_L3_Changed(mod, value) sendParameterChange({0x00,0x00,0x5D}, value) end
function LP1_TVFENVLevel_L3_Changed(mod, value) sendParameterChange({0x00,0x01,0x5D}, value) end
function LP2_TVFENVLevel_L3_Changed(mod, value) sendParameterChange({0x00,0x02,0x1D}, value) end
function UP1_TVFENVLevel_SustainLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x1E}, value) end
function UP2_TVFENVLevel_SustainLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x5E}, value) end
function LP1_TVFENVLevel_SustainLevel_Changed(mod, value) sendParameterChange({0x00,0x01,0x5E}, value) end
function LP2_TVFENVLevel_SustainLevel_Changed(mod, value) sendParameterChange({0x00,0x02,0x1E}, value) end
function UP1_TVFENVLevel_EndLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x1F}, value) end
function UP2_TVFENVLevel_EndLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x5F}, value) end
function LP1_TVFENVLevel_EndLevel_Changed(mod, value) sendParameterChange({0x00,0x01,0x5F}, value) end
function LP2_TVFENVLevel_EndLevel_Changed(mod, value) sendParameterChange({0x00,0x02,0x1F}, value) end
function UP1_TVFMOD_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x00,0x20}, value) end
function UP2_TVFMOD_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x00,0x60}, value) end
function LP1_TVFMOD_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x01,0x60}, value) end
function LP2_TVFMOD_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x02,0x20}, value) end
function UP1_TVFMOD_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x00,0x21}, value) end
function UP2_TVFMOD_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x00,0x61}, value) end
function LP1_TVFMOD_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x01,0x61}, value) end
function LP2_TVFMOD_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x02,0x21}, value) end
function UP1_TVFMOD_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x22}, value) end
function UP2_TVFMOD_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x62}, value) end
function LP1_TVFMOD_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x01,0x62}, value) end
function LP2_TVFMOD_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x02,0x22}, value) end
function UP1_TVA_Level_Changed(mod, value) sendParameterChange({0x00,0x00,0x23}, value) end
function UP2_TVA_Level_Changed(mod, value) sendParameterChange({0x00,0x00,0x63}, value) end
function LP1_TVA_Level_Changed(mod, value) sendParameterChange({0x00,0x01,0x63}, value) end
function LP2_TVA_Level_Changed(mod, value) sendParameterChange({0x00,0x02,0x23}, value) end
function UP1_TVA_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x24}, value) end
function UP2_TVA_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x64}, value) end
function LP1_TVA_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x01,0x64}, value) end
function LP2_TVA_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x02,0x24}, value) end
function UP1_TVA_BiasPoint_Changed(mod, value) sendParameterChange({0x00,0x00,0x25}, value) end
function UP2_TVA_BiasPoint_Changed(mod, value) sendParameterChange({0x00,0x00,0x65}, value) end
function LP1_TVA_BiasPoint_Changed(mod, value) sendParameterChange({0x00,0x01,0x65}, value) end
function LP2_TVA_BiasPoint_Changed(mod, value) sendParameterChange({0x00,0x02,0x25}, value) end
function UP1_TVA_BiasLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x26}, value) end
function UP2_TVA_BiasLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x66}, value) end
function LP1_TVA_BiasLevel_Changed(mod, value) sendParameterChange({0x00,0x01,0x66}, value) end
function LP2_TVA_BiasLevel_Changed(mod, value) sendParameterChange({0x00,0x02,0x26}, value) end
function UP1_TVAENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x00,0x27}, value) end
function UP2_TVAENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x00,0x67}, value) end
function LP1_TVAENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x01,0x67}, value) end
function LP2_TVAENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x02,0x27}, value) end
function UP1_TVAENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x00,0x28}, value) end
function UP2_TVAENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x00,0x68}, value) end
function LP1_TVAENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x01,0x68}, value) end
function LP2_TVAENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x02,0x28}, value) end
function UP1_TVAENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x00,0x29}, value) end
function UP2_TVAENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x00,0x69}, value) end
function LP1_TVAENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x01,0x69}, value) end
function LP2_TVAENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x02,0x29}, value) end
function UP1_TVAENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x00,0x2A}, value) end
function UP2_TVAENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x00,0x6A}, value) end
function LP1_TVAENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x01,0x6A}, value) end
function LP2_TVAENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x02,0x2A}, value) end
function UP1_TVAENVTime_T5_Changed(mod, value) sendParameterChange({0x00,0x00,0x2B}, value) end
function UP2_TVAENVTime_T5_Changed(mod, value) sendParameterChange({0x00,0x00,0x6B}, value) end
function LP1_TVAENVTime_T5_Changed(mod, value) sendParameterChange({0x00,0x01,0x6B}, value) end
function LP2_TVAENVTime_T5_Changed(mod, value) sendParameterChange({0x00,0x02,0x2B}, value) end
function UP1_TVAENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x00,0x2C}, value) end
function UP2_TVAENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x00,0x6C}, value) end
function LP1_TVAENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x01,0x6C}, value) end
function LP2_TVAENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x02,0x2C}, value) end
function UP1_TVAENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x00,0x2D}, value) end
function UP2_TVAENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x00,0x6D}, value) end
function LP1_TVAENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x01,0x6D}, value) end
function LP2_TVAENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x02,0x2D}, value) end
function UP1_TVAENVLevel_L3_Changed(mod, value) sendParameterChange({0x00,0x00,0x2E}, value) end
function UP2_TVAENVLevel_L3_Changed(mod, value) sendParameterChange({0x00,0x00,0x6E}, value) end
function LP1_TVAENVLevel_L3_Changed(mod, value) sendParameterChange({0x00,0x01,0x6E}, value) end
function LP2_TVAENVLevel_L3_Changed(mod, value) sendParameterChange({0x00,0x02,0x2E}, value) end
function UP1_TVAENVLevel_SustainLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x2F}, value) end
function UP2_TVAENVLevel_SustainLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x6F}, value) end
function LP1_TVAENVLevel_SustainLevel_Changed(mod, value) sendParameterChange({0x00,0x01,0x6F}, value) end
function LP2_TVAENVLevel_SustainLevel_Changed(mod, value) sendParameterChange({0x00,0x02,0x2F}, value) end
function UP1_TVAENVLevel_EndLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x30}, value) end
function UP2_TVAENVLevel_EndLevel_Changed(mod, value) sendParameterChange({0x00,0x00,0x70}, value) end
function LP1_TVAENVLevel_EndLevel_Changed(mod, value) sendParameterChange({0x00,0x01,0x70}, value) end
function LP2_TVAENVLevel_EndLevel_Changed(mod, value) sendParameterChange({0x00,0x02,0x30}, value) end
function UP1_TVAENV_VeloFollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x31}, value) end
function UP2_TVAENV_VeloFollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x71}, value) end
function LP1_TVAENV_VeloFollow_Changed(mod, value) sendParameterChange({0x00,0x01,0x71}, value) end
function LP2_TVAENV_VeloFollow_Changed(mod, value) sendParameterChange({0x00,0x02,0x31}, value) end
function UP1_TVAENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x32}, value) end
function UP2_TVAENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x00,0x72}, value) end
function LP1_TVAENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x01,0x72}, value) end
function LP2_TVAENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x02,0x32}, value) end
function UP1_TVAMOD_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x00,0x33}, value) end
function UP2_TVAMOD_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x00,0x73}, value) end
function LP1_TVAMOD_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x01,0x73}, value) end
function LP2_TVAMOD_LFOSelect_Changed(mod, value) sendParameterChange({0x00,0x02,0x33}, value) end
function UP1_TVAMOD_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x00,0x34}, value) end
function UP2_TVAMOD_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x00,0x74}, value) end
function LP1_TVAMOD_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x01,0x74}, value) end
function LP2_TVAMOD_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x02,0x34}, value) end
function UP1_TVAMOD_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x35}, value) end
function UP2_TVAMOD_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x00,0x75}, value) end
function LP1_TVAMOD_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x01,0x75}, value) end
function LP2_TVAMOD_AftertouchRange_Changed(mod, value) sendParameterChange({0x00,0x02,0x35}, value) end

--- COMMON PARAMETERS (x2)
function UC_Structure_Changed(mod, value) sendParameterChange({0x00,0x01,0x0A}, value) end
function LC_Structure_Changed(mod, value) sendParameterChange({0x00,0x02,0x4A}, value) end
function UC_PENV_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x01,0x0B}, value) end
function LC_PENV_VeloRange_Changed(mod, value) sendParameterChange({0x00,0x02,0x4B}, value) end
function UC_PENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x01,0x0C}, value) end
function LC_PENV_TimeKeyfollow_Changed(mod, value) sendParameterChange({0x00,0x02,0x4C}, value) end
function UC_PENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x01,0x0D}, value) end
function LC_PENVTime_T1_Changed(mod, value) sendParameterChange({0x00,0x02,0x4D}, value) end
function UC_PENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x01,0x0E}, value) end
function LC_PENVTime_T2_Changed(mod, value) sendParameterChange({0x00,0x02,0x4E}, value) end
function UC_PENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x01,0x0F}, value) end
function LC_PENVTime_T3_Changed(mod, value) sendParameterChange({0x00,0x02,0x4F}, value) end
function UC_PENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x01,0x10}, value) end
function LC_PENVTime_T4_Changed(mod, value) sendParameterChange({0x00,0x02,0x50}, value) end
function UC_PENVLevel_L0_Changed(mod, value) sendParameterChange({0x00,0x01,0x11}, value) end
function LC_PENVLevel_L0_Changed(mod, value) sendParameterChange({0x00,0x02,0x51}, value) end
function UC_PENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x01,0x12}, value) end
function LC_PENVLevel_L1_Changed(mod, value) sendParameterChange({0x00,0x02,0x52}, value) end
function UC_PENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x01,0x13}, value) end
function LC_PENVLevel_L2_Changed(mod, value) sendParameterChange({0x00,0x02,0x53}, value) end
function UC_PENVLevel_Sustain_Changed(mod, value) sendParameterChange({0x00,0x01,0x14}, value) end
function LC_PENVLevel_Sustain_Changed(mod, value) sendParameterChange({0x00,0x02,0x54}, value) end
function UC_PENVLevel_End_Changed(mod, value) sendParameterChange({0x00,0x01,0x15}, value) end
function LC_PENVLevel_End_Changed(mod, value) sendParameterChange({0x00,0x02,0x55}, value) end
function UC_PitchMod_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x01,0x16}, value) end
function LC_PitchMod_LFODepth_Changed(mod, value) sendParameterChange({0x00,0x02,0x56}, value) end
function UC_PitchMod_LeverMod_Changed(mod, value) sendParameterChange({0x00,0x01,0x17}, value) end
function LC_PitchMod_LeverMod_Changed(mod, value) sendParameterChange({0x00,0x02,0x57}, value) end
function UC_PitchMod_AftertouchMod_Changed(mod, value) sendParameterChange({0x00,0x01,0x18}, value) end
function LC_PitchMod_AftertouchMod_Changed(mod, value) sendParameterChange({0x00,0x02,0x58}, value) end
function UC_LFO1_Waveform_Changed(mod, value) sendParameterChange({0x00,0x01,0x19}, value) end
function LC_LFO1_Waveform_Changed(mod, value) sendParameterChange({0x00,0x02,0x59}, value) end
function UC_LFO1_Rate_Changed(mod, value) sendParameterChange({0x00,0x01,0x1A}, value) end
function LC_LFO1_Rate_Changed(mod, value) sendParameterChange({0x00,0x02,0x5A}, value) end
function UC_LFO1_DelayTime_Changed(mod, value) sendParameterChange({0x00,0x01,0x1B}, value) end
function LC_LFO1_DelayTime_Changed(mod, value) sendParameterChange({0x00,0x02,0x5B}, value) end
function UC_LFO1_Sync_Changed(mod, value) sendParameterChange({0x00,0x01,0x1C}, value) end
function LC_LFO1_Sync_Changed(mod, value) sendParameterChange({0x00,0x02,0x5C}, value) end
function UC_LFO2_Waveform_Changed(mod, value) sendParameterChange({0x00,0x01,0x1D}, value) end
function LC_LFO2_Waveform_Changed(mod, value) sendParameterChange({0x00,0x02,0x5D}, value) end
function UC_LFO2_Rate_Changed(mod, value) sendParameterChange({0x00,0x01,0x1E}, value) end
function LC_LFO2_Rate_Changed(mod, value) sendParameterChange({0x00,0x02,0x5E}, value) end
function UC_LFO2_DelayTime_Changed(mod, value) sendParameterChange({0x00,0x01,0x1F}, value) end
function LC_LFO2_DelayTime_Changed(mod, value) sendParameterChange({0x00,0x02,0x5F}, value) end
function UC_LFO2_Sync_Changed(mod, value) sendParameterChange({0x00,0x01,0x20}, value) end
function LC_LFO2_Sync_Changed(mod, value) sendParameterChange({0x00,0x02,0x60}, value) end
function UC_LFO3_Waveform_Changed(mod, value) sendParameterChange({0x00,0x01,0x21}, value) end
function LC_LFO3_Waveform_Changed(mod, value) sendParameterChange({0x00,0x02,0x61}, value) end
function UC_LFO3_Rate_Changed(mod, value) sendParameterChange({0x00,0x01,0x22}, value) end
function LC_LFO3_Rate_Changed(mod, value) sendParameterChange({0x00,0x02,0x62}, value) end
function UC_LFO3_DelayTime_Changed(mod, value) sendParameterChange({0x00,0x01,0x23}, value) end
function LC_LFO3_DelayTime_Changed(mod, value) sendParameterChange({0x00,0x02,0x63}, value) end
function UC_LFO3_Sync_Changed(mod, value) sendParameterChange({0x00,0x01,0x24}, value) end
function LC_LFO3_Sync_Changed(mod, value) sendParameterChange({0x00,0x02,0x64}, value) end
function UC_EQ_LowFreq_Changed(mod, value) sendParameterChange({0x00,0x01,0x25}, value) end
function LC_EQ_LowFreq_Changed(mod, value) sendParameterChange({0x00,0x02,0x65}, value) end
function UC_EQ_LowGain_Changed(mod, value) sendParameterChange({0x00,0x01,0x26}, value) end
function LC_EQ_LowGain_Changed(mod, value) sendParameterChange({0x00,0x02,0x66}, value) end
function UC_EQ_HighFreq_Changed(mod, value) sendParameterChange({0x00,0x01,0x27}, value) end
function LC_EQ_HighFreq_Changed(mod, value) sendParameterChange({0x00,0x02,0x67}, value) end
function UC_EQ_HighQ_Changed(mod, value) sendParameterChange({0x00,0x01,0x28}, value) end
function LC_EQ_HighQ_Changed(mod, value) sendParameterChange({0x00,0x02,0x68}, value) end
function UC_EQ_HighGain_Changed(mod, value) sendParameterChange({0x00,0x01,0x29}, value) end
function LC_EQ_HighGain_Changed(mod, value) sendParameterChange({0x00,0x02,0x69}, value) end
function UC_Chorus_Type_Changed(mod, value) sendParameterChange({0x00,0x01,0x2A}, value) end
function LC_Chorus_Type_Changed(mod, value) sendParameterChange({0x00,0x02,0x6A}, value) end
function UC_Chorus_Rate_Changed(mod, value) sendParameterChange({0x00,0x01,0x2B}, value) end
function LC_Chorus_Rate_Changed(mod, value) sendParameterChange({0x00,0x02,0x6B}, value) end
function UC_Chorus_Depth_Changed(mod, value) sendParameterChange({0x00,0x01,0x2C}, value) end
function LC_Chorus_Depth_Changed(mod, value) sendParameterChange({0x00,0x02,0x6C}, value) end
function UC_Chorus_Balance_Changed(mod, value) sendParameterChange({0x00,0x01,0x2D}, value) end
function LC_Chorus_Balance_Changed(mod, value) sendParameterChange({0x00,0x02,0x6D}, value) end
function UC_PartialMute_Changed(mod, value) sendParameterChange({0x00,0x01,0x2E}, value) end
function LC_PartialMute_Changed(mod, value) sendParameterChange({0x00,0x02,0x6E}, value) end
function UC_PartialBalance_Changed(mod, value) sendParameterChange({0x00,0x01,0x2F}, value) end
function LC_PartialBalance_Changed(mod, value) sendParameterChange({0x00,0x02,0x6F}, value) end

--- PATCH PARAMETERS (x1)
function Patch_KeyMode_Changed(mod, value) sendParameterChange({0x00,0x03,0x12}, value) end
function Patch_SplitPoint_Changed(mod, value) sendParameterChange({0x00,0x03,0x13}, value) end
function Patch_PortamentoMode_Changed(mod, value) sendParameterChange({0x00,0x03,0x14}, value) end
function Patch_HoldMode_Changed(mod, value) sendParameterChange({0x00,0x03,0x15}, value) end
function Patch_UToneKeyShift_Changed(mod, value) sendParameterChange({0x00,0x03,0x16}, value) end
function Patch_LToneKeyShift_Changed(mod, value) sendParameterChange({0x00,0x03,0x17}, value) end
function Patch_UToneFineTune_Changed(mod, value) sendParameterChange({0x00,0x03,0x18}, value) end
function Patch_LToneFineTune_Changed(mod, value) sendParameterChange({0x00,0x03,0x19}, value) end
function Patch_BenderRange_Changed(mod, value) sendParameterChange({0x00,0x03,0x1A}, value) end
function Patch_AftertouchPB_Changed(mod, value) sendParameterChange({0x00,0x03,0x1B}, value) end
function Patch_PortamentoTime_Changed(mod, value) sendParameterChange({0x00,0x03,0x1C}, value) end
function Patch_OutputMode_Changed(mod, value) sendParameterChange({0x00,0x03,0x1D}, value) end
function Patch_ReverbType_Changed(mod, value) sendParameterChange({0x00,0x03,0x1E}, value) end
function Patch_ReverbBalance_Changed(mod, value) sendParameterChange({0x00,0x03,0x1F}, value) end
function Patch_TotalVolume_Changed(mod, value) sendParameterChange({0x00,0x03,0x20}, value) end
function Patch_ToneBalance_Changed(mod, value) sendParameterChange({0x00,0x03,0x21}, value) end
function Patch_ChaseMode_Changed(mod, value) sendParameterChange({0x00,0x03,0x22}, value) end
function Patch_ChaseLevel_Changed(mod, value) sendParameterChange({0x00,0x03,0x23}, value) end
function Patch_ChaseTime_Changed(mod, value) sendParameterChange({0x00,0x03,0x24}, value) end

--- SPECIAL HANDLERS
function Patch_MIDIDevice_Changed(mod, value)
    midiDeviceID = value
    console("D-05 MIDI Device ID changed to: "..(midiDeviceID + 1))
end

function Patch_RequestDump_Changed(mod, value)
    if value == 1 then -- Only trigger on button press down
        requestPatchDump()
    end
end


-- ==============================================================================
--  BI-DIRECTIONAL ADDRESS MAP POPULATION (v3 - Truly Complete)
-- ==============================================================================

function populateAddressMap()
    -- This function maps a SysEx address string to a modulator name.
    -- It is called once when the panel loads and is used by the midiReceivedCbk
    -- to update the panel's UI when data is received from the synth.

    -- --- PARTIAL PARAMETERS ---
    local partial_params = {
        {offset=0x00, section="WGPitch", name="Coarse"}, {offset=0x01, section="WGPitch", name="Fine"},
        {offset=0x02, section="WGPitch", name="Keyfollow"}, {offset=0x03, section="WGMod", name="LFOMode"},
        {offset=0x04, section="WGMod", name="PENVMode"}, {offset=0x05, section="WGMod", name="BenderMode"},
        {offset=0x06, section="WGForm", name="WaveformSynth"}, {offset=0x07, section="WGForm", name="WaveformPCM"},
        {offset=0x08, section="WGPW", name="PulseWidth"}, {offset=0x09, section="WGPW", name="VeloRange"},
        {offset=0x0A, section="WGPW", name="LFOSelect"}, {offset=0x0B, section="WGPW", name="LFODepth"},
        {offset=0x0C, section="WGPW", name="AftertouchRange"}, {offset=0x0D, section="TVF", name="Cutoff"},
        {offset=0x0E, section="TVF", name="Resonance"}, {offset=0x0F, section="TVF", name="Keyfollow"},
        {offset=0x10, section="TVF", name="BiasPoint"}, {offset=0x11, section="TVF", name="BiasLevel"},
        {offset=0x12, section="TVFENV", name="Depth"}, {offset=0x13, section="TVFENV", name="VeloRange"},
        {offset=0x14, section="TVFENV", name="DepthKeyfollow"}, {offset=0x15, section="TVFENV", name="TimeKeyfollow"},
        {offset=0x16, section="TVFENVTime", name="T1"}, {offset=0x17, section="TVFENVTime", name="T2"},
        {offset=0x18, section="TVFENVTime", name="T3"}, {offset=0x19, section="TVFENVTime", name="T4"},
        {offset=0x1A, section="TVFENVTime", name="T5"}, {offset=0x1B, section="TVFENVLevel", name="L1"},
        {offset=0x1C, section="TVFENVLevel", name="L2"}, {offset=0x1D, section="TVFENVLevel", name="L3"},
        {offset=0x1E, section="TVFENVLevel", name="SustainLevel"}, {offset=0x1F, section="TVFENVLevel", name="EndLevel"},
        {offset=0x20, section="TVFMOD", name="LFOSelect"}, {offset=0x21, section="TVFMOD", name="LFODepth"},
        {offset=0x22, section="TVFMOD", name="AftertouchRange"}, {offset=0x23, section="TVA", name="Level"},
        {offset=0x24, section="TVA", name="VeloRange"}, {offset=0x25, section="TVA", name="BiasPoint"},
        {offset=0x26, section="TVA", name="BiasLevel"}, {offset=0x27, section="TVAENVTime", name="T1"},
        {offset=0x28, section="TVAENVTime", name="T2"}, {offset=0x29, section="TVAENVTime", name="T3"},
        {offset=0x2A, section="TVAENVTime", name="T4"}, {offset=0x2B, section="TVAENVTime", name="T5"},
        {offset=0x2C, section="TVAENVLevel", name="L1"}, {offset=0x2D, section="TVAENVLevel", name="L2"},
        {offset=0x2E, section="TVAENVLevel", name="L3"}, {offset=0x2F, section="TVAENVLevel", name="SustainLevel"},
        {offset=0x30, section="TVAENVLevel", name="EndLevel"}, {offset=0x31, section="TVAENV", name="VeloFollow"},
        {offset=0x32, section="TVAENV", name="TimeKeyfollow"}, {offset=0x33, section="TVAMOD", name="LFOSelect"},
        {offset=0x34, section="TVAMOD", name="LFODepth"}, {offset=0x35, section="TVAMOD", name="AftertouchRange"}
    }
    local partials = {
        {prefix="UP1", baseH=0x00, baseM=0x00, baseL=0x00}, {prefix="UP2", baseH=0x00, baseM=0x00, baseL=0x40},
        {prefix="LP1", baseH=0x00, baseM=0x01, baseL=0x40}, {prefix="LP2", baseH=0x00, baseM=0x02, baseL=0x00}
    }
    for _, p_instance in ipairs(partials) do
        for _, param in ipairs(partial_params) do
            local addrL = p_instance.baseL + param.offset
            local addrM = p_instance.baseM
            if addrL > 0x7F then -- Handle L-byte overflow for this specific mapping
                addrM = addrM + 1
                addrL = addrL - 0x40
            end
            local addr_str = string.format("%02X%02X%02X", p_instance.baseH, addrM, addrL)
            local mod_name = p_instance.prefix .. "_" .. param.section .. "_" .. param.name
            addressMap[addr_str] = mod_name
        end
    end

    -- --- COMMON PARAMETERS ---
    local common_params = {
        {offset=0x0A, section="Common", name="Structure"}, {offset=0x0B, section="PENV", name="VeloRange"},
        {offset=0x0C, section="PENV", name="TimeKeyfollow"}, {offset=0x0D, section="PENVTime", name="T1"},
        {offset=0x0E, section="PENVTime", name="T2"}, {offset=0x0F, section="PENVTime", name="T3"},
        {offset=0x10, section="PENVTime", name="T4"}, {offset=0x11, section="PENVLevel", name="L0"},
        {offset=0x12, section="PENVLevel", name="L1"}, {offset=0x13, section="PENVLevel", name="L2"},
        {offset=0x14, section="PENVLevel", name="Sustain"}, {offset=0x15, section="PENVLevel", name="End"},
        {offset=0x16, section="PitchMod", name="LFODepth"}, {offset=0x17, section="PitchMod", name="LeverMod"},
        {offset=0x18, section="PitchMod", name="AftertouchMod"}, {offset=0x19, section="LFO1", name="Waveform"},
        {offset=0x1A, section="LFO1", name="Rate"}, {offset=0x1B, section="LFO1", name="DelayTime"},
        {offset=0x1C, section="LFO1", name="Sync"}, {offset=0x1D, section="LFO2", name="Waveform"},
        {offset=0x1E, section="LFO2", name="Rate"}, {offset=0x1F, section="LFO2", name="DelayTime"},
        {offset=0x20, section="LFO2", name="Sync"}, {offset=0x21, section="LFO3", name="Waveform"},
        {offset=0x22, section="LFO3", name="Rate"}, {offset=0x23, section="LFO3", name="DelayTime"},
        {offset=0x24, section="LFO3", name="Sync"}, {offset=0x25, section="EQ", name="LowFreq"},
        {offset=0x26, section="EQ", name="LowGain"}, {offset=0x27, section="EQ", name="HighFreq"},
        {offset=0x28, section="EQ", name="HighQ"}, {offset=0x29, section="EQ", name="HighGain"},
        {offset=0x2A, section="Chorus", name="Type"}, {offset=0x2B, section="Chorus", name="Rate"},
        {offset=0x2C, section="Chorus", name="Depth"}, {offset=0x2D, section="Chorus", name="Balance"},
        {offset=0x2E, section="Common", name="PartialMute"}, {offset=0x2F, section="Common", name="PartialBalance"}
    }
    local commons = {
        {prefix="UC", baseH=0x00, baseM=0x01, baseL=0x00}, {prefix="LC", baseH=0x00, baseM=0x02, baseL=0x40}
    }
    for _, c_instance in ipairs(commons) do
        for _, param in ipairs(common_params) do
            local addrL = c_instance.baseL + param.offset
            local addr_str = string.format("%02X%02X%02X", c_instance.baseH, c_instance.baseM, addrL)
            local mod_name = c_instance.prefix .. "_" .. param.section .. "_" .. param.name
            addressMap[addr_str] = mod_name
        end
    end

    -- --- PATCH PARAMETERS ---
    -- Note: Patch Name is not included as it's a multi-byte string handled differently.
    addressMap["000312"] = "Patch_KeyMode"
    addressMap["000313"] = "Patch_SplitPoint"
    addressMap["000314"] = "Patch_PortamentoMode"
    addressMap["000315"] = "Patch_HoldMode"
    addressMap["000316"] = "Patch_UToneKeyShift"
    addressMap["000317"] = "Patch_LToneKeyShift"
    addressMap["000318"] = "Patch_UToneFineTune"
    addressMap["000319"] = "Patch_LToneFineTune"
    addressMap["00031A"] = "Patch_BenderRange"
    addressMap["00031B"] = "Patch_AftertouchPB"
    addressMap["00031C"] = "Patch_PortamentoTime"
    addressMap["00031D"] = "Patch_OutputMode"
    addressMap["00031E"] = "Patch_ReverbType"
    addressMap["00031F"] = "Patch_ReverbBalance"
    addressMap["000320"] = "Patch_TotalVolume"
    addressMap["000321"] = "Patch_ToneBalance"
    addressMap["000322"] = "Patch_ChaseMode"
    addressMap["000323"] = "Patch_ChaseLevel"
    addressMap["000324"] = "Patch_ChaseTime"
end
