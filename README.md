### CTRLR Panels Project

The goal is to create custom Ctrlr panels for hardware synthesizers, which can function as standalone editors or as VST/AU plugins within a Digital Audio Workstation (DAW). This process involves three main disciplines:
1.  **Synth Research:** Understanding the target synthesizer's MIDI communication protocol (especially System Exclusive messages, or SysEx).
2.  **UI/UX Design:** Creating a graphical interface that is both functional and intuitive.
3.  **Ctrlr Development:** Using the Ctrlr application to build the panel, connect UI elements to MIDI messages, and script custom logic using Lua.

A sample `PKGBUILD` file and D-50 panel image are located in the examples directory of the *end result* of this process: a distributable software package and the graphical asset it uses. Below is a list of the steps to *create* these artifacts.

---

### **Phase 1: Research, Planning, and Asset Preparation (The Foundation)**

This is the most critical phase. Flaws here will cascade through the entire project. Do not skip these steps.

**1.1. Target Synthesizer Deep Dive**
*   **Objective:** To understand every controllable parameter of your synth and how to control it via MIDI.
*   **Action:**
    *   **Obtain the Manuals:** You need the **User Manual** and, most importantly, the **MIDI Implementation Chart**. Often, a **Service Manual** is the holy grail as it can contain undocumented SysEx commands.
    *   **Identify Control Methods:** Most classic synths use a combination of:
        *   **Control Change (CC):** For common, real-time parameters (e.g., Mod Wheel, Volume). Simple to implement.
        *   **NRPN (Non-Registered Parameter Numbers):** For higher-resolution or more specific parameters. More complex than CC.
        *   **System Exclusive (SysEx):** The most powerful and most common method for deep patch editing. It allows manufacturers to create custom data formats. **You must master the SysEx format for your target synth.**

**1.2. Deconstruct the SysEx Protocol**
*   **Objective:** To be able to read and write SysEx messages that control individual parameters and full patch dumps.
*   **Action:**
    *   **Study the MIDI Implementation Chart:** It will detail the structure of a SysEx message. It typically looks like this:
        `F0 <Manufacturer ID> <Device ID> <Model ID> <Command> <Address> <Data> F7`
    *   **Use a MIDI Monitor:** Tools like MIDI-OX (Windows), Snoize (macOS), or even features within your DAW are essential. Watch the MIDI data that the synth sends when you tweak a knob on its front panel or when it sends a full patch dump. This is invaluable for verifying the manual and finding undocumented commands.
    *   **Identify Key Operations:**
        *   **Parameter Change:** The SysEx message to change a single value (e.g., Filter Cutoff).
        *   **Patch Dump Request:** The SysEx message you send to the synth to ask it to send you its current patch data.
        *   **Patch Dump Receive:** The format of the full patch data the synth sends back. You will need to parse this to update your entire editor.

**1.3. Create a Parameter Map (The Blueprint)**
*   **Objective:** To have a definitive reference for every parameter in your editor.
*   **Expert Advice:** Do this in a spreadsheet (Google Sheets, Excel, etc.). This will become your project bible.
*   **Columns for your spreadsheet:**
    *   `Parameter Name`: e.g., "VCF Cutoff"
    *   `Panel Section`: e.g., "Filter"
    *   `Ctrlr Component Type`: e.g., "Slider", "Knob", "Button"
    *   `Synth Value Range`: e.g., 0-99
    *   `MIDI Type`: e.g., "SysEx", "CC"
    *   `MIDI Message Details`:
        *   For CC: The CC number.
        *   For SysEx: The exact address bytes for this parameter.
    *   `Notes`: e.g., "Value is LSB/MSB", "Requires checksum calculation".

**1.4. GUI Design and Asset Creation**
*   **Objective:** To design and create the graphical background for your panel.
*   **Action:**
    *   **Analyze the Provided D-50 Image:** The D-50 panel is a masterpiece of skeuomorphic design. It's clean, logically grouped (WG PITCH, TVF, STRUCTURE), and directly references the hardware's workflow. This is a great model to follow.
    *   **Choose a Design Philosophy:**
        1.  **Hardware Recreation:** Mimic the physical synth's front panel (like the D-50 example). This is familiar to existing users.
        2.  **Modern UI:** Create a clean, flat, modern interface. This can improve usability by exposing hidden parameters more clearly.
    *   **Use a Graphics Editor:** Adobe Photoshop, GIMP (free), Affinity Designer, or even Figma.
    *   **Export:** Export the final design as a single high-quality PNG or JPG file. This will be the background of your Ctrlr panel.

