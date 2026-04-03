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
%  Tab 5: "Compare" (appears after an operation is applied)
%  ─────────────────────
%  - Pre/post overlay of data before and after a processing step
%  - Two-color rendering: original in blue, processed in red
%  - Difference trace option: shows (post - pre) as a third color
%  - Only available when structure is compatible (see rules below)
%  - Toggle button: [Overlay | Difference | Side-by-side]
%
%  Compare tab — compatibility rules:
%  ─────────────────────────────────────
%  The compare view is only meaningful when the pre and post data have
%  compatible structure. After any operation, check:
%
%    compatible = (pre.nbchan == post.nbchan) && ...
%                 (pre.pnts   == post.pnts)   && ...
%                 (pre.trials == post.trials)  && ...
%                 (pre.srate  == post.srate);
%
%  If compatible:
%    - Store g.EEGpre = <snapshot before operation>
%    - Enable the Compare tab
%    - Overlay mode: plot pre data in blue, post data in red, same axes
%    - Difference mode: plot (post.data - pre.data) in green
%    - Navigation syncs with the Data tab (same time window)
%
%  If NOT compatible (channels added/removed, epochs rejected,
%  re-epoched, resampled):
%    - Compare tab shows message: "Data structure changed —
%      comparison not available (channels: 64→60, epochs: 200→180)"
%    - The tab stays visible but greyed out with an explanation
%    - User can dismiss to free the memory from EEGpre
%
%  Memory management:
%    - g.EEGpre stores a COPY of EEG.data before the operation
%    - This doubles memory use while Compare is active
%    - [Dismiss] button clears g.EEGpre and hides the Compare tab
%    - Auto-cleared when a new non-comparable operation runs
%    - For large datasets, store only the visible window range
%      (lazy comparison: compute diff on-the-fly during scroll)
%
%  When Compare triggers:
%    - APPLY (eeg_eegrej_adv): after interpolation/rejection
%    - QUICKLAB methods: after ICA, BSS, re-reference
%    - TBT: after trial-by-trial rejection
%    - NOT after: navigation, display changes, marking
%
%  Compare draw_data integration:
%    - draw_data checks if Compare tab is active
%    - If active and compatible, draws both datasets:
%      plot(ax1, pre_data, 'Color', [0.3 0.5 0.9], 'LineWidth', 0.5)
%      plot(ax1, post_data, 'Color', [0.9 0.3 0.2], 'LineWidth', 1.0)
%    - The post data is drawn on top (thicker) so changes are visible
%    - Difference mode replaces both with: post - pre
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
%  2e. Add "Compare" tab (hidden until first operation)
%  2f. Tab switching callbacks to manage axes visibility
%
%  Phase 2.5: Pre/Post Comparison
%  ─────────────────────────────────
%  2.5a. Add EEGpre snapshot logic to APPLY, QUICKLAB, TBT, ICLABEL
%  2.5b. Add check_compare_compat() helper
%  2.5c. Add overlay/difference rendering in draw_data
%  2.5d. Add Compare tab UI (mode toggle, dismiss button, status text)
%  2.5e. Add memory management (auto-clear on incompatible operation)
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
%  │   │   ├── erpTab  (uitab, Title 'ERPs')       % conditional
%  │   │   └── compTab (uitab, Title 'Compare')    % appears after operation
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
%% PRE/POST COMPARISON — g STRUCT FIELDS
%% ====================================================================
%
%  New fields added to eegplot_defaults.m:
%
%  g.EEGpre          = []     % Snapshot of EEG before last operation
%  g.compare_mode    = 'off'  % 'off', 'overlay', 'difference'
%  g.compare_compat  = 0      % 1 if pre/post structure matches
%  g.compare_msg     = ''     % Explanation when not compatible
%
%  Snapshot workflow in eegplot_adv_methods.m:
%
%    function g = APPLY(g)
%        g.EEGpre = g.EEG;              % <-- snapshot BEFORE
%        ... apply changes ...
%        g = check_compare_compat(g);   % <-- check after
%    end
%
%    function g = check_compare_compat(g)
%        if isempty(g.EEGpre), return; end
%        pre = g.EEGpre; post = g.EEG;
%        if pre.nbchan == post.nbchan && pre.pnts == post.pnts && ...
%           pre.trials == post.trials && pre.srate == post.srate
%            g.compare_compat = 1;
%            g.compare_msg = sprintf('Showing comparison: %d chans x %d pts', ...
%                post.nbchan, post.pnts);
%        else
%            g.compare_compat = 0;
%            g.compare_msg = sprintf(['Structure changed: chans %d->%d, ' ...
%                'pts %d->%d, epochs %d->%d'], ...
%                pre.nbchan, post.nbchan, pre.pnts, post.pnts, ...
%                pre.trials, post.trials);
%        end
%    end
%
%  Draw integration (in draw_data.m):
%
%    if strcmp(g.compare_mode, 'overlay') && g.compare_compat
%        % Draw pre data in faded blue behind current data
%        predata = g.EEGpre.data;  % or icaact if component view
%        tmp_pre = plotChannel(oldspacing,meandata,predata,g,chans,lowlim,highlim);
%        plot(ax1, tmp_pre', 'Color', [0.3 0.5 0.9 0.4], 'LineWidth', 0.5);
%    elseif strcmp(g.compare_mode, 'difference') && g.compare_compat
%        % Draw difference only
%        diffdata = data - g.EEGpre.data;
%        tmp_diff = plotChannel(oldspacing,zeros(1,g.chans),diffdata,g,chans,lowlim,highlim);
%        plot(ax1, tmp_diff', 'Color', [0.2 0.8 0.3], 'LineWidth', 1.0);
%    end
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
%  - eegplot_tab_components.m (lazy-load component view)
%  - eegplot_tab_spectra.m (lazy-load spectra view)
%  - eegplot_tab_compare.m (pre/post comparison view)
%  - eegplot_check_compare.m (compatibility check helper)
