### Analysis of the D-05 MIDI Implementation

The two most important documents needed for this project are the `D-05 Owner's Manual` and the `D-05 Parameter Guide` (with the `MIDI Implementation` section) are the blueprints for the synthesizer's brain.

The full script with all the parts dicsussed below is named D05.lua.

Here are the critical takeaways from the manual for our Ctrlr panel:

1.  **SysEx Structure:** The D-05 uses standard Roland SysEx for parameter changes. The format for sending a single parameter change (Data Set 1) is:
    `F0 41 <Device ID> 14 12 <Address H> <Address M> <Address L> <Data> <Checksum> F7`
    *   `14H` is the Model ID for the D-50/D-05.
    *   `<Device ID>` corresponds to the MIDI channel (0-15 mapped to 0H-FH).
    *   `<Address>` is a 3-byte address pointing to the specific parameter in the synth's memory.
    *   `<Data>` is the value we want to set.
    *   `<Checksum>` is a calculated byte. The manual states: "The check sum is the value that causes the lower seven bits to be zero when the address, the size, and the check sum itself are added."

2.  **Checksum is Required:** The checksum calculation is mandatory. This is not something that can be done with a simple placeholder in Ctrlr's MIDI formula field. **This confirms that Lua scripting is essential for a functional panel.**

3.  **Address Space:** Page 39 ("Address mapping") is key. It shows us two areas:
    *   **Temporary Area:** Starts at `00 00 00`. This is the edit buffer. When you tweak a parameter, you are changing values here. This is what our editor will primarily talk to.
    *   **Work Area:** Starts at `02 00 00`. This corresponds to the stored patches.
    *   The structure is hierarchical: `Patch -> Tone (Upper/Lower) -> Partial (1/2)`. The addresses reflect this. For example:
        *   Upper Tone, Partial 1: starts at `00 00 00`
        *   Upper Tone, Partial 2: starts at `00 00 40`
        *   Lower Tone, Partial 1: starts at `00 01 40`

---

### Phase 1: The Pre-Built D-05 Parameter Map

Here is a sample of the map of parameters you will need.  Each parameter has  the `SysEx Address` from the manual and a pre-formatted `SysEx Formula` that you will use in conjunction with the Lua script.

**Important Note on SysEx Formulas:**
The `Formula` column below isn't for direct entry into the Ctrlr MIDI tab. It's a reference for our Lua script. The script will need the **3-byte address** and the **value**. In your Ctrlr modulator callbacks, you will call a Lua function like `sendParameterChange({0x00, 0x00, 0x00}, value)`.

#### **Group 1: Patch Parameters** (Page 42)
These are global settings for the entire patch.

| Parameter Name | UI Group | Ctrlr Component | Value Range | SysEx Address |
| :--- | :--- | :--- | :--- | :--- |
| Key Mode | Patch | uiComboBox | 0-8 | `00 03 12` |
| Split Point | Patch | uiKnob / uiSlider | 0-60 | `00 03 13` |
| Portamento Mode | Patch | uiComboBox | 0-2 | `00 03 14` |
| Portamento Time | Patch | uiSlider | 0-100 | `00 03 1C` |
| Bender Range | Patch | uiSlider | 0-12 | `00 03 1A` |
| Reverb Type | Patch | uiComboBox | 0-31 | `00 03 1E` |
| Reverb Balance | Patch | uiSlider | 0-100 | `00 03 1F` |
| Total Volume | Patch | uiSlider | 0-100 | `00 03 20` |
| Tone Balance | Patch | uiSlider | 0-100 | `00 03 21` |

#### **Group 2: Tone Common Parameters** (Page 41)
These settings apply to a full Tone (which contains 2 Partials). You will need a set of these controls for the **Upper Tone** and a separate set for the **Lower Tone**.

*   **For Upper Tone:** Use SysEx Address prefix `00 01 xx`
*   **For Lower Tone:** Use SysEx Address prefix `00 02 xx`

| Parameter Name | UI Group | Ctrlr Component | Value Range | SysEx Address (Upper/Lower) |
| :--- | :--- | :--- | :--- | :--- |
| Structure | Tone Common | uiComboBox | 0-6 | `00 01 0A` / `00 02 4A` |
| P-ENV Velocity Rng | Tone Common | uiSlider | 0-2 | `00 01 0B` / `00 02 4B` |
| P-ENV T1 | Tone Common | uiSlider | 0-50 | `00 01 0D` / `00 02 4D` |
| P-ENV T4 | Tone Common | uiSlider | 0-50 | `00 01 10` / `00 02 50` |
| P-ENV L1 | Tone Common | uiSlider | -50..+50 (map 0-100) | `00 01 12` / `00 02 52` |
| P-ENV SusL | Tone Common | uiSlider | -50..+50 (map 0-100) | `00 01 14` / `00 02 54` |
| LFO-1 Waveform | Tone Common | uiComboBox | 0-3 | `00 01 19` / `00 02 59` |
| LFO-1 Rate | Tone Common | uiSlider | 0-100 | `00 01 1A` / `00 02 5A` |
| ... (and so on for all LFOs, EQ, Chorus) | | | | |