---

### **Phase 2: Panel Development in Ctrlr (The Build)**

Now we move into the Ctrlr application itself.

**2.1. Initial Panel Setup**
1.  Open Ctrlr. Go to `Panel -> New Panel`.
2.  In the panel properties (usually on the right), set the dimensions to match your background image (`Panel Size`).
3.  Set the `Panel Background Image` property to your exported image file.
4.  Define the plugin formats you want to export under `Export`. Start with `Standalone` and `VST` or `AU`.

**2.2. Adding UI Components (Modulators)**
1.  From the `Tools` menu, add components like `uiSlider`, `uiKnob`, `uiButton`, etc.
2.  Drag and position them over the corresponding elements on your background image.
3.  **Crucially, name each component logically** using the "Component Name" property. Use the names from your parameter map spreadsheet (e.g., `vcfCutoffSlider`). This is vital for scripting later.
4.  Style the components. You can make them transparent to just use the graphics from your background, or use Ctrlr's built-in styling.

**2.3. MIDI Mapping (Connecting UI to Synth)**
*   **Objective:** To make a UI slider change a parameter on the synth.
*   **This is the core of the project.** Select a component (e.g., `vcfCutoffSlider`).
*   In its properties, go to the **MIDI** tab.
*   Configure the **MIDI Message** section:
    *   **Type:** Select `SysEx`, `CC`, etc., based on your research.
    *   **SysEx Formula:** This is where you construct the message. Use your spreadsheet! Ctrlr uses `xx` as a placeholder for the component's value.
        *   *Example:* If the manual says the message for cutoff is `F0 41 10 16 12 01 00 05 <value> <checksum> F7`, your formula might be `F0 41 10 16 12 01 00 05 xx F7`. (Checksums are an advanced topic we'll cover in scripting).
    *   **Value Mapping:** Set the `Min` and `Max` values to match the component's range and the synth's expected range.

**2.4. Advanced Logic with Lua Scripting**
*   **Objective:** To handle tasks that are too complex for simple MIDI mapping.
*   **Expert Advice:** Nearly every professional-quality panel requires some Lua scripting.
*   Access the script editor via `Panel -> LUA Editor`.
*   **Common Use Cases for Lua:**
    1.  **Checksum Calculation:** Many synths require a checksum byte in their SysEx messages. You'll write a Lua function that calculates this and inserts it into the message before sending.
    2.  **Receiving and Parsing Patch Dumps:** Create a function that is triggered when the panel receives a large SysEx dump from the synth. This function will read the byte array, extract the value for each parameter, and update the corresponding UI component on your panel (`panel:getModulatorByName("vcfCutoffSlider"):setValue(...)`). This is how you get bi-directional control.
    3.  **Patch Dump Request Button:** Create a button that, when clicked, calls a Lua function to send the "patch dump request" SysEx message to the synth.
    4.  **Complex Parameter Dependencies:** If changing one parameter should enable/disable or change the range of another (e.g., switching an LFO shape changes the available parameters), you handle this logic in Lua.

*   **Example Lua Snippet (Conceptual):**

```lua
-- This function is called whenever the cutoff slider is moved
function updateVCF_Cutoff(modulator, value)
  -- A simple SysEx message without a checksum
  local sysex_message = {0xF0, 0x41, 0x10, 0x16, 0x12, 0x01, 0x00, 0x05, value, 0xF7}
  panel:sendMidiMessage(sysex_message)
end

-- This function is called when a "Request Patch" button is pressed
function requestPatchDump()
  local request_message = {0xF0, 0x41, 0x10, 0x16, 0x11, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00, 0x7F, 0xF7} -- Example request
  panel:sendMidiMessage(request_message)
end
```

---

### **Phase 3: Testing and Refinement**

*   **Connectivity Test:** Ensure Ctrlr can see your MIDI interface and synth.
*   **Unidirectional Test:** Move a slider on your panel. Does the parameter change on the synth? Use your MIDI monitor to see if the correct message is being sent.
*   **Bidirectional Test:** Change a parameter on the synth itself. After requesting a patch dump, does your panel update to reflect the new state?
*   **DAW Integration:** Export the panel as a VST/AU. Load it in your DAW. Does it control the synth? Does the panel's state save and recall correctly with the DAW project? This is a critical test.
*   **Bug Hunting:** Test edge cases. Min/max values, invalid combinations, etc.

---

### **Phase 4: Packaging and Distribution**

**4.1. Exporting the Panel**
*   In Ctrlr, go to `File -> Export -> Export Restricted Instance`. This bundles your panel, scripts, and assets into a self-contained plugin/application that doesn't require users to have Ctrlr installed.
*   Alternatively, you can save the panel as a `.bpanelz` file (a zipped panel bundle). This is for users who already have Ctrlr installed.

**4.2. Distribution**
*   **Simple:** Zip up your exported plugin files with a `README.txt` and upload it to a forum or website.
*   **Advanced (The `PKGBUILD` Method):** This is specific to Arch Linux. The provided `PKGBUILD` file is a recipe for the package manager. It tells it:
    *   The name and version (`pkgname`, `pkgver`).
    *   The dependencies (`depends=('ctrlr')`). This means the user must install Ctrlr first.
    *   Where to download the source file (`source=...`). This points directly to a `.bpanelz` file.
    *   How to install it (`package()` function). This copies the downloaded panel into the standard Ctrlr panels directory: `/usr/share/ctrlr/panels/AuthorName/`.

---

### **Web Resources (Sorted by Utility/Type)**

Here is a curated list of resources to aid your development. Age is less important than relevance in this niche, but I'll note where things might be dated.

1.  **Official Ctrlr Website & Forum (Primary Resource)**
    *   **Link:** [https://ctrlr.org/](https://ctrlr.org/)
    *   **Summary:** The central hub. You can download the application here. The most valuable part is the forum.
    *   **Forum Link:** [https://ctrlr.org/forums/](https://ctrlr.org/forums/)
    *   **Expert Advice:** The forum is your #1 resource. Search it before asking. There are dedicated sections for panel development, Lua scripting, and bug reports. Many complete panels with open-source code are shared here. You can learn almost everything by dissecting other people's work. It has been active for many years.

2.  **Ctrlr on GitHub (Source Code & Issue Tracking)**
    *   **Link:** [https://github.com/RomanKubiak/ctrlr](https://github.com/RomanKubiak/ctrlr)
    *   **Summary:** The official source code repository. Useful for seeing the latest (sometimes unstable) developments and for reporting deep-level bugs. You can also find forks where other developers have added features.

3.  **Lua Programming Resources (For Scripting)**
    *   **Link:** [https://www.lua.org/pil/contents.html](https://www.lua.org/pil/contents.html) (Programming in Lua, First Edition)
    *   **Summary:** The official book for learning Lua. The first edition is available for free online. Ctrlr uses Lua 5.3, so most of this is directly applicable. You don't need to be a master, but understanding tables, functions, and control structures is essential.

4.  **YouTube Tutorials (Visual Learning)**
    *   **Link:** Search YouTube for "Ctrlr tutorial", "Ctrlr panel tutorial".
    *   **Summary:** There are various tutorials from different creators, often from several years ago, but the core principles of Ctrlr have not changed much. They are excellent for getting a visual walkthrough of adding components and setting up basic MIDI messages.
    *   **Example Channel (dasfaker):** [Link](https://www.youtube.com/user/dasfaker/search?query=ctrlr) - This user has several older but still very relevant videos on creating panels.

5.  **MIDI and SysEx Information**
    *   **Link:** [https://www.midi.org/specifications](https://www.midi.org/specifications)
    *   **Summary:** The official source for MIDI specifications. Can be very dense and technical.
    *   **Link (MIDI-OX):** [http://www.midiox.com/](http://www.midiox.com/)
    *   **Summary:** The de-facto standard MIDI utility for Windows for decades. A must-have for monitoring MIDI traffic and debugging your panel.
    *   **Synth-Specific Forums:** (e.g., Gearspace, Roland Clan, etc.) - Forums dedicated to your target synth are often the best place to find discussions about its SysEx implementation, and sometimes even pre-made SysEx tables.

Start small. Pick a synthesizer you know well, map out 5-10 key parameters, and try to build a mini-panel for just those. Once you have a successful "proof of concept," expand from there.
