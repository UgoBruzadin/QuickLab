%% TABBED UI DESIGN - QuickLab eegplot_adv v2.0
%
% This file documents the design for the new tabbed UI layout.
% It replaces the current single-column sidebar of ~50 buttons with
% an organized tabbed interface.
%
% Author: Ugo Bruzadin Nunes + Claude
% Date: 2026-04-03
%
%% ====================================================================
%% FIGURE LAYOUT (top level)
%% ====================================================================
%
%  The figure is divided into two horizontal zones:
%
%  ┌─────────────────────────────────────────┬─────────────────┐
%  │            MAIN PANEL (80%)             │  SIDEBAR (20%)  │
%  │                                         │                 │
%  │  ┌─ Data ──┬─ ICA ──┬─ Spectra ──┐     │  ┌───────────┐  │
%  │  │                                │     │  │ Sidebar   │  │
%  │  │  [axes area]                   │     │  │ TabGroup  │  │
%  │  │                                │     │  │           │  │
%  │  │                                │     │  │           │  │
%  │  └────────────────────────────────┘     │  │           │  │
%  │                                         │  │           │  │
%  │  ┌─ Info Bar ─────────────────────┐     │  │           │  │
%  │  │  [heatmap] [topoplot] [status] │     │  │           │  │
%  │  └────────────────────────────────┘     │  └───────────┘  │
%  │                                         │                 │
%  │  [◄◄] [◄] [position edit] [►] [►►]     │  [Apply] [Save] │
%  └─────────────────────────────────────────┴─────────────────┘
%
%% ====================================================================
%% MAIN PANEL - View Tabs (uitabgroup)
%% ====================================================================
%
%  Tab 1: "Data" (default)
%  ─────────────────────
%  - EEG/ICA scrolling view (current eegplot_adv main axes)
%  - Background axes for rejection patches (ax0)
%  - Data axes for channel traces (ax1)
%  - This is the existing view, just contained in a tab panel
%
%  Tab 2: "Components"
%  ─────────────────────
%  - Component property grid (like pop_viewprops_adv)
%  - Topoplot + scalp map for each component
%  - ICLabel classifications displayed inline
%  - Checkbox per component for rejection
%  - Created on-demand (lazy loading - only when tab is selected)
%
%  Tab 3: "Spectra"
%  ─────────────────────
%  - Channel power spectra (like quick_spectra output)
%  - Topographic frequency maps
%  - Created on-demand
%
%  Tab 4: "ERPs" (only visible for epoched data)
%  ─────────────────────
%  - ERP waveforms by condition
%  - ERP image plots
%  - Created on-demand
%
%  Implementation notes:
%  - Only the "Data" tab is created at startup (fast launch)
%  - Other tabs show a "Click to load" message initially
%  - Tab SelectionChangedFcn triggers lazy loading
%  - Each tab stores its axes handles in the tab's UserData
%
%% ====================================================================
%% NAVIGATION BAR (below main panel)
%% ====================================================================
%
%  This is a fixed bar that stays visible regardless of which tab is active.
%
%  ┌──────────────────────────────────────────────────────────────┐
%  │  [|◄] [◄◄] [◄] [ Position: _____ ] [►] [►►] [►|]  Scale:  │
%  │                                          [___] [+] [-]      │
%  └──────────────────────────────────────────────────────────────┘
%
%  Controls (always visible):
%  - 7 navigation buttons (|<, <<, <, position edit, >, >>, >|)
%  - Scale edit + zoom buttons (+, -)
%  - Channel count display
%  - Slider for vertical scrolling
%
%  These are the most-used controls and must never be hidden in a tab.
%
%% ====================================================================
%% SIDEBAR - Control Tabs (uitabgroup)
%% ====================================================================
%
%  Tab A: "Info"
%  ─────────────────────
%  Current data readouts (from the old sidebar top section):
%  - Channel/Electrode name display
%  - Time/Latency display
%  - Value/Amplitude display
%  - File info: Channels, Frames, Rate, Epochs, Events, ICA status
%  - Current filename and folder browser
%
%  Tab B: "Marks"
%  ─────────────────────
%  Rejection and marking tools (from the old sidebar middle section):
%  - Rejection heatmap (mini matrix view)
%  - Topoplot (scalp map at cursor position)
%  - Mark navigation: [< prev mark] [next mark >]
%  - Count display: "X trials marked, Y channels flagged"
%  - Mode toggles:
%    [Interpolation / Rejection Mode]
%    [Show EEG / Show ICA]
%    [Show Epoch / Hide Epoch]
%  - [Normalize] [Stack/Spread] buttons
%
%  Tab C: "Methods"
%  ─────────────────────
%  Processing pipeline (from the old TBT section):
%  - Library selector: [TBT | QuickLab | ICLabel | Plots]
%  - Method dropdown
%  - Options edit box
%  - Parameter hints
%  - % Trials / # Channels thresholds
%  - [Run] [Clear Marks] buttons
%
%  Tab D: "Actions"
%  ─────────────────────
%  File operations and final actions:
%  - [Apply Changes] button (prominent)
%  - [Transfer to EEGLAB] button
%  - Save text edit + [Save File] button
%  - [FFT] [ICLabel] quick-action buttons
%  - Events button
%
%% ====================================================================
%% STYLING
%% ====================================================================
%
%  Modern flat style:
%  - Figure background: dark blue-grey [0.15 0.16 0.21]
%  - Panel backgrounds: slightly lighter [0.20 0.21 0.26]
%  - Tab backgrounds: match panel
%  - Active tab: accent color strip on top [0.30 0.65 0.90]
%  - Button colors: flat, no 3D bevel
%    - Default: [0.25 0.26 0.31]
%    - Hover: [0.30 0.31 0.36] (if MATLAB supports it)
%    - Active/On: [0.20 0.65 0.35] (green)
%    - Warning/Off: [0.85 0.30 0.25] (red)
%    - Special: [0.90 0.75 0.15] (gold)
%  - Text: white [0.90 0.91 0.92]
%  - Data traces: [0.40 0.50 0.95] (light blue)
%  - Bad channels: [0.95 0.30 0.25] (red)
%  - Axes background: [0.10 0.10 0.14] (near-black)
%  - Grid lines: [0.25 0.25 0.30] (subtle)
%
%  These will be defined in quick_colormode.m under a new 'Modern' theme.
%  Users can switch between 'Default', 'DarkMode', and 'Modern'.
%
%% ====================================================================
%% IMPLEMENTATION PLAN (incremental steps)
%% ====================================================================
%
%  Phase 1: Framework (this branch)
%  ─────────────────────────────────
%  1a. Create the figure with two uipanels (main + sidebar) instead
%      of raw normalized positions
%  1b. Put the data axes (ax0, ax1) inside the main panel
%  1c. Create sidebar uitabgroup with 4 tabs (Info, Marks, Methods, Actions)
%  1d. Move existing controls into the appropriate sidebar tab
%  1e. Create navigation bar as a fixed panel below main axes
%  1f. Verify all existing functionality works in the new layout
%
%  Phase 2: Main Panel Tabs
%  ─────────────────────────
%  2a. Add uitabgroup to main panel with "Data" tab containing axes
%  2b. Add "Components" tab with lazy-loaded ICLabel grid
%  2c. Add "Spectra" tab with lazy-loaded spectopo
%  2d. Add "ERPs" tab (conditional on epoched data)
%  2e. Tab switching callbacks to manage axes visibility
%
%  Phase 3: Modern Styling
%  ─────────────────────────
%  3a. Create 'Modern' color theme in quick_colormode.m
%  3b. Apply flat styling to all controls
%  3c. Custom tab rendering (colored strip instead of Win98 tabs)
%  3d. Clean up font sizes and spacing
%
%  Phase 4: Polish
%  ─────────────────────────
%  4a. Keyboard shortcuts visible in tooltips
%  4b. Status bar at bottom with file info
%  4c. Context menus on right-click
%  4d. Performance optimization (lazy redraw, double buffering)
%
%% ====================================================================
%% MATLAB IMPLEMENTATION DETAILS
%% ====================================================================
%
%  Figure hierarchy:
%
%  figh (figure)
%  ├── mainPanel (uipanel, Position [0.01 0.06 0.78 0.93])
%  │   ├── viewTabs (uitabgroup, Position [0 0.15 1 0.85])
%  │   │   ├── dataTab (uitab, Title 'Data')
%  │   │   │   ├── ax0 (axes, tag 'backeeg')     % background patches
%  │   │   │   └── ax1 (axes, tag 'eegaxis')      % data traces
%  │   │   ├── compTab (uitab, Title 'Components') % lazy loaded
%  │   │   ├── specTab (uitab, Title 'Spectra')    % lazy loaded
%  │   │   └── erpTab  (uitab, Title 'ERPs')       % conditional
%  │   │
%  │   └── navPanel (uipanel, Position [0 0 1 0.14])
%  │       ├── btnFirst, btnPrevPage, btnPrev      % navigation
%  │       ├── editPosition                        % position edit
%  │       ├── btnNext, btnNextPage, btnLast        % navigation
%  │       ├── editScale, btnScaleUp, btnScaleDown  % scale
%  │       └── editNumChans, btnShowAll             % channel count
%  │
%  ├── sidePanel (uipanel, Position [0.80 0.06 0.19 0.93])
%  │   └── sideTabs (uitabgroup)
%  │       ├── infoTab (uitab, Title 'Info')
%  │       │   ├── lblElecName, lblElecValue
%  │       │   ├── lblTime, lblValue
%  │       │   ├── fileInfoGroup (chans, frames, rate, etc.)
%  │       │   └── folderBrowser (popupmenu)
%  │       │
%  │       ├── marksTab (uitab, Title 'Marks')
%  │       │   ├── heatmapAxes (mini rejection matrix)
%  │       │   ├── topoAxes (scalp map)
%  │       │   ├── btnPrevMark, btnNextMark
%  │       │   ├── lblTrialCount, lblChanCount
%  │       │   ├── btnMode (Interp/Reject)
%  │       │   ├── btnSwitch (EEG/ICA)
%  │       │   ├── btnEpoch (Show/Hide)
%  │       │   └── btnNorm, btnStack
%  │       │
%  │       ├── methodsTab (uitab, Title 'Methods')
%  │       │   ├── popLibrary (TBT/QuickLab/ICLabel/Plots)
%  │       │   ├── popMethod (method dropdown)
%  │       │   ├── editOptions (parameter edit)
%  │       │   ├── lblHints (parameter hints)
%  │       │   ├── editTrialPct, editChanCount
%  │       │   └── btnRun, btnClear
%  │       │
%  │       └── actionsTab (uitab, Title 'Actions')
%  │           ├── btnApply (prominent)
%  │           ├── btnTransfer (to EEGLAB)
%  │           ├── editSaveText, btnSave
%  │           ├── btnFFT, btnICLabel
%  │           └── btnEvents
%  │
%  ├── slider (uicontrol, vertical scroll)
%  └── statusBar (uipanel, Position [0 0 1 0.05])
%      └── lblStatus (filename, mode, mark count)
%
%% ====================================================================
%% KEY CONSTRAINTS
%% ====================================================================
%
%  1. The 'backeeg' and 'eegaxis' axes MUST keep their tags
%     because 20+ external functions use findobj('tag','eegaxis')
%     to locate them. The tabs just provide containment.
%
%  2. The figure tag MUST remain 'eegplot_adv' for the same reason.
%
%  3. Mouse callbacks (mouse_down, mouse_up, mouse_motion) are set
%     on the figure, not on axes. This still works with tabs since
%     figure-level callbacks fire regardless of which tab is active.
%
%  4. The g struct stored in figure UserData must be preserved.
%     Tab handles can be stored in g (g.tabs.data, g.tabs.comp, etc.)
%
%  5. uitabgroup requires parent to be a figure or uipanel.
%     Axes inside uitab work fine since R2014b.
%
%  6. Performance: only redraw the active tab's axes.
%     draw_data should check which tab is active and skip if not 'Data'.
%
%% ====================================================================
%% MIGRATION FROM CURRENT UI
%% ====================================================================
%
%  Current control -> New location:
%
%  NAVIGATION (stays in navPanel, always visible):
%    u(46) |<          -> navPanel.btnFirst
%    u(1)  <<          -> navPanel.btnPrevPage
%    u(2)  <           -> navPanel.btnPrev
%    u(5)  Position    -> navPanel.editPosition
%    u(3)  >           -> navPanel.btnNext
%    u(4)  >>          -> navPanel.btnNextPage
%    u(47) >|          -> navPanel.btnLast
%    u(6)  Scale edit  -> navPanel.editScale
%    u(7)  +           -> navPanel.btnScaleUp
%    u(8)  -           -> navPanel.btnScaleDown
%    u(49) NumChans    -> navPanel.editNumChans
%    u(61) Show All    -> navPanel.btnShowAll
%    u(20) Slider      -> kept at figure level
%
%  INFO TAB:
%    u(14) Elec name tag    -> infoTab
%    u(09) Elec value       -> infoTab
%    u(15) Time tag         -> infoTab
%    u(10) Time value       -> infoTab
%    u(16) Value tag        -> infoTab
%    u(11) Value            -> infoTab
%    u(60-69) File info     -> infoTab (chans, frames, epochs, etc.)
%    u(57) Folder browser   -> infoTab
%    u(58) Folder tag       -> infoTab
%
%  MARKS TAB:
%    u(70) < prev mark      -> marksTab
%    u(71) > next mark      -> marksTab
%    u(29) Count trials     -> marksTab
%    u(30) Count channels   -> marksTab
%    u(27) Interp/Reject    -> marksTab
%    u(45) EEG/ICA switch   -> marksTab
%    u(28) Epoch toggle     -> marksTab
%    u(21) Normalize        -> marksTab
%    u(22) Stack/Spread     -> marksTab
%    Topoplot axes          -> marksTab
%    Heatmap axes           -> marksTab
%
%  METHODS TAB:
%    u(25) Library tag       -> methodsTab
%    u(32) Library popup     -> methodsTab
%    u(33) Method popup      -> methodsTab
%    u(34) Options edit      -> methodsTab
%    u(35) Hints text        -> methodsTab
%    u(36) Trial % tag       -> methodsTab
%    u(37) Chan # tag        -> methodsTab
%    u(38) Trial % edit      -> methodsTab
%    u(39) Chan # edit       -> methodsTab
%    u(40) Run button        -> methodsTab
%    u(41) Clear button      -> methodsTab
%
%  ACTIONS TAB:
%    u(60/APPLY) Apply       -> actionsTab (prominent)
%    u(42) Transfer          -> actionsTab
%    u(59) Save text tag     -> actionsTab
%    u(50) Save text edit    -> actionsTab
%    u(58) Save button       -> actionsTab
%    u(54) FFT button        -> actionsTab
%    u(55) ICLabel button    -> actionsTab
%    u(17) Events button     -> actionsTab
%
%% ====================================================================
%% ESTIMATED IMPACT
%% ====================================================================
%
%  Files to modify:
%  - eegplot_create_ui.m  (major rewrite - new tab-based layout)
%  - eegplot_adv.m        (minor - axes creation moves into tab)
%  - quick_colormode.m    (add 'Modern' theme)
%  - draw_data.m          (add active-tab check for performance)
%  - draw_background.m    (add active-tab check)
%  - draw_matrix.m        (render into marksTab axes instead of figure)
%  - mouse_motion.m       (update UI handle references)
%  - eegplot_readkey.m    (update UI handle references)
%
%  Files unchanged:
%  - eegplot_adv_methods.m (processes g struct, UI-agnostic)
%  - All processing/* files
%  - eeg_eegrej_adv.m
%  - plotChannel.m, optim_scale.m, etc.
%
%  New files:
%  - quick_colormode.m additions (Modern theme)
%  - Possibly eegplot_tab_components.m (lazy-load component view)
%  - Possibly eegplot_tab_spectra.m (lazy-load spectra view)