#### **Group 3: Partial Parameters** (Page 40)
This is the heart of the synth engine. You will need **four** complete sets of these controls, one for each Partial:
*   **Upper Partial 1:** SysEx Address prefix `00 00 xx`
*   **Upper Partial 2:** SysEx Address prefix `00 00 xx` (but add `40H` to `xx`) -> e.g., `00 00 40`, `00 00 41`
*   **Lower Partial 1:** SysEx Address prefix `00 01 xx` (but add `40H` to `xx`) -> e.g., `00 01 40`, `00 01 41`
*   **Lower Partial 2:** SysEx Address prefix `00 02 xx` -> e.g., `00 02 00`, `00 02 01`

| Parameter Name | UI Group | Ctrlr Component | Value Range | SysEx Address (for U-P1) |
| :--- | :--- | :--- | :--- | :--- |
| **WG (Wave Generator)** |
| Coarse Pitch | Partial: WG | uiKnob | 0-72 (C1-C7) | `00 00 00` |
| Fine Pitch | Partial: WG | uiKnob | -50..+50 (map 0-100) | `00 00 01` |
| Keyfollow (Pitch) | Partial: WG | uiComboBox | 0-16 | `00 00 02` |
| WG Waveform | Partial: WG | uiComboBox | 0-1 (Synth) / 0-99 (PCM) | `00 00 06` / `00 00 07` |
| Pulse Width | Partial: WG | uiSlider | 0-100 | `00 00 08` |
| PWM LFO Select | Partial: WG | uiComboBox | 0-5 | `00 00 0A` |
| PWM LFO Depth | Partial: WG | uiSlider | 0-100 | `00 00 0B` |
| **TVF (Filter)** |
| Cutoff Freq | Partial: TVF | uiSlider | 0-100 | `00 00 0D` |
| Resonance | Partial: TVF | uiSlider | 0-30 | `00 00 0E` |
| Keyfollow (Cutoff) | Partial: TVF | uiComboBox | 0-14 | `00 00 0F` |
| ENV Depth | Partial: TVF | uiSlider | 0-100 | `00 00 12` |
| ENV T1 | Partial: TVF | uiSlider | 0-100 | `00 00 16` |
| ENV L1 | Partial: TVF | uiSlider | 0-100 | `00 00 1B` |
| ENV SusL | Partial: TVF | uiSlider | 0-100 | `00 00 1E` |
| **TVA (Amplifier)** |
| Level | Partial: TVA | uiSlider | 0-100 | `00 00 23` |
| Velocity Range | Partial: TVA | uiSlider | -50..+50 (map 0-100) | `00 00 24` |
| ENV T1 | Partial: TVA | uiSlider | 0-100 | `00 00 27` |
| ENV L1 | Partial: TVA | uiSlider | 0-100 | `00 00 2C` |
| ENV SusL | Partial: TVA | uiSlider | 0-100 | `00 00 2F` |
| ... *and so on for all other parameters* | | | | |

---

### Phase 2: Core Lua Scripts

Here is Lua code to handle the necessary logic. The Lua code needs to be pasted in, use the full script named D05.lua and Go to `Panel -> LUA Editor` in Ctrlr and paste it in.

```lua
--
-- D-05 Ctrlr Panel Core Script
--

-- Panel loaded, setup initial values
function panelLoaded()
    -- Get the MIDI Device ID from a combo box on the panel named 'midiDeviceID'
    -- This allows the user to set the MIDI channel the synth is on.
    -- The values should be 0-15.
    midiDeviceID = panel:getModulatorByName("midiDeviceID"):getModulatorValue()
    console("Panel Loaded. D-05 MIDI Device ID set to: "..midiDeviceID)
end


-- Function to calculate the Roland checksum
-- Input: A table of bytes (address and data)
-- Output: The calculated checksum byte
function calculateChecksum(bytes)
    local sum = 0
    for i, b in ipairs(bytes) do
        sum = sum + b
    end
    -- The checksum is a value that, when added to the sum,
    -- makes the lower 7 bits of the total equal to 0.
    return (128 - (sum % 128)) % 128
end


-- Central function to send a parameter change via SysEx
-- This is the function you will call from your sliders/knobs.
-- addr: a 3-byte table for the address, e.g. {0x00, 0x00, 0x0D} for TVF Cutoff
-- value: the integer value of the parameter (0-127)
function sendParameterChange(addr, value)
    -- First, calculate the checksum for the address and data bytes
    local checksum_data = {addr[1], addr[2], addr[3], value}
    local checksum = calculateChecksum(checksum_data)

    -- Construct the full SysEx message
    local sysex_message = {
        0xF0, -- SysEx Start
        0x41, -- Roland ID
        midiDeviceID, -- From our panel setting
        0x14, -- D-50/D-05 Model ID
        0x12, -- Data Set 1 (DT1) Command
        addr[1], addr[2], addr[3], -- The 3-byte address
        value, -- The data
        checksum, -- The calculated checksum
        0xF7  -- SysEx End
    }

    -- Send the message
    panel:sendMidiMessage(sysex_message)

    -- Optional: Log to console for debugging
    -- console(string.format("Sent SysEx: Addr=%02X%02X%02X, Val=%d, CS=%02X", addr[1], addr[2], addr[3], value, checksum))
end


-- Function to request a full dump of the current edit buffer from the D-05
-- This can be attached to a button on the panel.
function requestPatchDump()
    -- We want to request the entire temporary area.
    -- It spans from 00 00 00 up to around 00 03 3F (check manual for exact size)
    -- For simplicity, we'll request a known block.
    -- Address: 00 00 00 (Start of Temp Area)
    -- Size: 00 04 00 (Requesting 1024 bytes, which covers the entire patch buffer)
    local addr = {0x00, 0x00, 0x00}
    local size = {0x00, 0x04, 0x00} -- Requesting 1k block.
    
    local checksum = calculateChecksum({addr[1], addr[2], addr[3], size[1], size[2], size[3]})

    local request_message = {
        0xF0, 0x41, midiDeviceID, 0x14,
        0x11, -- Request Data 1 (RQ1) Command
        addr[1], addr[2], addr[3],
        size[1], size[2], size[3],
        checksum,
        0xF7
    }
    
    panel:sendMidiMessage(request_message)
    console("Patch dump requested from D-05.")
end


-- This is a more advanced placeholder for receiving and parsing the patch dump.
-- To use this, you need to set the panel's "LUA midiReceivedCbk" property to "receiveMidiMessage"
function receiveMidiMessage(midiMessage)
    -- Check if it's a SysEx message from our D-05
    if midiMessage:isSysEx() and midiMessage:getByte(2) == 0x41 and midiMessage:getByte(4) == 0x14 and midiMessage:getByte(5) == 0x12 then
        -- It's a Data Set 1 (DT1) message, likely in response to our dump request
        local startAddr = {midiMessage:getByte(6), midiMessage:getByte(7), midiMessage:getByte(8)}
        
        -- The actual data starts at byte 9 and goes until the checksum at the end
        local dataBytes = {}
        for i = 9, midiMessage:getSize() - 2 do
            table.insert(dataBytes, midiMessage:getByte(i))
        end

        console("Received SysEx Dump! Starting address: "..string.format("%02X%02X%02X", startAddr[1], startAddr[2], startAddr[3]))
        
        -- Now, you would loop through the dataBytes and update your UI.
        -- This part is complex and requires a full map of addresses to modulator names.
        -- Example for just one parameter:
        if startAddr[1] == 0x00 and startAddr[2] == 0x00 and startAddr[3] == 0x0D then
             -- This dump starts at TVF Cutoff for Upper Partial 1
             local cutoffValue = dataBytes[1]
             -- Assuming you named your slider "UP1_TVFCutoff"
             local mod = panel:getModulatorByName("UP1_TVFCutoff")
             if mod then
                 mod:setValue(cutoffValue, false) -- set value without triggering callback
             end
        end
        -- ... you would need to implement this logic for ALL parameters.
    end
end

```

### How to Use This

1.  **Design your UI:** Create your background image and lay out all your sliders, knobs, and buttons in Ctrlr. **Give them logical names** as I suggested (e.g., `UP1_TVFCutoff`, `LT2_TVALevel`, `Patch_ReverbType`). This is critical for the `receiveMidiMessage` function to work later.
2.  **Add the Lua Script:** Paste the Lua code above into the Lua Editor.
3.  **Connect UI to Lua:** For each modulator (e.g., the TVF Cutoff slider for Upper Partial 1), you don't use the MIDI tab. Instead, you set its `LUA modulatorValueChangeCbk` property to the name of a new Lua function.
    *   Example: For the `UP1_TVFCutoff` slider, you'd set its callback property to `UP1_TVFCutoff_Changed`.
    *   Then, in your Lua script, you add that function:
        ```lua
        function UP1_TVFCutoff_Changed(mod, value)
            -- Call our central function with the correct address for this parameter
            -- Address for UP1 TVF Cutoff is 00 00 0D
            sendParameterChange({0x00, 0x00, 0x0D}, value)
        end

        function LT2_TVALevel_Changed(mod, value)
            -- Address for LT2 TVA Level is 00 02 23
            sendParameterChange({0x00, 0x02, 0x23}, value)
        end
        ```
    *   You will create one of these small callback functions for every single control on your panel. It's tedious, but it's the correct and most maintainable way to do it.

This is a sample of the code, see D05.lua for the actual script with the complete data map, essential code, and callback functions to build a fully functional D-05 editor. 
