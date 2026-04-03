% eegplot_adv() - Advanced Data Editor and Scroll (horizontally and/or vertically) through multichannel data.
%             Allows vertical scrolling through channels and manual marking 
%             and unmarking of data stretches or epochs for rejection.
%
%    Significantly modified from pop_eegplot_w(): 
%       
%       - Quickly switch between ICA data and EEG data scroll
%       - Select parts of channels and components interpolation/removal
%       - Has imbued Trial by Trial for channel interpolation and epoch removal
%       - Allow to apply data modifications and observe 
%       - Shows all rejection and interpolations in the data
%       - 
%       - 
%       - 
%    ALL eeglab menu options to the data displayed, Allows you to continue
%    to process file after processing data, allows you to run ICAs/PCAs in
%    the data, remove parts of components,
%    looks even better in wide-screen monitor and draw EEG data even faster!
%    
%
% Usage: 
%           >> eegplot_adv(data, 1, 2, 1, 1, 'key1', value1 ...); % use interface buttons, etc.
%      else
%           >> eegplot_adv('noui', data, 1, 2, 1, 1, 'key1', value1 ...); % no user interface;
%                                                         % use for plotting
% Menu items:
%
%    *NEW*: Copies of ALL EEGLAB menu, except they are modified to use the EEG data in
%    the Adv. Data Editor, and return the EEG data to the Adv. Data Editor.
%    They are dark blue to differentiate from the original menu items.
%
%    "Figure > print" - [menu] Print figure in portrait or landscape.
%    "Figure > Edit figure" - [menu] Remove menus and buttons and call up the standard
%                  Matlab figure menu. Select "Tools > Edit" to format the figure
%                  for publication. Command line equivalent: 'noui' 
%    "Figure > Accept and Close" - [menu] Same as the bottom-right "Reject" button. 
%    "Figure > Cancel and Close" - [menu] Cancel all editing, same as the "Cancel" button. 
%    "Display > Marking color" > [Hide|Show] marks" - [menu] Show or hide patches of 
%                  background color behind the data. Mark stretches of *continuous* 
%                  data (e.g., for rejection) by dragging the mouse horizontally 
%                  over the activity. With *epoched* data, click on the selected epochs.
%                  Clicked on a marked region to unmark it. Called from the
%                  command line, marked data stretches or epochs are returned in 
%                  the TMPREJ variable in the global workspace *if/when* the "Reject" 
%                  button is pressed (see Outputs); called from pop_eegplot() or 
%                  eeglab(), the marked data portions are removed from the current
%                  dataset, and the dataset is automatically updated.
%     "Display > Marking color > Choose color" - [menu] Change the background marking 
%                  color. The marking color(s) of previously marked trials are preserved. 
%                  Called from command line, subsequent functions eegplot2event() or 
%                  eegplot2trials() allow processing trials marked with different colors 
%                  in the TMPREJ output variable. Command line equivalent: 'wincolor'.
%     "Display > Grid > ..." - [menu] Toggle (on or off) time and/or channel axis grids 
%                  in the activity plot. Submenus allow modifications to grid aspects.
%                  Command line equivalents: 'xgrid' / 'ygrid' 
%     "Display > Show scale" - [menu] Show (or hide if shown) the scale on the bottom 
%                  right corner of the activity window. Command line equivalent: 'scale' 
%     "Display > Title" - [menu] Change the title of the figure. Command line equivalent: 
%                  'title'
%     "Settings > Time range to display"  - [menu] For continuous EEG data, this item 
%                  pops up a query window for entering the number of seconds to display
%                  in the activity window. For epoched data, the query window asks
%                  for the number of epochs to display (this can be fractional). 
%                  Command line equivalent: 'winlength'
%     "Settings > Number of channels to display" - [menu] Number of channels to display
%                  in the activity window.  If not all channels are displayed, the 
%                  user may scroll through channels using the slider on the left 
%                  of the activity plot. Command line equivalent: 'dispchans'
%     "Settings > Channel labels > ..."  - [menu] Use numbers as channel labels or load
%                  a channel location file from disk. If called from the eeglab() menu or
%                  pop_eegplot(), the channel labels of the dataset will be used. 
%                  Command line equivalent: 'eloc_file'
%     "Settings > Zoom on/off" - [menu] Toggle Matlab figure zoom on or off for time and
%                  electrode axes. left-click to zoom (x2); right-click to reverse-zoom. 
%                  Else, draw a rectange in the activity window to zoom the display into 
%                  that region. NOTE: When zoom is on, data cannot be marked for rejection.
%     "Settings > Events" - [menu] Toggle event on or off (assuming events have been 
%                  given as input). Press "legend" to pop up a legend window for events.
%
% Display window interface:
%    "Activity plot" - [main window] This axis displays the channel activities.  For 
%                  continuous data, the time axis shows time in seconds. For epoched
%                  data, the axis label indicate time within each epoch.
%    *NEW* 
%    Left click: Select trial for interpolation (green) or removal (red)
%    Right click: Select channel for interpolation. If withing a selected trial, will only highlight that window
%    Middle click (shift click): Show topoplot of that area. If within trial, shows average headmap for that trial.
%                  Keyboard: Z - allows you to select a channel even if there are only selected epochs
%    "Select Methods" - [popup menu] Select choice of methods to apply to the fata from dropdown menu. 
%                  Current options are TBT, QUICKLAB, ICLABEL, and PLOTS
%    "Methods" - [popup menu] a second menu with the list of functions from
%                  each method list to be applied. 
%                  TBT - [menu choice] Choose the function to highlighting which
%                      trials have data that fails to meet a threshold. Current functions are:
%                      Detect Flatline (from AAR), Abnormal Values, Abnormal Trends, 
%                      Improbable Data, Abnormal Distributions, Abnormal Spectra, Mix-Max threshold, 
%                      and Detect Channel Pops (new)
%                  QUICKLAB - [menu choice] Choose the function to be run on
%                      the data: Current options: ICA, BSS EMG, Re-reference,
%                      Reduce headmodel to 94, Reepoch, QuickDotloc, BSS + ICA, DipFit
%               
%                  ICLABEL - [menu choice] Choose one of ICLABEL rejection
%                      functions. Current options: All but brain and other, Brain,
%                      Muscle, Eye, heart, Line Noise, Channel noise, & Other.
%                  PLOTS - [menu choice] Choose one choices to plot.
%                  Spectra+ (FFT), ICLABEL+, and Components ERP
%    "Options" - [edit box] Write options for the selected functions. text
%                  below are hints
%    "% trial 4 rej" - [edit box] threshold percent of trial necessary for the channel to be interpolated
%    "# chans 4 rej" - [edit box] threshold number of channels necessary for epoched to be selected for rejection
%    
%    "RUN" - [button] Runs the function selected from the lists of functions from the list of methods.
%    "Clear Marks" - [button] Clears any selected of trials or channels for
%                  this dataset.
%    "Current Data Marks" - [figure] Shows currently selected epochs,
%                  channels/components for interpolation or rejection.
%                  Legend:
%                      Green bar: epoch selected for partial interpolation.
%                      Red bar: epoch selected for rejection.
%                      Yellow bar: Channel/Component selected for interpolation.
%                      Black dot/bar: Part of channel/component selected for interpolation.
%    "Chan: 0 + 0 part" - [text] display of current number of total and
%                  partial channels selected
%    "Trial: 0 red + 0 green" - [text] display of current number of trials
%                  selected for rejection (red) and partial interpolation (green)
%
%    "Apply Changes" - [button] Interpolates and rejects selected data using function eegrej,
%    saves file with new name addint new suffixes, replots the new data in
%    the data editor.
%    
%    "FFT(avg) - [button] Plots the averaged FFT (QuickLab version) of the current data (not component)
%                 using QuickLab Defaults.
%    "ICLabel" - [button] Runs IClabel (QuickLab version) and plots the components,
%                allows user to select components for rejection
%
%    "SHOW ICA/EEG" - [button] If file has Components run, it shows the component
%    data instead of the EEG data. If ICA is shown, display EEG data instead.
%                  Keyboard: W
%    "HIDE/SHOW EPOCH" - [button] Temporarily removes the epoch display,
%                  for more precise channel interpolation or data rejection.
%    "Interpolation/Rejection Mode" - [button] Allow user to switch between rejecting a trial (red background) 
%                  or selecting a trial for partial interpolation (blue background).
%                  Keyboard: S
%
%    "Select File to Load" - [popup menu] Choose a file from the current folder to load into EEGLAB/Adv. Data Editor
%    "Enter text to add to filename" - [edit box] text entered to be added to the end of the filename
%    "Save to File with Text" - [button] When pressed, saves current dataset adding 
%                  the text entered to the end of the filename.
%    "Transfer to EEGLAB" - [button] transfer current data file and state to EEGLAB
%
%    "Stack/Spread" - [button] "Stack" collapses all channels/activations onto the
%                  middle axis of the plot. "Spread" undoes the operation.
%    "Norm/Denorm" - [button] "Norm" normalizes each channel separately such that all
%                  channels have the same standard deviation without changing original 
%                  data/activations under EEG structure. "Denorm" undoes the operation.
%    "Event types" - [button] pop up a legend window for events.
%    NEW "|<" - [button] Scroll backwards to the beggining of the file.
%       Keyboard: Q
%    "<<" - [button] Scroll backwards through time or epochs by one window length.
%       Keyboard: A
%    "<"  - [button] Scroll backwards through time or epochs by 0.2 window length.
%    "Navigation edit box" - [edit box] Enter a starting time or epoch to jump to.
%    ">"  - [button] Scroll forward through time or epochs by 0.2 window length.
%    ">>" - [button] Scroll forward through time or epochs by one window length.
%       Keyboard: D
%    NEW ">|" - [button] Scroll backwards to the end of the file.
%       Keyboard: E
%    "Chan/Time/Value" - [text] If the mouse is within the activity window, indicates
%                  which channel, time, and activity value the cursor is closest to.
%    "Scale edit box" - [edit box] Scales the displayed amplitude in activity units.
%                  Command line equivalent: 'spacing' 
%    "+ / -" - [buttons] Use these buttons to +/- the amplitude scale by 10%.
%       Keyboard: C / X (it's reversed but intuitive)
%    Removed the "Cancel" - [button] Closes the window and cancels any data
%    rejection marks.
% 
%     Other Keyboard functions:
%     V, B, N, M [keyboard press]: Plot topoplot Avg. Exp. for that bin or selected area
%
%     
%
%                 
% Required command line input:
%    data        - Input data matrix, either continuous 2-D (channels,timepoints) or 
%                  epoched 3-D (channels,timepoints,epochs). If the data is preceded 
%                  by keyword 'noui', GUI control elements are omitted (useful for 
%                  plotting data for presentation). A set of power spectra at
%                  each channel may also be plotted (see 'freqlimits' below).
% Optional command line keywords:
%    'srate'      - Sampling rate in Hz {default|0: 256 Hz}
%    'spacing'    - Display range per channel (default|0: max(whole_data)-min(whole_data))
%    'eloc_file'  - Electrode filename (as in  >> topoplot example) to read
%                    ascii channel labels. Else,
%                   [vector of integers] -> Show specified channel numbers. Else,
%                   [] -> Do not show channel labels {default|0 -> Show [1:nchans]}
%    'limits'     - [start end] Time limits for data epochs in ms (for labeling 
%                   purposes only).
%    'freqs'      - Vector of frequencies (If data contain  spectral values).
%                   size(data, 2) must be equal to size(freqs,2).
%                   *** This option must be used ALWAYS with 'freqlimits' ***                           
%    'freqlimits' - [freq_start freq_end] If plotting epoch spectra instead of data, frequency 
%                   limits to display spectrum. (Data should contain spectral values).
%                   *** This option must be used ALWAYS with 'freqs' ***  
%    'winlength'  - [value] Seconds (or epochs) of data to display in window {default: 10}
%    'dispchans'  - [integer] Number of channels to display in the activity window 
%                   {default: from data}.  If < total number of channels, a vertical  
%                   slider on the left side of the figure allows vertical data scrolling. 
%    'title'      - Figure title {default: none}
%    'plottitle'  - Plot title {default: none}
%    'xgrid'      - ['on'|'off'] Toggle display of the x-axis grid {default: 'off'}
%    'ygrid'      - ['on'|'off'] Toggle display of the y-axis grid {default: 'off'}
%    'ploteventdur' - ['on'|'off'] Toggle display of event duration { default: 'off' }
%    'data2'      - [float array] identical size to the original data and
%                   plotted on top of it.
%
% Additional keywords:
%    'command'    - ['string'] Matlab command to evaluate when the 'REJECT' button is 
%                   clicked. The 'REJECT' button is visible only if this parameter is 
%                   not empty. As explained in the "Output" section below, the variable 
%                   'TMPREJ' contains the rejected windows (see the functions 
%                   eegplot2event() and eegplot2trial()).
%    'butlabel'   - Reject button label. {default: 'REJECT'}
%    'winrej'     - [start end R G B e1 e2 e3 ...] Matrix giving data periods to mark 
%                    for rejection, each row indicating a different period
%                      [start end] = period limits (in frames from beginning of data); 
%                      [R G B] = specifies the marking color; 
%                      [e1 e2 e3 ...] = a (1,nchans) logical [0|1] vector giving 
%                         channels (1) to mark and (0) not mark for rejection.
%    'color'      - ['on'|'off'|cell array] Plot channels with different colors.
%                   If an RGB cell array {'r' 'b' 'g'}, channels will be plotted 
%                   using the cell-array color elements in cyclic order {default:'off'}. 
%    'wincolor'   - [color] Color to use to mark data stretches or epochs {default: 
%                   [ 0.7 1 0.9] is the default marking color}
%    'events'     - [struct] EEGLAB event structure (EEG.event) to use to show events.
%    'submean'    - ['on'|'off'] Remove channel means in each window {default: 'on'}
%    'position'   - [lowleft_x lowleft_y width height] Position of the figure in pixels.
%    'tag'        - [string] Matlab object tag to identify this eegplot_adv() window (allows 
%                    keeping track of several simultaneous eegplot_adv() windows). 
%    'children'   - [integer] Figure handle of a *dependent* eegplot_adv() window. Scrolling
%                    horizontally in the master window will produce the same scroll in 
%                    the dependent window. Allows comparison of two concurrent datasets,
%                    or of channel and component data from the same dataset.
%    'scale'      - ['on'|'off'] Display the amplitude scale {default: 'on'}.
%    'selectcommand' - [cell array] list of 3 commands (strings) to run when the mouse 
%                      button is down, when it is moving and when the mouse button is up.
%    'ctrlselectcommand' - [cell array] same as above in conjunction with pressing the 
%                      CTRL key.
% Outputs:
%    TMPREJ       -  Matrix (same format as 'winrej' above) placed as a variable in
%                    the global workspace (only) when the REJECT button is clicked. 
%                    The command specified in the 'command' keyword argument can use 
%                    this variable. (See eegplot2trial() and eegplot2event()). 
%    EEG          -  EEG data extracted from g.EEG
%
% Author: Arnaud Delorme & Colin Humphries, CNL/Salk Institute, SCCN/INC/UCSD, 1998-2001
% Completely Modified by: Ugo Bruzadin Nunes 2021
% Part of the code was copied and altered from the TBT plugin by Mattan S. Ben-Shachar
%
% See also: eeg_multieegplot(), eegplot2event(), eegplot2trial(), eeglab()
%
% deprecated 
%    'colmodif'   - nested cell array of window colors that may be marked/unmarked. Default
%                   is current color only.
%
% Copyright (C) 2001 Arnaud Delorme & Colin Humphries, Salk Institute, arno@salk.edu
% Copyright (C) 2017 Mattan S. Ben-Shachar
% Copyright (C) 2021 Ugo Bruzadin Nunes ugobruzadin@gmail.com
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% Note for programmers - Internal variable structure:
% All in g. except for Eposition and Eg.spacingwhich are inside the boxes
% gcf
%    1 - winlength
%    2 - srate 
%    3 - children
% 'backeeg' axis
%    1 - trialtag
%    2 - g.winrej
%    3 - nested call flag
% 'eegaxis'
%    1 - data
%    2 - colorlist
%    3 - submean    % on or off, subtract the mean
%    4 - maxfreq    % empty [] if no gfrequency content
% 'buttons hold other informations' Eposition for instance hold the current postition

function [EEG,com] = eegplot_adv(EEG, varargin) % p1,p2,p3,p4,p5,p6,p7,p8,p9)

com = '';

%% Collects component or channel plot, continuous or epoched plot
if isstruct(EEG)
    EEG.varargin = varargin;
%     if ~isfield(EEG,'plotIc')
%         EEG.plotchannels = 1;
%     end
    if ~isfield(EEG,'plotEp')
        EEG.plotEp = 1;
    end
    if ~isfield(EEG, 'plotchannels')
        EEG.plotchannels = 1;
    end
    if EEG.plotchannels == 1
        data = EEG.data;
    else
        if isempty(EEG.icaact)
            data = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
        else
            data = EEG.icaact;
        end
    end
    if EEG.plotEp ~= 1 && size(data,3) > 1
        data = data(:,:);
    end
else
    data = EEG;
end

%% Defaults (can be re-defined):
%EEG.myVariables = {};
DEFAULT_PLOT_COLOR = { [1 1 1], [1 1 1]};         % EEG line color

% try
%   icadefs;
% 	DEFAULT_FIG_COLOR = BACKCOLOR;
% 	BUTTON_COLOR = GUIBUTTONCOLOR;
% catch
% 	DEFAULT_FIG_COLOR = [1 1 1];
% 	BUTTON_COLOR =[0.8 0.8 0.8];
% end

% DEFAULT_FIG_COLOR = [1 1 1];
% BUTTON_COLOR = [0.8 0.8 0.8];
% 
% DEFAULT_AXIS_COLOR = 'k';         % X-axis, Y-axis Color, text Color

% CHANGING COLORS2022 #UGO #COLORS2022

try
    icadefs;
    QuickLabDefs;
catch

    DEFAULT_FIG_COLOR = [0.1 0.1 0.2]; %dark blue fig background
    BUTTON_COLOR = [0.2 0.2 0.2]; % dark grey button
    DEFAULT_ON_COLOR = [0.5 1 0.5]; % green button background
    DEFAULT_OFF_COLOR = [1 0.5 0.5]; % red button background
    DEFAULT_SPECIAL_COLOR = [1 1 0]; % yellow button background
    DEFAULT_SPECIAL_COLOR2 = [1 1 1]; % yellow button foreground
    DEFAULT_AXIS_COLOR = 'w';         % X-axis, Y-axis Color, text Color
    DEFAULT_PLOT_BACKGROUND = [1 1 1];
    DEFAULT_PLOT_INTERP = [0 1 0];
    DEFAULT_PLOT_REJ = [1 0 0];
    DEFAULT_PLOT_LINES = [0 0 0.4]; %darkblue 
    DEFAULT_PLOT_SELECTED = [1 0 0]; %red

end

DEFAULT_GRID_SPACING = 1;         % Grid lines every n seconds
DEFAULT_GRID_STYLE = '-';         % Grid line style
%YAXIS_NEG = 'off';                % 'off' = positive up 
%DEFAULT_NOUI_PLOT_COLOR = 'k';    % EEG line color for noui option
                                  %   0 - 1st color in AxesColorOrder
SPACING_EYE = 'on';               % g.spacingI on/off
%SPACING_UNITS_STRING = '';        % '\muV' for microvolt optional units for g.spacingI Ex. uV
%MAXEVENTSTRING = 10;
%DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842 0.75-(MAXEVENTSTRING-5)/100];
                                  % dimensions of main EEG axes
ORIGINAL_POSITION = [50 50 800 500];
                                  
if nargin < 1
   help eegplot_adv
   return
end
				  
% %%%%%%%%%%%%%%%%%%%%%%%%
%% Setup inputs
% %%%%%%%%%%%%%%%%%%%%%%%%

if ~ischar(data) % If NOT a 'noui' call or a callback from uicontrols

    %% NEW ADDED FEATURE, CLOSES OTHER EEGPLOT_ADV
    otherfigs = findobj('tag','eegplot_adv');
    if ~isempty (otherfigs)
        close(otherfigs);
    end

    %%
   try
       options = varargin;
       if ~isempty( varargin )
           for i = 1:2:numel(options)
               g.(options{i}) = options{i+1};
           end
       else g= [];
       end
   catch
       disp('eegplot_adv() error: calling convention {''key'', value, ... } error'); return;
   end
   
   %% Getting EEG structure from g
   
   if isstruct(EEG)
       g.EEG = EEG;
   end
   
   %% Selection of data range If spectrum plot  
   if isfield(g,'freqlimits') || isfield(g,'freqs')
%        % Check  consistency of freqlimits       
%        % Check  consistency of freqs

       % Selecting data and freqs
       [temp, fBeg] = min(abs(g.freqs-g.freqlimits(1)));
       [temp, fEnd] = min(abs(g.freqs-g.freqlimits(2)));
       data = data(:,fBeg:fEnd,:);
       g.freqs     = g.freqs(fBeg:fEnd);
       
       % Updating settings
       if ndims(data) == 2, g.winlength = g.freqs(end) - g.freqs(1); end 
       g.srate     = length(g.freqs)/(g.freqs(end)-g.freqs(1));
       g.isfreq    = 1;
   end

  %% push button: create/remove window
  % ---------------------------------
  defdowncom   = 'eegplot_adv(''defdowncom'',   gcbf);'; % push button: create/remove window
  defmotioncom = 'eegplot_adv(''defmotioncom'', gcbf);'; % motion button: move windows or display current position
  defupcom     = 'eegplot_adv(''defupcom'',     gcbf);';
  defctrldowncom = 'eegplot_adv(''topoplot'',   gcbf);'; % CTRL press and motion -> do nothing by default
  defctrlmotioncom = ''; % CTRL press and motion -> do nothing by default
  defctrlupcom = ''; % CTRL press and up -> do nothing by default
  
  %% Apply defaults for all g fields (see utils/eegplot_defaults.m)
   g = eegplot_defaults(g, data, EEG);
   
   
   %% continue defaults
   if strcmpi(g.ploteventdur, 'on')
       g.ploteventdur = 1; 
   else
       g.ploteventdur = 0; 
   end
   
   if ndims(data) > 2
       g.trialstag = size(	data, 2);
   end
   
   gfields = fieldnames(g);
   for index=1:length(gfields)
      switch gfields{index}
          case { 'com' 'TBTcom' 'spacing_ch' 'data' 'data_pc' 'e' 'data_ch' 'spacing_pc' 'rand' 'old' 'gnumber' 'typing' 'thinking' 'backcolor' 'EEG' 'winrej' 'winrej_ch' 'winrej_pc' 'srate' 'eloc_file' 'eloc_file_ch' 'eloc_file_pc' 'winlength' 'fullscreen' 'position' 'title' 'plottitle' ...
               'trialstag' 'tag' 'xgrid' 'ygrid' 'color' 'colmodif' 'spacing' 'normed' 'normed_ch' 'normed_pc' 'datastd' 'datastd_ch'  'datastd_pc' ...
               'freqs' 'freqlimits' 'submean' 'children' 'limits' 'matrixpos' 'headpos' 'dispchans' 'wincolor' 'currentoptions' ...
               'maxeventstring' 'ploteventdur' 'butlabel' 'scale' 'events' 'data2' 'plotdata2' 'command'  'command2' 'savecommand' 'savecommand2'...
               'mocap' 'selectcommand' 'ctrlselectcommand' 'envelope' 'isfreq'  'tbtmethods' 'tbtoptions' 'plotmethods' 'plotoptions' 'allevents' 'events_show'}
      otherwise, error(['eegplot_adv: unrecognized option: ''' gfields{index} '''' ]);
      end
   end

   % g.data=data; % never used and slows down display dramatically - Ozgur 2010
   
   if length(g.srate) ~= 1
   		disp('Error: srate must be a single number'); return;
   end
   if length(g.spacing) ~= 1
   		disp('Error: ''spacing'' must be a single number'); return;
   end
   if length(g.winlength) ~= 1
   		disp('Error: winlength must be a single number'); return;
   end
   if ischar(g.title) ~= 1
   		disp('Error: title must be is a string'); return;
   end
   if ischar(g.command) ~= 1
   		disp('Error: command must be is a string'); return;
   end
   if ischar(g.tag) ~= 1
   		disp('Error: tag must be is a string'); return;
   end
   if ischar(g.fullscreen) ~= 1
   		disp('Error: position must be is a 4 elements array'); return;
   end
   if length(g.position) ~= 4
   		disp('Error: position must be is a 4 elements array'); return;
   end
   switch lower(g.xgrid)
	   case { 'on', 'off' }
       otherwise
           disp('Error: xgrid must be either ''on'' or ''off'''); return;
   end
   switch lower(g.ygrid)
	   case { 'on', 'off' }
       otherwise
           disp('Error: ygrid must be either ''on'' or ''off'''); return;
   end
   switch lower(g.submean)
	   case { 'on' 'off' }
       otherwise
           disp('Error: submean must be either ''on'' or ''off'''); return;
   end
   switch lower(g.scale)
	   case { 'on' 'off' }
       otherwise
           disp('Error: scale must be either ''on'' or ''off'''); return;
   end
   
   if ~iscell(g.color)
	   switch lower(g.color)
		case 'on', g.color = { 'k', 'm', 'c', 'b', 'g' }; 
		case 'off', g.color = { DEFAULT_PLOT_LINES };  
		otherwise 
		 disp('Error: color must be either ''on'' or ''off'' or a cell array'); 
                return;
       end
   end
   if length(g.dispchans) > size(data,1)
	   g.dispchans = size(data,1);
   end
   if ~iscell(g.colmodif)
   		g.colmodif = { g.colmodif };
   end
   if g.maxeventstring>20 % JavierLC
        disp('Error: maxeventstring must be equal or lesser than 20'); return;
   end

   % max event string;  JavierLC
   % ---------------------------------
   MAXEVENTSTRING = g.maxeventstring;

   screen_size = get(0,'screensize');
   
   % create an adjustment for screensizes smaller than 1080p
   adj = 0;
   if screen_size(4) < 1080
       adj = -.05;
   else
       adj = 0;
   end

   DEFAULT_AXES_POSITION = [0.045 0.03 0.85+adj 1-(10-4)/100]; %[0.095 0.35 0.842 0.75-(MAXEVENTSTRING-5)/100];
   
   % convert color to modify into array of float
   % -------------------------------------------
   for index = 1:length(g.colmodif)
       if iscell(g.colmodif{index})
           tmpcolmodif{index} = g.colmodif{index}{1} ...
                                  + g.colmodif{index}{2}*10 ...
                                  + g.colmodif{index}{3}*100;
       else
           tmpcolmodif{index} = g.colmodif{index}(1) ...
                                  + g.colmodif{index}(2)*10 ...
                                  + g.colmodif{index}(3)*100;
       end
   end
   g.colmodif = tmpcolmodif;
   
   [g.chans,g.frames, tmpnb] = size(data);
   g.frames = g.frames*tmpnb;
  
  if g.spacing == 0
    g=optim_scale(data,g);
  end

  %% set g defaults
  % ------------ 
  g.incallback = 0;
  g.winstatus = 1;
  g.setelectrode  = 0;
  [g.chans,g.frames,tmpnb] = size(data);   
  g.frames = g.frames*tmpnb;
  g.nbdat = 1; % deprecated
  g.time  = 0;
  g.elecoffset = 0;
  %%
  if EEG.plotchannels == 1
        g.data = data;
        g.data_ch = data;
        if isempty(EEG.icaact)
            EEG.icaact = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
            g.EEG.icaact = EEG.icaact;
            g.data_pc = EEG.icaact;
        else
            g.data_pc = EEG.icaact;
        end
  else
      g.data_ch = data;
        if isempty(EEG.icaact)
            EEG.icaact = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
            g.EEG.icaact = EEG.icaact;
            g.data = EEG.icaact;
            g.data_pc = EEG.icaact;
        else
            data = EEG.icaact;
            g.data = EEG.icaact;
            g.data_pc = EEG.icaact;
        end
  end
  %% Collect winrejs and badchans
  % ------------ 
  if isstruct(EEG)
    % created badchans
    
      if ~isfield(g.eloc_file, 'badchan')
          %if g.EEG.plotchannels == 1
          for ii=1:length(g.eloc_file)
              g.eloc_file(ii).badchan = 0;
          end
      end
      if ~isfield(g.eloc_file_pc, 'badchan')
          if g.eloc_file_pc ~= 0
          %if g.EEG.plotchannels == 1
              for ii=1:length(g.eloc_file_pc)
                  g.eloc_file_pc(ii).badchan = 0;
              end
          end
      end
      if ~isfield(g.eloc_file_ch, 'badchan')
          %if g.EEG.plotchannels == 1
          for ii=1:length(g.eloc_file_ch)
              g.eloc_file_ch(ii).badchan = 0;
          end
      end
    % collects mybadchans and mybadcomps
      if isfield(EEG, 'mybadchan')
          for ch = EEG.mybadchan
              g.eloc_file_ch(ch).badchan = 1;
          end
      end
      %else
      if isfield(EEG, 'mybadcomp')
          for cp = EEG.mybadcomp
              g.eloc_file_pc(cp).badchan = 1;
          end
      end
      % --- still needs work; needs to make sure comps are the same size :/
      % --- collects comprejects from gcompreject

      if isfield(EEG.reject, 'gcompreject')
          if any(EEG.reject.gcompreject)
              mybadcomp2 = find(EEG.reject.gcompreject);
              for ind = 1:size(mybadcomp2,2)
                  try g.eloc_file_pc(mybadcomp2(ind)).badchan = 1; catch; end % marks component as bad
              end
          end
      end
      % --- select which eloc_file to use and collects winrejs

      if g.EEG.plotchannels == 1
          
          g.eloc_file = g.eloc_file_ch;
            
            %g.chans = size(g.eloc_file_ch,2);
            %if g.chans 

          if isfield(EEG,'chanrej')
              g.winrej = EEG.chanrej;
              g.winrej_ch = EEG.chanrej;
              %try g.winrej_pc = EEG.comprej; catch; end
          end
          try g.winrej_pc = EEG.comprej; catch; end
      else
          g.eloc_file = g.eloc_file_pc;
          g.chans = size(g.eloc_file_pc,2);
          if isfield(EEG,'comprej')
              g.winrej = EEG.comprej;
              g.winrej_pc = EEG.comprej;
              %g.winrej_ch = EEG.chanrej;
          end
          try g.winrej_ch = EEG.chanrej; catch; end
      end
  end

 
  %% %%%%%%%%%%%%%%%%%%%%%%%%
  %  Prepare figure and axes
  %  %%%%%%%%%%%%%%%%%%%%%%%%  

  %[ax0, ax1, figh] = prepare_figure(g,data);

  figh = figure('UserData', g,... % store the settings here
      'Color',DEFAULT_FIG_COLOR, 'name', g.title,...
      'MenuBar','none','tag', g.tag ,'Position',g.position, ...
      'numbertitle', 'off', 'visible', 'off', 'Units', 'Normalized',...
      'interruptible', 'off', 'busyaction', 'queue');

  if strcmp(g.fullscreen,'on')
      %figh.WindowState = 'maximized';
      %set(figh,'OuterPosition',[0 0 1 1]);
      set(figh,'OuterPosition',[ 0	0.06	1	0.94]);
      %0.00087	0.072	1	0.8875
  end
  pos = get(figh,'position'); % plot relative to current axes
  q = [pos(1) pos(2) 0 0];
  s = [pos(3) pos(4) pos(3) pos(4)]./100;
  clf;
  
  % Plot title if provided
  if ~isempty(g.plottitle)
      h = findobj('tag', 'eegplottitle'); 
      if ~isempty(h)
          set(h, 'string',g.plottitle);
      else
          h = textsc(g.plottitle, 'title'); 
          set(h, 'tag', 'eegplottitle');
      end
  end
      
  % Background axis
  % --------------- 
  ax0 = axes('tag','backeeg','parent',figh,...
      'Position',DEFAULT_AXES_POSITION,...
      'Box','off','xgrid','off', 'xaxislocation', 'top', 'Units', 'Normalized'); 

  % Drawing axis
  % --------------- 
  YLabels = num2str((1:g.chans)');  % Use numbers as default
  YLabels = flipud(char(YLabels,' '));
  ax1 = axes('Position',DEFAULT_AXES_POSITION,...
      'userdata', data, ...% store the data here
      'tag','eegaxis','parent',figh,...%(when in g, slow down display)
      'Box','on','xgrid', g.xgrid,'ygrid', g.ygrid,...
      'gridlinestyle',DEFAULT_GRID_STYLE,...
      'Xlim',[0 g.winlength*g.srate],...
      'xtick',[0:g.srate*DEFAULT_GRID_SPACING:g.winlength*g.srate],...
      'Ylim',[0 (g.chans+1)*g.spacing],...
      'YTick',[0:g.spacing:g.chans*g.spacing],...
      'YTickLabel', YLabels,...
      'XTickLabel',num2str((0:DEFAULT_GRID_SPACING:g.winlength)'),...
      'TickLength',[.005 .005],...
      'Color','none',...
      'XColor',DEFAULT_AXIS_COLOR,...
      'YColor',DEFAULT_AXIS_COLOR,...
      'FontSize',8);
  
  if ischar(g.eloc_file) || isstruct(g.eloc_file)  % Read in electrode names
      if isstruct(g.eloc_file) && length(g.eloc_file) > size(data,1)
          g.eloc_file(end) = []; % common reference channel location
      end
      eegplot_adv('setelect', g.eloc_file, ax1);
  end
  
     %% NEW ADDED FEATURE, COPY THE MENU ITEMS FROM EEGLAB!
     
     eeglab_menus = findobj('tag','EEGLAB');
     %new_menus = {};
     for i = length(eeglab_menus.Children):-1:1
         if sum(strcmp(eeglab_menus.Children(i).Type,'uimenu'))
             new_menus(i) = copyobj(eeglab_menus.Children(i),findobj('tag','eegplot_adv'),'legacy');
             new_menus(i).ForegroundColor = [0 0 .5];
         end
     end
    
    allnew_menus = findobj(new_menus);

    precallback = ['g = get(findobj(''tag'',''eegplot_adv''),''Userdata''); EEG = g.EEG; fig2 = figure;'];
    postcallback = ['fig = findobj(''tag'',''eegplot_adv''); g = get(fig,''Userdata''); g.EEG = EEG; set(fig,''Userdata'',g); if isempty(fig2.Children), try close(fig2); catch; end; end; eegplot_adv(''RESET'')'];
    
     for j = 1:length(allnew_menus)
         %if strcmp(allnew_menus.Type,'uimenu')
            try 
                if ~isempty(allnew_menus(j).Callback)
                    allnew_menus(j).Callback = [precallback allnew_menus(j).Callback postcallback];
                end
            catch; end
         %end
     end



  %% Set up uicontrols
  % %%%%%%%%%%%%%%%%%%%%%%%%%
  
  div = 0.02 + DEFAULT_AXES_POSITION(2) + DEFAULT_AXES_POSITION(3); % this contains the right end of plot
  max_wi = 1 - div - .005;
  half_wi = max_wi/2;
  un = (max_wi/16);
  heights =      [.02, .015,.03, .04];
  bottoms =      [div,div+half_wi,div+un*2,div+un*5,div+un*11,div+un*14,div+un*4,div+un*3/2];
  widths =       [max_wi/2,max_wi,max_wi/8,3*(max_wi/16),max_wi/4,];
  %heights =      [.02, .015,.03, .04];
  %bottoms =      [.915,.955,.925,.935,.94,.97,0.985,.922];
  %widths =       [.04,.08,.01,.015,.20];

  r = -.01;

% positions of buttons
%                  bottom  left    width    heigth
% numbers go from 1 and end at 47 (need to be reorganized)
  posbut(22,:) = [ bottoms(1)    0.98+r    widths(1)    heights(1) ]; % stack channels(same offset)  
  posbut(21,:) = [ bottoms(1)    0.96+r    widths(1)    heights(1) ]; % normalize
  posbut(17,:) = [ bottoms(1)    0.94+r    widths(1)    heights(1) ]; % events types
  
  posbut(14,:) = [ bottoms(1)    0.90+r    widths(1)    heights(1) ]; % elec tag
  posbut(7,:) =  [ bottoms(1)    0.885+r    widths(1)    heights(1) ]; % elec
  
  posbut(16,:) = [ bottoms(1)    0.86+r    widths(1)    heights(1) ]; % value tag
  posbut(9,:) =  [ bottoms(1)    0.845+r    widths(1)    heights(1) ]; % value
  
  posbut(15,:) = [ bottoms(1)    0.82+r    widths(1)    heights(1) ]; % g.time tag
  posbut(8,:) =  [ bottoms(1)    0.805+r    widths(1)    heights(1) ]; % g.time   

%% New file description texts about the file

  posbut(60,:) = [ bottoms(2)    0.98+r    widths(1)    heights(1) ]; % Number of Channels tag
  posbut(61,:) = [ bottoms(2)    0.965+r    widths(1)    heights(1) ]; % Number of Channels
  
  posbut(62,:) = [ bottoms(2)    0.94+r    widths(1)    heights(1) ]; % Frames/Sampling Rate tag
  posbut(63,:) = [ bottoms(2)    0.925+r    widths(1)    heights(1) ]; % Frames/Sampling Rate

  posbut(64,:) = [ bottoms(2)    0.90+r    widths(1)    heights(1) ]; % Epochs/Events tag
  posbut(65,:) = [ bottoms(2)    0.885+r    widths(1)    heights(1) ]; % Epochs/Events

  posbut(66,:) = [ bottoms(2)    0.86+r    widths(1)    heights(1) ]; % Epoch Start/End tag
  posbut(67,:) = [ bottoms(2)    0.845+r    widths(1)    heights(1) ]; % Epoch Start/End

  posbut(68,:) = [ bottoms(2)    0.82+r    widths(1)    heights(1) ]; %  ICA weights/rank tag
  posbut(69,:) = [ bottoms(2)    0.805+r    widths(1)    heights(1) ]; %  ICA weights/rank
    

  %% New Buttons to navigate identified marks

  posbut(70,:) = [ bottoms(1)    0.48+r    widths(3)    heights(1) ]; %  ICA weights/rank tag
  posbut(71,:) = [ bottoms(6)    0.48+r    widths(3)    heights(1) ]; %  ICA weights/rank

%% Epoch editbox, arrows, scale size, number of channels display

  posbut(5,:) =  [ bottoms(1)    0.78+r    widths(2)    heights(1) ]; % Eposition .52
  posbut(46,:) = [ bottoms(1)    0.76+r    widths(3)        heights(1) ]; % |<<  % NEW UGO
  posbut(1,:) =  [ bottoms(3)    0.76+r    widths(4)        heights(1) ]; % <<  
  posbut(2,:) =  [ bottoms(4)    0.76+r    widths(4)        heights(1) ]; % <  
  posbut(3,:) =  [ bottoms(2)    0.76+r    widths(4)        heights(1) ]; % >
  posbut(4,:) =  [ bottoms(5)    0.76+r    widths(4)        heights(1) ]; % >>  
  posbut(47,:) = [ bottoms(6)    0.76+r    widths(3)        heights(1) ]; % >>|  % NEW UGO

  posbut(23,:) = [ bottoms(1)    0.735+r   widths(1)    heights(1) ]; % Espacing/scale tag
  posbut(6,:) =  [ bottoms(1)    0.72+r    widths(1)    heights(1) ]; % Espacing/scale  

   posbut(48,:) = [ bottoms(2)   0.735+r   widths(1)    heights(1) ]; % NumChan tag % NEW UGO
   posbut(49,:) = [ bottoms(2)   0.72+r    widths(1)    heights(1) ]; % NumChan % NEW UGO

  posbut(52,:) = [ bottoms(2)    0.70+r    widths(1)    heights(1) ]; % Reset chan numbers to max auto % NEW UGO

  posbut(10,:) = [ bottoms(7)    0.70+r    widths(5)    heights(1) ]; % +  
  posbut(11,:) = [ bottoms(1)    0.70+r    widths(5)    heights(1) ]; % -  
  
  posbut(20,:) = [ 0.004   0.02    0.008    0.96 ]; % slider  
  
  % new TBT options #Ugo
  posbut(25,:) = [ bottoms(1)    0.675+r    widths(2)    heights(1) ]; % Title tag
  posbut(31,:) = [ bottoms(3)    0.66+r    1.5*widths(1)    heights(1) ]; % List of methods to run in the data
  posbut(33,:) = [ bottoms(1)    0.63+r    widths(2)    heights(1) ]; % List of Channel/Epoch Methods, drop box, select from list
  posbut(34,:) = [ bottoms(1)    0.60+r    widths(2)    heights(1) ]; % TextBox with options
  posbut(35,:) = [ bottoms(1)    0.58+r    widths(2)    heights(2) ]; % TextBox with option hints!
  posbut(36,:) = [ bottoms(1)    0.545+r    widths(1)    heights(1) ]; % Percent of Trials Tag
  posbut(37,:) = [ bottoms(2)    0.545+r    widths(1)    heights(1) ]; % Number of Channels Tag
  posbut(38,:) = [ bottoms(1)    0.525+r    widths(1)    heights(1) ]; % Percent of Trials box
  posbut(39,:) = [ bottoms(2)    0.525+r    widths(1)    heights(1) ]; % Number of Channels Box
  
  posbut(40,:) = [ bottoms(1)    0.505+r    widths(1)    heights(1) ]; % Run button % run code from box 1 and 2, add data to winrej, redraw
  
  %posbut(32,:) = [ 0.96    0.51+r    widths(1)    defaultsizes(1) ]; % Apply Rejections;
  
  posbut(41,:) = [ bottoms(2)    0.505+r    widths(1)    heights(1) ]; % Clear marks button
  %posbut(50,:) = [ 0.96    0.49+r    0.020    defaultsizes(1) ]; % UNDO BUTTON
  %posbut(53,:) = [ 0.98    0.49+r    0.020    defaultsizes(1) ]; % REDO BUTTON
 
  posbut(24,:) = [ bottoms(1)    0.48+r    widths(2)    heights(1) ]; % Topoplot tag

  %this doesnt do anything, just a place so I can remember what the
  %positions are, if I change up top I'll have to change here.
  g.headpos =     [ bottoms(8)   0.35+r      0.075    0.13 ]; %position of topoplot
  g.matrixpos =   [ bottoms(1)    0.35+r      widths(2)    0.13 ];  %position of matrix
 
  posbut(30,:) = [ bottoms(1)    0.32+r    widths(2)    heights(1) ]; % Counting marks tag #Ugo
  posbut(29,:) = [ bottoms(1)    0.30+r    widths(2)    heights(1) ]; % Counting marks #Ugo

  posbut(32,:) = [ bottoms(1)    0.28+r    widths(2)    heights(1) ]; % Apply Rejections;
  % deprecated
  %posbut(26,:) = [ 0.93    0.25    widths(2)    defaultsizes(1) ]; % Plot data difference #Ugo
% original = works
  
  posbut(54,:) = [ bottoms(1)    0.255+r    widths(1)    heights(1) ]; % plot FFT
  posbut(55,:) = [ bottoms(2)    0.255+r    widths(1)    heights(1) ]; % plot ICA headmaps
  %posbut(56,:) = [ bottoms(1)    0.43    widths(1)    defaultsizes(1) ]; % plot AVG FFT

   posbut(51,:) = [ bottoms(1)    0.23+r    widths(2)    heights(1) ]; % Epoched/Continuous Mode
   posbut(28,:) = [ bottoms(1)    0.21+r    widths(2)    heights(1) ]; % Rejecting/Interpolating Mode  
   posbut(27,:) = [ bottoms(1)    0.19+r    widths(2)    heights(1) ]; % Components/EEG SWITCH FUNCTION

% rotated  new vertical buttons
%   posbut(51,:) = [ 0.01    0.80    0.015    0.15 ]; % Components/EEG SWITCH FUNCTION  
%   posbut(28,:) = [ 0.01    0.625    0.015    0.17 ]; % Epoched/Continuous Mode
%   posbut(27,:) = [ 0.01    0.45    0.015    0.17 ]; % Rejecting/Interpolating Mode 
   
  posbut(57,:) = [ bottoms(1)    0.14+r    widths(2)    heights(1) ]; % Folder dropmenu
  posbut(58,:) = [ bottoms(1)    0.16+r    widths(2)    heights(1) ]; % Folder tag

   %posbut(59,:) = [ bottoms(1)    0.15    widths(2)    defaultsizes(2) ]; % Components/EEG SWITCH FUNCTION
  
  %posbut(43,:) = [ bottoms(1)    0.15    widths(2)    defaultsizes(2) ]; % RUN, TAG AND SAVE
  posbut(59,:) = [ bottoms(1)    0.11+r    widths(2)    heights(1) ]; % Save text tag
  posbut(44,:) = [ bottoms(1)    0.09+r    widths(2)    heights(1) ]; % SAVE TEXT EDIT

  posbut(45,:) = [ bottoms(1)    0.06+r    widths(2)    heights(1) ]; % SAVE FILE BUTTON
  posbut(42,:) = [ bottoms(1)    0.04+r    widths(2)    heights(1) ]; % store marks, transfer to eeglab #Ugo
  posbut(13,:) = [ bottoms(2)    0.02+r    widths(1)    heights(1) ]; % cancel/close

  %posbut(12,:) = [ bottoms(1)    0.02    widths(2)    defaultsizes(2) ]; % accept/close
  
%% NEW TEXT FOR THE CURRENT EEGLAB FILE
        
u(60) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(60,:),'Style','text','FontSize',8,...
	'Tag','Number of Channels tag','BackgroundColor',DEFAULT_FIG_COLOR,'string','Chans - Ref');

u(61) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(61,:),'Style','text','FontSize',10,...
	'Tag','Number of Channels','BackgroundColor',DEFAULT_FIG_COLOR,'string',[num2str(EEG.nbchan),' - ',EEG.ref]);

u(62) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(62,:),'Style','text','FontSize',8,...
	'Tag','Frames tag','BackgroundColor',DEFAULT_FIG_COLOR,'string','Frames - Rate');

u(63) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(63,:),'Style','text','FontSize',10,...
	'Tag','Frames','BackgroundColor',DEFAULT_FIG_COLOR,'string',[num2str(EEG.pnts),' - ',num2str(EEG.srate)]);

u(64) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(64,:),'Style','text','FontSize',8,...
	'Tag','Epochs tag','BackgroundColor',DEFAULT_FIG_COLOR,'string','Epochs-Events');

u(65) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(65,:),'Style','text','FontSize',10,...
	'Tag','Epochs','BackgroundColor',DEFAULT_FIG_COLOR,'string',[num2str(EEG.trials),' - ',num2str(size(EEG.event,2))]);

u(66) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(66,:),'Style','text','FontSize',8,...
	'Tag','Epochs time tag','BackgroundColor',DEFAULT_FIG_COLOR,'string','[Start End]');

u(67) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(67,:),'Style','text','FontSize',10,...
	'Tag','Epochs time','BackgroundColor',DEFAULT_FIG_COLOR,'string',['[',num2str(EEG.xmin),' ', num2str(EEG.xmax),']']);

u(68) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(68,:),'Style','text','FontSize',8,...
	'Tag','ICA weights tag','BackgroundColor',DEFAULT_FIG_COLOR,'string','ICA - Rank');

if ~isempty(EEG.icaact)
    tmpdata = reshape( EEG.data(1:EEG.nbchan,:,:), EEG.nbchan, EEG.pnts*EEG.trials);
    tmpdata = tmpdata - repmat(mean(tmpdata,2), [1 size(tmpdata,2)]); % zero mean
    tmprank = getrank(tmpdata(:,1:min(3000, size(tmpdata,2))));

    icatext = [num2str(size(EEG.icaact,1)),' - ', num2str(tmprank)];
else
    icatext = 'no';
end

u(69) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(69,:),'Style','text','FontSize',10,...
	'Tag','ICA weights','BackgroundColor',DEFAULT_FIG_COLOR,'string',icatext);

%% NEW BUTTONS SAVE AND LOAD
% load directory
%loaddircommand = ['findex = [1];try cd(EEG.filepath); catch, end; filecount = [1];files = dir(''*.set'');findex = find(strcmp({files.name}, EEG.filename));files = dir(''*.set'');set(findobj(''tag'',''FolderList''),''string'',{files(1:end).name},''value'',find(strcmp({files.name}, EEG.filename)));'];
% filelist
loadfilecommand = ['try cd(EEG.filepath); catch, end;files = dir(''*.set''); newEEG = pop_loadset(files(get(findobj(''tag'',''FolderList''),''value'')).name, pwd);[EEG,com] = pop_eegplot_adv(newEEG, 1, 2, 1, 1);[ALLEEG newEEG CURRENTSET] = eeg_store(ALLEEG, newEEG, CURRENTSET);'];

u(59) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(59,:),'Style','text','FontSize',8,...
	'Tag','save_file_title','BackgroundColor',DEFAULT_FIG_COLOR,'string','Enter Text to Add to Filename');

u(58) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(58,:),'Style','text','FontSize',8,...
	'Tag','load_dir_title','BackgroundColor',DEFAULT_FIG_COLOR,'string','Load File From This Folder');

u(57) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(57,:),'Style','popupmenu',...
    'Tag','FolderList','string','',    'callback',loadfilecommand);
load_directory(EEG,figh)
%eval(loaddircommand); % loads the folder of the file

%% Channel rejection callbacks
% get channels for partial interpolation
chaninterp = ['EEG.myVariables{1} = get(findobj(gcf, ''Tag'', ''Channel''),''string'');']; 
% select plot difference
plotdiffcom = ['EEG.myVariables{2} = get(findobj(gcf, ''Tag'', ''datadiff''),''Value'');'];
% get channels for complete interpolation
chaninterp2 = ['EEG.myVariables{3} = get(findobj(gcf, ''Tag'', ''Removal''),''string'');'];

displayep = ['eegplot_adv(''redraw'');'];
togglerej = ['eegplot_adv(''rejection'');'];
displaycomp = ['EEG.plotEp = 1 - EEG.plotEp; eegplot_adv(EEG,varargin);'];

%% --- start trial by trial options
% 

u(54) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(54,:),'Style','pushbutton',...
	'Tag','plotFFT','string','FFT(avg)','callback',['g = get(gcf,''UserData''); quick_spectra(g.EEG,40,2,''AVG'');']);

ICLcommand = ['g = get(gcf,''UserData''); [EEG,com] = quick_IClabel(g.EEG,[],[],[],[],[''eegplot_adv(''''MERGE_REJECTION'''');'']);'];

u(55) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(55,:),'Style','pushbutton',...
	'Tag','plotICLABEL','string','IClabel','callback',ICLcommand);

u(50) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(44,:),	'Style','edit', ...
	'Tag','SaveNowText','BackgroundColor',DEFAULT_PLOT_BACKGROUND,'string','');

    u(58) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(45,:),'Style','pushbutton',...
	'Tag','SaveNowButton','string','Save File with Text','callback',['eegplot_adv(''SAVE'');']);

%% heatmap title
  u(24) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(24,:),'Style','text','FontSize',8, ...
	'Tag','headmap','BackgroundColor',DEFAULT_FIG_COLOR,'string','Current Data Marks','TooltipString', ...
    ['Red lines: Rejected epochs',newline,...
    'Green lines: Epochs selected for partial interpolation',newline,...
    'Yellow lines: Channels/Components selected for interpolation/rejection',newline,...
    'Black dots: Parts of channels selected for interpolation or highlighted during rejection']);

%% TBT part modified from pop_TBT() scripts
if isstruct(EEG)
QuickLabDefs;

    g.eegmethods = ['ICA|',...
        'BSS EMG (AAR)|',...
        'Re-reference|'...
        'Re-epoch|'...
        'DipFit (par)|' ...
        'Any Script'];

    g.eegoptions = {...
        ['[], ''' ICATYPE ''' , 0'],...
        ['components, icatype, display'],...
        'quick_pca';...
        ...
        [''],...
        'window, windowshift',...
        'quick_bss2';...
        ...
        [' "AVG" '],...
        'choose reference(s)',...
        'quick_reref';...
        ...
        '0.600,2.648',...
        'time 1, time 2',...
        'quick_epoch';...
        ...
        ['[],1'],...
        '[components], dipoles',...
        'quick_dipfit';...
        ...
         [''],...
        'run any script',...
        '';...
        ...
        };

% g.eegoptions = {...
%         ['[], ''' ICATYPE ''' , 0'],...
%         ['components, icatype, display'],...
%         'quick_pca';...
%         ...
%         [''],...
%         'window, windowshift',...
%         'quick_bss2';...
%         ...
%         [' "AVG" '],...
%         'choose reference(s)',...
%         'quick_reref';...
%         ...
%         '',...
%         'remove surrounding channels',...
%         'quick_HM94';...
%         ...
%         '0.600,2.648',...
%         'time 1, time 2',...
%         'quick_epoch';...
%         ...
%         [''],...
%         'HM92, epoch [.6 2.658], ICA',...
%         '';...
%         ...
%         [''],...
%         'BSS + ICA',...
%         '';...
%         ...
%         ['[],1'],...
%         '[components], dipoles',...
%         'quick_dipfit';...
%         ...
%         [''],...
%         'ICA + ICL.8 + BSS + ICA',...
%         '';...
%         ...
%         };

    g.iclmethods = ['All but Brain and Other|' ...
        'Brain|'...
        'Muscle|'...
        'Eye|'...
        'Heart|'...
        'Line noise|'...
        'Channel noise|'...
        'Other'];

    g.icloptions = {...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .3 0 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        [' .8 1 '],...
        ['min max'],...
        '';...
        ...
        };

    g.tbtmethods = ['Abnormal values|'...
        'Abnormal trends|'...
        'Improbable data|'...
        'Abnormal distributions|'...
        'Abnormal spectra|'...
        'Max-Min Threshold|'...
        'Detect Flatline (cleanline)|' ...
        'Detect Channel Pops (by Ugo)'];
    
    g.tbtoptions = {...
        ['[1:57,59,60],-150 , 150 ,' num2str(EEG.xmin) ' , ' num2str(EEG.xmax)],...
        'chans,low/up thresh, starttime, endtime',...
        'pop_eegthresh';...
        ...
        ['[1:57,59,60],',num2str(EEG.pnts) ' , 0.5 , 0.3'],...
        'chans,winsize, maxslope, minR',...
        'pop_rejtrend';...
        ...
        '[1:57,59,60],3 , 3',...
        'chans,locthresh, globthresh',...
        'pop_jointprob';...
        ...
        '[1:57,59,60],3 , 3',...
        'chans,locthresh, globthresh',...
        'pop_rejkurt';...
        ...
        ['[1:57,59,60],''method'' , ''FFT'' , ''threshold'' , [-70 , 15] ,''freqlimits'' , [20 , 55]'],...
        'chans,th in Db, limits in Hz >34',...
        'pop_rejspec';...
        ...
        ['[1:57,59,60],[1:' num2str(EEG.nbchan) '],[' num2str([EEG.xmin EEG.xmax]*1000) '],100,' num2str([EEG.xmax - EEG.xmin]*1000) ',1,0'],...
        'chans,chRange,timeRange,minmaxThresh,winSize,stepSize,maW',...
        'pop_eegmaxmin';...
        ...
        ['[1:57,59,60],5, 20'],...
        ['chans,fl duration, max jitter'],...
        '';...
        ...
        ['[1:57,59,60],{5, 8, 100, 2, [],''mean''}'],...
        ['chans,SumWindow, StdRej, max rej win, Chancomps, type'],...
        '';...
        };
else
    g.tbtmethods = {'0','0'};
    g.tbtoptions = {'0','0'};
end

    g.plotmethods = ['Plot Spectra|' ...
        'Plot IClabel|'...
        'Plot Component ERPs'];
    
    g.plotoptions = {...
        ['40, 2, []'],...
        ['lowpass, highpass, reference'],...
        '';...
        ...
        ['[]'],...
        'components, lowpass, highpass',...
        '';...
        ...
        ['{2,[],[]}'],...
        'type, reference, project to channel',...
        '';...
        };

g.allmethods = ['TBT|' ...
        'QUICKLAB|'...
        'ICLABEL|' ...
        'QUICKLAB PLOTS'];

g.currentoptions = g.tbtoptions;

% Choose Methods tag
  u(25) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(25,:),'Style','text','FontSize',8, ...
	'Tag','ListTag','BackgroundColor',DEFAULT_FIG_COLOR,'string','Select Library of Functions');

% Functions Library
  u(32) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(31,:),'Style','popupmenu','HorizontalAlignment', 'center','FontSize',10,...
    'Tag','ListPopup','BackgroundColor',DEFAULT_PLOT_BACKGROUND,'string',g.allmethods,'callback',@change_list,'TooltipString','Select a library of functions');

% methods
  u(33) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(33,:),'Style','popupmenu',...
	'Tag','ALLmethods','BackgroundColor',DEFAULT_PLOT_BACKGROUND,'string',g.tbtmethods,'callback',@change_options,'TooltipString','Select a function of the chosen library');

% options
  u(34) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(34,:),'Style','edit',...
	'Tag','ALLoptions','BackgroundColor',DEFAULT_PLOT_BACKGROUND,'string',g.tbtoptions{1},'TooltipString','Options for the selected function');

% options hints
  u(35) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(35,:),'Style','text','FontSize',8,...
    'Tag','ALLhints','BackgroundColor',DEFAULT_FIG_COLOR,'string',g.tbtoptions{1,2},'TooltipString',['Hints for the function options,',newline,g.tbtoptions{1,2}]);
% hint

% tag
  u(36) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(36,:),'Style','text','FontSize',8,...
	'Tag','TBT%tag','BackgroundColor',DEFAULT_FIG_COLOR,'string','% Trials 4 rej.','TooltipString','Minimal percentage of trials necessary for a channel to be selected for rejection');

  u(37) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(37,:),'Style','text','FontSize',8,...
	'Tag','TBTnchanstag','BackgroundColor',DEFAULT_FIG_COLOR,	'string','# Chans 4 rej.','TooltipString','Minimal number of channels necessary for a trial to be selected for rejection');

  u(38) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(38,:),'Style','edit',...
	'Tag','TBT%','BackgroundColor',DEFAULT_PLOT_BACKGROUND,'string','60');

  u(39) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(39,:), 'Style','edit',...
	'Tag','TBTnchans','BackgroundColor',DEFAULT_PLOT_BACKGROUND, 'string','1');	

  u(40) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(40,:), ...
    'Tag','TBT','BackgroundColor',DEFAULT_OFF_COLOR,'string','Run','Callback', 'eegplot_adv(''METHODS'');' );

  u(60) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(32,:), ...
	'Tag','APPLY','BackgroundColor',DEFAULT_OFF_COLOR,'string','Apply Changes',	'Callback', ['eegplot_adv(''APPLY'');'] );

  %posbut(32
  u(41) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(41,:),...
	'Tag','ClearMarks','BackgroundColor',DEFAULT_OFF_COLOR,'string','Clear Marks','Callback', ['eegplot_adv(''ClearMarks'');']);

%% Save, Tag and ICA attempts #Ugo 5/27/2022
% u(43) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(43,:),
% 	'Tag','SaveTagICA', 'BackgroundColor',[.5 1 0.5],'string','Tag, Save & ICA','Callback', ['eegplot_adv(''saveandtag'')'] );

g.scripts = ['BSS|' ...
        'ICA|'...
        'Reference|'...
        'Epoch|'...
        'Channel Reduction'];

if g.EEG.plotchannels == 1
    cmodecolor = DEFAULT_ON_COLOR;
    cmode = 'Show ICA'; 
else
    cmodecolor = DEFAULT_OFF_COLOR;
    cmode = 'Show EEG'; 
end

u(45) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(51,:),...
	'Tag','SWITCH','BackgroundColor',cmodecolor,'string',cmode,'Callback', ['eegplot_adv(''SWITCH'');']);

% u(46) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(50,:), ...
% 	'Tag','UNDO', 'BackgroundColor',[.7 .7 1],'string','Undo','Callback', ['eegplot_adv(''UNDO'')']);
% 
% u(47) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(53,:),'Tag','REDO','BackgroundColor',[.7 .7 1],'string','Redo','Callback', ['eegplot_adv(''REDO'')']);

%% channel or epoch, rejection or interpolation buttons #Ugo

 u(27) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(27,:),...
	'Tag','Rejection','BackgroundColor',DEFAULT_ON_COLOR,'string','Interpolation Mode','Callback', togglerej);

if g.trialstag == -1
    modecolor = DEFAULT_OFF_COLOR;
    mode = 'Show Epoch';
else
    modecolor = DEFAULT_ON_COLOR;
    mode = 'Hide Epoch';
end

 u(28) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(28,:),...
	'Tag','Display', 'BackgroundColor',modecolor,'string',mode,'Callback', displayep );

%% number of marked areas for control #Ugo

  u(29) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(29,:),'Style','text','FontSize',8,...
	'Tag','Count_Trials','BackgroundColor',DEFAULT_FIG_COLOR,'string','');

  u(30) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(30,:),'Style','text','FontSize',8,...
	'Tag','Count_Channels','BackgroundColor',DEFAULT_FIG_COLOR,'string','');

%% arrows to move between marked winrej

  u(70) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(70,:),'Style','pushbutton','FontSize',8,...
	'Tag','GoBackWinrej','BackgroundColor',DEFAULT_FIG_COLOR,'string','<','Callback',{@draw_data,figh,11,[],[],ax1});

  u(71) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(71,:),'Style','pushbutton','FontSize',8,...
	'Tag','GoForwardWinrej','BackgroundColor',DEFAULT_FIG_COLOR,'string','>','Callback',{@draw_data,figh,12,[],[],ax1});

%% plot data difference checkbox

% u(26)= uicontrol('Parent',figh, ...
% 	'Units', 'normalized', ...
% 	'BackgroundColor',DEFAULT_PLOT_BACKGROUND, ...
% 	'Position', posbut(26,:), ...
% 	'Style','checkbox', ...
% 	'FontSize',8,...
% 	'Tag','datadiff',...
% 	'string','plot Data Difference',...
%     'Callback', plotdiffcom );

%% Five move buttons: |< << < text > >> >|
% NEW: GOES TO THE BEGGINING % UGO
  u(46) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(46,:),'FontSize',8,...
	'Tag','Pushbutton0','string','|<','Callback',{@draw_data,figh,8,[],[],ax1});

  u(1) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(1,:),'FontSize',8,...
	'Tag','Pushbutton1','string','<<','Callback',{@draw_data,figh,1,[],[],ax1});

  u(2) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(2,:), ...
	'Tag','Pushbutton2','string','<','Callback',{@draw_data,figh,2,[],[],ax1});

  u(5) = uicontrol('Parent',figh,'Units', 'normalized',	'Position', posbut(5,:),'Style','edit',...
	'Tag','EPosition','BackgroundColor',DEFAULT_PLOT_BACKGROUND,'string', fastif(g.trialstag(1) == -1, '0', '1'),'Callback', {@draw_data,figh,0,[],[],ax1});

  u(3) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(3,:), ...
	'Tag','Pushbutton3','string','>','Callback',{@draw_data,figh,3,[],[],ax1});

  u(4) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(4,:),'FontSize',8, ...
	'Tag','Pushbutton4','string','>>','Callback',{@draw_data,figh,4,[],[],ax1});

  % NEW GO TO THE END #UGO
  u(47) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(47,:), 'FontSize',8,...
	'Tag','Pushbutton5','string','>|','Callback',{@draw_data,figh,7,[],[],ax1});

%% Channels, position, value and tag
% Values of time/value and freq/power in GUI
  if g.isfreq
      u15_string =  'Freq';
      u16_string  = 'Power';
  else
      u15_string =  'Time';
      u16_string  = 'Value';
  end
      
  u(48)= uicontrol('Parent',figh,'Units','normalized','Position', posbut(48,:),'Style','text','FontSize',8,...
	'Tag','NumChansTag','BackgroundColor',DEFAULT_FIG_COLOR,'string','Chan Display');

  u(23)= uicontrol('Parent',figh,'Units','normalized','Position', posbut(23,:),'Style','text','FontSize',8,...
	'Tag','thescale','BackgroundColor',DEFAULT_FIG_COLOR,'string','Scale');

  u(15) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(15,:),'Style','text','FontSize',8,...
	'Tag','Etimename','BackgroundColor',DEFAULT_FIG_COLOR,'string',u15_string);

  u(16) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(16,:),'Style','text','FontSize',8,...
	'Tag','Evaluename','BackgroundColor',DEFAULT_FIG_COLOR,'string',u16_string);

  u(14) = uicontrol('Parent',figh,'Units','normalized','Position', posbut(14,:),'Style','text','FontSize',8,...
	'Tag','Eelecname','BackgroundColor',DEFAULT_FIG_COLOR,'string','Chan/Comp');

  u(09) = uicontrol('Parent',figh,'Units','normalized','Position', posbut(7,:),'Style','text','FontSize',10, ...
	'Tag','Eelec','string',' ','BackgroundColor',DEFAULT_FIG_COLOR);

  u(10) = uicontrol('Parent',figh,'Units','normalized','Position', posbut(8,:),'Style','text','FontSize',10,...
	'Tag','Etime','BackgroundColor',DEFAULT_FIG_COLOR,'string','0.00');

  u(11) = uicontrol('Parent',figh,'Units','normalized','Position', posbut(9,:),'Style','text','FontSize',10, ...
	'Tag','Evalue','BackgroundColor',DEFAULT_FIG_COLOR,'string','0.00');

%% Text edit fields: NumChans

  u(49) = uicontrol('Parent',figh, ...
	'Units', 'normalized','Position', posbut(49,:),'Style','edit', ...
	'Tag','NumChan','BackgroundColor',DEFAULT_PLOT_BACKGROUND,'string',num2str(g.chans),'Callback', 'eegplot_adv(''winelec_text'')' );

  %% Text edit fields: ESpacing
    u(6) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(6,:),'Style','edit', ...
    'Tag','ESpacing','BackgroundColor',DEFAULT_PLOT_BACKGROUND,'string',num2str(g.spacing),'Callback', {@change_scale,figh,0,ax1} );

%% Slider for vertical motion
  u(20) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(20,:),'Style','slider', ...
   'visible', 'off','sliderstep', [0.9 1],'Tag','eegslider',...
   'callback',{@draw_data,figh,0,[],[],ax1,'g.elecoffset = get(gcbo, ''value'')*(g.chans-g.dispchans);'}, ...
   'value', 0);


%% ESpacing buttons: + -
  u(7) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(10,:), ...
	'Tag','Pushbutton5','string','+','FontSize',10,'Callback',{@change_scale,figh,1,ax1});

  u(8) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(11,:), ...
	'Tag','Pushbutton6','string','-','FontSize',10,'Callback',{@change_scale,figh,2,ax1});
  
  u(61) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(52,:), ...
	'Tag','Pushbutton6','string','Show All','FontSize',10,'Callback',['eegplot_adv(''winelec_auto'')']);

%% Button for Normalizing data
u(21) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(21,:), ...
    'Tag','Norm','string','Norm', 'callback', {@normalize_chan,figh});

cb_envelope = ['g = get(gcbf,''userdata'');'...
    'hmenu = findobj(gcf, ''Tag'', ''Envelope_menu'');' ...
    'g.envelope = ~g.envelope;' ...
    'set(gcbf,''userdata'',g);'...
    'set(gcbo,''string'',fastif(g.envelope,''Spread'',''Stack''));' ...
    'set(hmenu, ''Label'', fastif(g.envelope,''Spread channels'',''Stack channels''));' ...
    'eegplot_adv(''drawp'',0);clear g;'];

%% Button to plot envelope of data
u(22) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(22,:), ...
    'Tag','Envelope','string','Stack', 'callback', cb_envelope);

  if isempty(g.command) tmpcom = 'fprintf(''Rejections saved in variable TMPREJ\n'');';   
  else tmpcom = g.command;
  end
  closecommand = ['g = get(gcbf,''userdata''); EEG = g.EEG; if g.children, delete(g.children); end'...
                 'delete(gcbf);' ...
                 'eval(get(findobj(''tag'',''LoadDir''),''Callback''));' ...
                 'eval(get(findobj(''tag'',''LoadFileList''),''Callback''));'];

  acceptcommand = [ 'g = get(gcbf, ''userdata'');' ... 
                    'TMPREJ = g.winrej;' ...
                    'if isfield(g, ''eloc_file'') && isfield(g.eloc_file, ''badchan''); '...
                         'TMPREJCHN = find([g.eloc_file.badchan]); '...
                    'else TMPREJCHN = [];'...
                    'end ' ...
                          closecommand ...
		  				  tmpcom ...
                    '; clear g;']; % quitting expression
  if ~isempty(g.command)
% 	  u(12) = uicontrol('Parent',figh, ...
% 						'Units', 'normalized', ...
% 						'Position',posbut(12,:), ...
% 						'Tag','Accept',...
% 						'string',g.butlabel, 'callback', acceptcommand);
  end

%   Commented/deprecated the close button for UX purposes
%   u(13) = uicontrol('Parent',figh, ...
% 	'Units', 'normalized', ...
% 	'Position',posbut(13,:), ...
% 	'string',fastif(isempty(g.command),'CLOSE', 'CLOSE'), 'callback', ...
% 		[	'g = get(gcbf, ''userdata'');' ...
%             'if g.children, delete(g.children); end;' ...
% 			'close(gcbf);'] );

% save button #Ugo
if isempty(g.command) 
    tmpsavecom = 'fprintf(''Rejections saved in variable TMPREJ\n'');';   
else 
    if g.EEG.plotchannels == 1
        tmpsavecom = g.savecommand;
    else
        tmpsavecom = g.savecommand2;
    end
end
  savecommand = [ 'g = get(gcbf, ''userdata'');' ...  
                'TMPEEG = g.EEG;' ...
                    'TMPREJ = g.winrej;' ...
                    'if isfield(g, ''eloc_file'') && isfield(g.eloc_file, ''badchan''); '...
                         'TMPREJCHN = find([g.eloc_file.badchan]); '...
                    'else TMPREJCHN = [];'...
                    'end; ' ...
		  				  tmpsavecom]; % quitting expression
                      
  if ~isempty(g.savecommand)
    
      u(42) = uicontrol('Parent',figh,'Units', 'normalized','Position', posbut(42,:), ...
	   'Tag','SaveButton', 'BackgroundColor',[.5 1 0.5],'string','Transfer to EEGLAB','Callback', savecommand );

  end

 acceptandsavecommand = [savecommand acceptcommand];

  if ~isempty(g.events)
      u(17) = uicontrol('Parent',figh,'Units', 'normalized','Position',posbut(17,:), ...
                        'string', 'Events', 'callback', 'eegplot_adv(''drawlegend'', gcbf);');
  end

  for i = 1: length(u) % Matlab 2014b compatibility
      if isprop(eval(['u(' num2str(i) ')']),'Style')
          set(u(i),'Units','Normalized');
      end
  end
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set up uimenus
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Figure Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  m(7) = uimenu('Parent',figh,'Label','Figure');
  m(8) = uimenu('Parent',m(7),'Label','Print');
  uimenu('Parent',m(7),'Label','Edit figure', 'Callback', 'eegplot_adv(''noui'');');
  uimenu('Parent',m(7),'Label','Accept and close','Tag','AcceptAndSave', 'Callback', acceptandsavecommand );
  uimenu('Parent',m(7),'Label','Cancel and close', 'Callback','delete(gcbf)')
  
  % Portrait %%%%%%%%

  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''portrait'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
		
  uimenu('Parent',m(8),'Label','Portrait','checked',...
      'on','tag','orient','callback',timestring)
  
  % Landscape %%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''landscape'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
  
  uimenu('Parent',m(8),'Label','Landscape','checked',...
      'off','tag','orient','callback',timestring)

  % Print command %%%%%%%
  uimenu('Parent',m(8),'Label','Print','tag','printcommand','callback',...
  		['RESULT = inputdlg2( { ''Command:'' }, ''Print'', 1,  { ''print -r72'' });' ...
		 'if size( RESULT,1 ) ~= 0' ... 
		 '  eval ( RESULT{1} );' ...
		 'end;' ...
		 'clear RESULT;' ]);
  
  % Display Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  m(1) = uimenu('Parent',figh,...
      'Label','Display', 'tag', 'displaymenu');
  
  % window grid %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % userdata = 4 cells : display yes/no, color, electrode yes/no, 
  %                      trial boundary adapt yes/no (1/0)  
  m(11) = uimenu('Parent',m(1),'Label','Data select/mark', 'tag', 'displaywin', ...
            'userdata', { 1, [0.8 1 0.8], 0, fastif( g.trialstag(1) == -1, 0, 1)});

          uimenu('Parent',m(11),'Label','Hide marks','Callback', ...
  	        ['g = get(gcbf, ''userdata'');' ...
            'if ~g.winstatus' ... 
            '  set(gcbo, ''label'', ''Hide marks'');' ...
            'else' ...
            '  set(gcbo, ''label'', ''Show marks'');' ...
            'end;' ...
            'g.winstatus = ~g.winstatus;' ...
            'set(gcbf, ''userdata'', g);' ...
            'eegplot_adv(''drawb''); clear g;'] )

	% color %%%%%%%%%%%%%%%%%%%%%%%%%%
    if isunix % for some reasons, does not work under Windows
        uimenu('Parent',m(11),'Label','Choose color', 'Callback', ...
               [ 'g = get(gcbf, ''userdata'');' ...
                 'g.wincolor = uisetcolor(g.wincolor);' ...
                 'set(gcbf, ''userdata'', g ); ' ...
                 'clear g;'] )
    end

  % plot durations
  % --------------
  if g.ploteventdur && isfield(g.events, 'duration')
      disp(['Use menu "Display > Hide event duration" to hide colored regions ' ...
           'representing event duration']);
  end
  if isfield(g.events, 'duration')
      uimenu('Parent',m(1),'Label',fastif(g.ploteventdur, 'Hide event duration', 'Plot event duration'),'Callback', ...
             ['g = get(gcbf, ''userdata'');' ...
              'if ~g.ploteventdur' ... 
              '  set(gcbo, ''label'', ''Hide event duration'');' ...
              'else' ...
              '  set(gcbo, ''label'', ''Show event duration'');' ...
              'end;' ...
              'g.ploteventdur = ~g.ploteventdur;' ...
              'set(gcbf, ''userdata'', g);' ...
              'eegplot_adv(''drawb''); clear g;'] )
  end

  % X grid %%%%%%%%%%%%
  m(3) = uimenu('Parent',m(1),'Label','Grid');
  timestring = ['FIGH = gcbf;',...
	            'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
	            'if size(get(AXESH,''xgrid''),2) == 2' ... %on
		        '  set(AXESH,''xgrid'',''off'');',...
		        '  set(gcbo,''label'',''X grid on'');',...
		        'else' ...
		        '  set(AXESH,''xgrid'',''on'');',...
		        '  set(gcbo,''label'',''X grid off'');',...
		        'end;' ...
		        'clear FIGH AXESH;' ];
  uimenu('Parent',m(3),'Label',fastif(strcmp(g.xgrid, 'off'), ...
         'X grid on','X grid off'), 'Callback',timestring)
  
  % Y grid %%%%%%%%%%%%%
  timestring = ['FIGH = gcbf;',...
	            'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
	            'if size(get(AXESH,''ygrid''),2) == 2' ... %on
		        '  set(AXESH,''ygrid'',''off'');',...
		        '  set(gcbo,''label'',''Y grid on'');',...
		        'else' ...
		        '  set(AXESH,''ygrid'',''on'');',...
		        '  set(gcbo,''label'',''Y grid off'');',...
		        'end;' ...
		        'clear FIGH AXESH;' ];
  uimenu('Parent',m(3),'Label',fastif(strcmp(g.ygrid, 'off'), ...
         'Y grid on','Y grid off'), 'Callback',timestring)

  % Grid Style %%%%%%%%%
  m(5) = uimenu('Parent',m(3),'Label','Grid Style');
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''--'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','- -','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-.'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','_ .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'','':'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','. .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','__','Callback',timestring)
  
  % Submean menu %%%%%%%%%%%%%
  cb =       ['g = get(gcbf, ''userdata'');' ...
              'if strcmpi(g.submean, ''on''),' ... 
              '  set(gcbo, ''label'', ''Remove DC offset'');' ...
              '  g.submean =''off'';' ...
              'else' ...
              '  set(gcbo, ''label'', ''Do not remove DC offset'');' ...
              '  g.submean =''on'';' ...
              'end;' ...
              'set(gcbf, ''userdata'', g);' ...
              'eegplot_adv(''drawp'', 0); clear g;'];
  uimenu('Parent',m(1),'Label',fastif(strcmp(g.submean, 'on'), ...
         'Do not remove DC offset','Remove DC offset'), 'Callback',cb)

  % Scale Eye %%%%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'eegplot_adv(''scaleeye'',OBJ1,FIG1);',...
		'clear OBJ1 FIG1;'];
  m(7) = uimenu('Parent',m(1),'Label','Show scale','Callback',timestring);
  
  % Title %%%%%%%%%%%%
  uimenu('Parent',m(1),'Label','Title','Callback','eegplot_adv(''title'')')
  
  % Stack/Spread %%%%%%%%%%%%%%%
  cb =       ['g = get(gcbf, ''userdata'');' ...
              'hbutton = findobj(gcf, ''Tag'', ''Envelope'');' ...  % find button
              'if g.envelope == 0,' ... 
              '  set(gcbo, ''label'', ''Spread channels'');' ...
              '  g.envelope = 1;' ...
              '  set(hbutton, ''String'', ''Spread'');' ...
              'else' ...
              '  set(gcbo, ''label'', ''Stack channels'');' ...
              '  g.envelope = 0;' ...
              '  set(hbutton, ''String'', ''Stack'');' ...
              'end;' ...
              'set(gcbf, ''userdata'', g);' ...
              'eegplot_adv(''drawp'', 0); clear g;'];
  uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
         'Stack channels','Spread channels'), 'Callback',cb, 'Tag', 'Envelope_menu')
     
  % Normalize/denormalize %%%%%%%%%%%%%%%
  uimenu('Parent',m(1),'Label',fastif(g.envelope == 0, ...
         'Normalize channels','Denormalize channels'), 'Callback', {@normalize_chan,figh}, 'Tag', 'Normalize_menu')

  
  % Settings Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  m(2) = uimenu('Parent',figh,...
      'Label','Settings'); 
  
  % Window %%%%%%%%%%%%
  uimenu('Parent',m(2),'Label','Time range to display',...
      'Callback','eegplot_adv(''window'')')
  
  % Electrode window %%%%%%%%
  uimenu('Parent',m(2),'Label','Number of channels to display',...
      'Callback','eegplot_adv(''winelec'')')
  
  % Electrodes %%%%%%%%
  m(6) = uimenu('Parent',m(2),'Label','Channel labels');
  
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'YTICK = get(AXESH,''YTick'');',...
		'YTICK = length(YTICK);',...
		'set(AXESH,''YTickLabel'',flipud(char(num2str((1:YTICK-1)''),'' '')));',...
		'clear FIGH AXESH YTICK;'];
  uimenu('Parent',m(6),'Label','Show number','Callback',timestring)
  uimenu('Parent',m(6),'Label','Load .loc(s) file',...
      'Callback','eegplot_adv(''loadelect'');')
  
  % Zooms %%%%%%%%
 % if ismatlab && verLessThan('matlab','8.4.0')
 %     zm = uimenu('Parent',m(2),'Label','Zoom off/on');
 %     commandzoom = [ 'set(gcbf, ''WindowButtonDownFcn'', [ ''zoom(gcbf,''''down''''); eegplot_adv(''''zoom'''', gcbf, 1);'' ]);' ...
 %         'tmpg = get(gcbf, ''userdata'');' ...
 %         'clear tmpg tmpstr;'];
 %     uimenu('Parent',zm,'Label','Zoom on', 'callback', commandzoom);
 %     uimenu('Parent',zm,'Label','Zoom off', 'separator', 'on', 'callback', ...
 %         ['zoom(gcbf, ''off''); tmpg = get(gcbf, ''userdata'');' ...
 %         'set(gcbf, ''windowbuttondownfcn'', tmpg.commandselect{1});' ...
 %         'set(gcbf, ''windowbuttonupfcn'', tmpg.commandselect{3});' ...
 %         'clear tmpg;' ]);
 % else
 %      % This is failing for us http://undocumentedmatlab.com/blog/enabling-user-callbacks-during-zoom-pan
 %      uimenu('Parent',m(2),'Label','Zoom off/on', 'callback', 'warning(''FIXME: Zoom not work in MATLAB >= 8.4.0'')');
 % end
      
  uimenu('Parent',m(2),'Label', 'Help', 'callback', 'pophelp(''eegplot_adv'');'); %changed from figh to m(2) > settings

  % Events %%%%%%%%
  ev = uimenu('Parent',m(2),'Label','Events');
  comeventmaxstring   = [ 'tmpg = get(gcbf, ''userdata'');' ...
                'tmpg.plotevent = ''on'';' ...
                'set(gcbf, ''userdata'', tmpg); clear tmpg; eegplot_adv(''emaxstring'');']; % JavierLC      
  comeventleg  = [ 'eegplot_adv(''drawlegend'', gcbf);'];
    
  uimenu('Parent',ev,'Label','Events on'    , 'callback', {@draw_data,figh,0,[],[],ax1,'g.plotevent = ''on'';'},  'enable', fastif(isempty(g.events), 'off', 'on'));
  uimenu('Parent',ev,'Label','Events off'   , 'callback', {@draw_data,figh,0,[],[],ax1,'g.plotevent = ''off'';'}, 'enable', fastif(isempty(g.events), 'off', 'on'));
  uimenu('Parent',ev,'Label','Events'' string length'   , 'callback', comeventmaxstring, 'enable', fastif(isempty(g.events), 'off', 'on')); % JavierLC
  uimenu('Parent',ev,'Label','Events'' legend', 'callback', comeventleg , 'enable', fastif(isempty(g.allevents), 'off', 'on'));
  

  % %%%%%%%%%%%%%%%%%
  % Set up autoselect                                                        
  % NOTE: commandselect{2} option has been moved to a
  %       subfunction to improve speed
  %%%%%%%%%%%%%%%%%%%

   mouse_motion_com = {'@eegplot_adv,''mouse_motion'';'};


  if ~isempty(g.ctrlselectcommand{1}) || ~isempty(g.ctrlselectcommand{3}) || ...
         ~isempty(g.selectcommand{1}) || ~isempty(g.selectcommand{3})
      g.commandselect{1} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' ...
           g.ctrlselectcommand{1} '; else ' g.selectcommand{1} '; end;' ];
      g.commandselect{3} = [ 'if strcmp(get(gcbf, ''SelectionType''),''alt''),' ...
           g.ctrlselectcommand{3} '; else ' g.selectcommand{3} '; end;' ];
      set(figh, 'WindowButtonDownFcn',   g.commandselect{1});
      set(figh, 'WindowButtonupFcn',     g.commandselect{3});
  else
      set(figh, 'WindowButtonDownFcn',   {@mouse_down,figh});
      set(figh, 'WindowButtonupFcn',     {@mouse_up,figh});
  end

  set(figh, 'WindowScrollWheelFcn',  {@mouse_scroll_wheel,figh,ax0,ax1,u(10),u(11),u(9)});
  set(figh, 'WindowButtonMotionFcn', {@mouse_motion,figh,ax0,ax1,u(10),u(11),u(9)});
  %set(figh, 'windowbuttonmotionfcn', EEG = eegplot_adv('mouse_motion'));
  set(figh, 'WindowKeyPressFcn',     {@eegplot_readkey,figh,ax0,ax1,u(10),u(11),u(9)});
  set(figh, 'interruptible', 'on');
%  set(figh, 'busyaction', 'cancel');
%  set(figh, 'windowbuttondownfcn', commandpush);
%  set(figh, 'windowbuttonmotionfcn', commandmove);
%  set(figh, 'windowbuttonupfcn', commandrelease);
  
  % prepare event array if any
  % --------------------------
  if ~isempty(g.events)
      if ~isfield(g.events, 'type') || ~isfield(g.events, 'latency'), g.events = []; end
  end
      
  if ~isempty(g.events)
      if ischar(g.events(1).type)
           [g.eventtypes, ~, indexcolor] = unique_bc({g.events.type}); % indexcolor countinas the event type
      else [g.eventtypes, ~, indexcolor] = unique_bc([ g.events.type ]);
      end
      %indexcolor=length(indexcolor)-indexcolor+1;
      g.eventcolors     = { 'r', [0 0.8 0], 'b', 'm', [1 0.5 0],  [0.5 0 0.5], [0.6 0.3 0] };  
      g.eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'}; 
      g.eventwidths     = [ 2.5 1 ];
      g.eventtypecolors = g.eventcolors(mod([1:length(g.eventtypes)]-1 ,length(g.eventcolors))+1);
      g.eventcolors     = g.eventcolors(mod(indexcolor-1               ,length(g.eventcolors))+1);
      g.eventtypestyle  = g.eventstyle (mod([1:length(g.eventtypes)]-1 ,length(g.eventstyle))+1);
      g.eventstyle      = g.eventstyle (mod(indexcolor-1               ,length(g.eventstyle))+1);
      
      % for width, only boundary events have width 2 (for the line)
      % -----------------------------------------------------------
      indexwidth = ones(1,length(g.eventtypes))*2;
      if iscell(g.eventtypes)
          index=find(ismember(g.eventtypes,{'boundary'}));
          if ~isempty(index)
              indexwidth(index) = 1;
              g.eventtypestyle{index} = '-';
              g.eventtypecolors{index} = 'c';
              g.eventstyle(find(indexcolor==index))={'-'};
              g.eventcolors(find(indexcolor==index))={'c'};
          end
      end
      g.eventtypewidths = g.eventwidths (mod(indexwidth([1:length(g.eventtypes)])-1 ,length(g.eventwidths))+1);
      g.eventwidths     = g.eventwidths (mod(indexwidth(indexcolor)-1               ,length(g.eventwidths))+1);
      
      % latency and duration of events
      % ------------------------------
      g.eventlatencies  = [ g.events.latency ]+1;
      if isfield(g.events, 'duration')
           durations = { g.events.duration };
           durations(cellfun(@isempty, durations)) = { NaN };
           g.eventlatencyend   = g.eventlatencies + [durations{:}]+1;
      else g.eventlatencyend   = [];
      end
      g.plotevent       = 'on';
  end
  if isempty(g.events)
      g.plotevent      = 'off';
  end
  g.allevents = g.events;

  set(figh, 'userdata', g);
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot EEG Data
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  axes(ax1)
  hold on
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot Spacing I
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  YLim = get(ax1,'Ylim');
  A = DEFAULT_AXES_POSITION;
  axes('Position',[A(1)+A(3) 0.3 1-A(1)-A(3) A(4)],'Visible','off','Ylim',YLim,'tag','eyeaxes')
  axis manual
  if strcmp(SPACING_EYE,'on')
      set(m(7),'checked','on')
  else
      set(m(7),'checked','off');
  end 
  eegplot_adv('scaleeye', [], gcf);
  if strcmp(lower(g.scale), 'off')
	  eegplot_adv('scaleeye', 'off', gcf);
  end
  
  eegplot_adv('drawp', 0);
  if g.dispchans ~= g.chans
  	   eegplot_adv('zoom', gcf);
  end 
  eegplot_adv('scaleeye', [], gcf);

  if g.normed == 1
      g.normed = 1;
      normalize_chan([],[],gcf)
      normalize_chan([],[],gcf)
  end
  

  % set button colors #Ugo #COLORS 

  h = findobj(figh, 'style', 'pushbutton');
  set(h, 'backgroundcolor', BUTTON_COLOR);
  h = findobj(figh, 'type','UICONTROL');
  set(h, 'ForegroundColor', DEFAULT_AXIS_COLOR);
  h = findobj(figh, 'tag', 'Rejection');
  set(h, 'backgroundcolor', DEFAULT_ON_COLOR);
  h = findobj(figh, 'tag', 'APPLY');
  set(h, 'backgroundcolor', DEFAULT_SPECIAL_COLOR, 'foregroundcolor',DEFAULT_SPECIAL_TEXT);
  h = findobj(figh, 'tag', 'TBT');
  set(h, 'backgroundcolor', DEFAULT_SPECIAL_COLOR, 'foregroundcolor',DEFAULT_SPECIAL_TEXT);
  h = findobj(figh, 'tag','SaveNowButton');
  set(h, 'backgroundcolor', DEFAULT_SPECIAL_COLOR, 'foregroundcolor',DEFAULT_SPECIAL_TEXT);
  h = findobj(figh, 'tag', 'SaveTagICA');
  set(h, 'backgroundcolor', DEFAULT_SPECIAL_COLOR, 'foregroundcolor',DEFAULT_SPECIAL_TEXT);
  h = findobj(figh, 'tag', 'Display');
  set(h, 'backgroundcolor', modecolor);
  h = findobj(figh, 'tag', 'eegslider');
  set(h, 'backgroundcolor', BUTTON_COLOR);
  set(figh, 'visible', 'on');
  h = findobj(figh, 'tag', 'SWITCH');
  set(h, 'backgroundcolor', cmodecolor);

  eegplot_adv_methods('update_trial_rejections', g)
  drawnow; pause(0.05);
  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Main Function
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
  try p1 = varargin{1}; p2 = varargin{2}; catch, end
  fig = findobj('tag','eegplot_adv');
  switch data

  case 'normalize'
    
    normalize_chan([],[],fig);

  case 'RESET'
    g = RESET();
    load_directory(EEG,fig)
%     loaddircommand = ['findex = [1];try cd(EEG.filepath); catch, end; filecount = [1];files = dir(''*.set'');findex = find(strcmp({files.name}, EEG.filename));files = dir(''*.set'');set(findobj(''tag'',''FolderList''),''string'',{files(1:end).name},''value'',find(strcmp({files.name}, EEG.filename)));'];
%     eval(loaddircommand);

  case 'MERGE_REJECTION'
    
    fig = gcf;
    if ~contains(fig.Tag,'topo')
        allfigs = findobj('type','figure');
        for i=1:length(allfigs)
            if contains(allfigs(i).Tag,'topo')
                fig = allfigs(i);
                break;
            end
        end
    end
    try tmpstatus = get(findobj('parent', gcf, 'Style', 'checkbox'), 'value');
    comps = fliplr([tmpstatus{:}]);
    close(gcf);
    catch 
    end
    %EEG = p1;
    
    fig = findobj('tag','eegplot_adv');
%     g = get(fig,'UserData'); 
%     if size(fig,1) > 2
    g = get(fig,'UserData');
%     end
    
    %[ICL,~] = quick_IClabel(g.EEG); 
    comps = find(comps);
    set(fig,'UserData',g);
    if g.EEG.plotchannels == 1
        g = eegplot_adv_methods('SWITCH', g);
        g.eloc_file = g.eloc_file_pc;
    else
        for i = comps
            g.eloc_file(i).badchan = 1;
        end
    end
    eegplot_adv_methods('update_trial_rejections', g);
    draw_data([],[],fig,0,[],g);

  case 'TYPING'
     g = get(fig,'UserData'); 
     %g = TYPING(g,p1);

  case 'mouse_motion'

      %mouse_motion(varargin)
      
      figh = findobj('tag','eegplot_adv');
      ax0 = findobj('tag','backeeg','parent',figh);
      ax1 = findobj('tag','eegaxis','parent',figh);

      A = findobj('Style','text');
      B = findobj('Tag','Eelec');
      C = findobj('Tag','Evalue');

      mouse_motion([],[],figh,ax0,ax1,B,C,A)

  case 'SAVE'
      %fig = findobj('tag','eegplot_adv');
      g = get(fig,'UserData'); 
      EEG = g.EEG; 
      if ~isfield(g.EEG, 'plotchannels')
          g.EEG.plotchannels = 1;
      end
       if EEG.plotchannels == 1
           EEG.chanrej = g.winrej;
           EEG.comprej = g.winrej_pc;
           try EEG.mybadchan = find([g.eloc_file.badchan]);catch; end
           try EEG.mybadcomp = find([g.eloc_file_pc.badchan]); EEG.gcompreject = find([g.eloc_file.badchan]);catch; end
       else
           EEG.chanrej = g.winrej_ch;
           EEG.comprej = g.winrej;
           try EEG.mybadchan = find([g.eloc_file_ch.badchan]);catch; end
           try EEG.mybadcomp = find([g.eloc_file.badchan]); EEG.gcompreject = find([g.eloc_file.badchan]); catch; end
       end
      
      suffix = get(findobj(fig,'tag','SaveNowText'),'string');
      [~, fname, ~] = fileparts(EEG.filename);
      [EEG] = pop_saveset(EEG, 'filename', [fname suffix '.set'], 'filepath', EEG.filepath);

      set(findobj(fig,'tag','SaveNowText'),'String','');

      eval(get(findobj(fig,'tag','SaveButton'),'callback'))
      [g.EEG] = eeg_store([], g.EEG);
      %EEG = pop_loadset(EEG.filename);
      g.EEG = EEG; %save set ADDED BY UGO
      %eeglab redraw;
      set(findobj('tag','eegplot_adv'),'UserData',g);
        load_directory(EEG,fig)
%       loaddircommand = ['findex = [1];try cd(EEG.filepath); catch, end; filecount = [1];files = dir(''*.set'');findex = find(strcmp({files.name}, EEG.filename));files = dir(''*.set'');set(findobj(''tag'',''FolderList''),''string'',{files(1:end).name},''value'',find(strcmp({files.name}, EEG.filename)));'];
%       eval(loaddircommand);

  case 'METHODS'
    g = get(fig,'UserData');
    g = methods(g);

  case 'APPLY'
    g = get(fig,'UserData');
    if g.normed == 1
        normalize_chan([],[],fig);
    end
    g = eegplot_adv_methods('APPLY', g);
    % FIX NORMALIZATION
    EEG = g.EEG; 
    
  case 'SWITCH'
    g = get(fig,'UserData');

    g = eegplot_adv_methods('SWITCH', g);
    
    h = findobj(fig, 'tag', 'SWITCH');
    if ~isempty(g.EEG.icawinv)
        if g.EEG.plotchannels == 1
            %set(h,'string','EEG data ON');
            set(h,'string','Show ICA');
            set(h, 'BackGroundColor', DEFAULT_ON_COLOR);
        else
            %set(h,'string','Component Data ON');
            set(h,'string','Show EEG');
            set(h, 'BackgroundColor', DEFAULT_OFF_COLOR);
        end
    end
    
    %change_scale([],[],fig,p1)
%    eegplot_adv('zoom', fig);
%    eegplot_w3('updateslider', fig);
    eegplot_adv('drawp',0);	
%    eegplot_adv('scaleeye', [], fig);
    ax2 = findobj('tag','eegaxis','parent',fig);
    %change_scale([],[],fig,4,ax2);
    
  case 'saveandtag'
    g = get(fig,'UserData');
    EEG = g.EEG;
    EEG.save = 1;
    EEG.ICA = 1;
    eval(get(findobj(fig,'tag','AcceptAndSave'),'Callback'));
      
      %     g = get(fig,'UserData');
%     EEG = g.EEG;
%     tmpcolor = g.color;
%     draw_data_quick(fig,[],[],tmpcolor)
    %figure; spy(g.winrej)
    %interpolation_plot(g)
    %draw_matrix(fig,g);
    %[EEG, ~] = quick_spectra(EEG,40,2,'AVG');

  case 'TBT'
      g = get(fig,'UserData');
      g = eegplot_adv_methods('TBT', g);
      ax2 = findobj('tag','eegaxis','parent',fig);
      change_scale([],[],fig,4,ax2);
      draw_background
      eegplot_adv('drawp',0);

  case 'QUICKLAB'
      g = get(fig,'UserData');
      g = eegplot_adv_methods('QUICKLAB', g);
      ax2 = findobj('tag','eegaxis','parent',fig);
      change_scale([],[],fig,4,ax2);
    if g.EEG.plotchannels == 1
        eegplot_adv('SWITCH');
        g.eloc_file = g.eloc_file_pc;
    else
        try
            badcomps = find([g.eloc_file.badchan]);
            for i = badcomps
                g.eloc_file(i).badchan = 1;
            end
        catch; end
    end
  
  case 'ICLABEL'
      g = get(fig,'UserData');
      ax2 = findobj('tag','eegaxis','parent',fig);
      g = eegplot_adv_methods('ICLABEL', g);
      change_scale([],[],fig,4,ax2);

  case 'ClearMarks'
      g = get(fig,'UserData');
      g.winrej = [];
      g.EEG.suffix = '';
      for ii=1:length(g.eloc_file)
          g.eloc_file(ii).badchan = 0;
      end
      eegplot_adv_methods('update_trial_rejections', g);
      draw_data([],[],fig,0,[],g);
      
  case 'rejection'
    g = get(fig,'UserData');
    QuickLabDefs;
    dis = findobj(fig,'tag', 'Rejection');
    figh = findobj(fig,'tag', g.tag);
    if g.wincolor == DEFAULT_PLOT_INTERP
        g.wincolor = DEFAULT_PLOT_REJ; % BACKGROUND OF REJECTIONS

        set(dis,'BackgroundColor',DEFAULT_OFF_COLOR);
        set(dis,'string','Rejection Mode');

        set(figh,'Color',DEFAULT_FIG_COLOR2);
        set(findobj(fig,'Style','Text'),'BackgroundColor',DEFAULT_FIG_COLOR2)
    else
        g.wincolor = DEFAULT_PLOT_INTERP; % BACKGROUND OF INTERPOLATIONS

        set(dis,'BackgroundColor',DEFAULT_ON_COLOR);
        set(dis,'string','Interpolation Mode');

        set(figh,'Color',DEFAULT_FIG_COLOR); % 
        set(findobj(fig,'Style','Text'),'BackgroundColor',DEFAULT_FIG_COLOR)
    end
    
    draw_data([],[],fig,0,[],g);
      
   case 'redraw'
    g = get(fig,'UserData');
    EEG = g.EEG;
    epoch = abs(EEG.xmin - EEG.xmax);
    dis = findobj('tag', 'Display');
    
    if g.trialstag == -1
        
        g.trialstag = (g.srate * epoch)+1 ;
        g.winlength =  g.winlength / epoch;
        g.time = g.time * epoch;
        
        set(dis,'BackgroundColor',DEFAULT_ON_COLOR); %make display red
        set(dis,'string','Hide Epoch');
        
        draw_data([],[],fig,5,[],g);
    else
        g.trialstag = -1;
        g.winlength = g.winlength * epoch;
        
        g.time = g.time * epoch;
        set(dis,'BackgroundColor',DEFAULT_OFF_COLOR); %make display green
        set(dis,'string','Show Epoch');

        draw_data([],[],fig,5,[],g);
    end
      
  case 'drawp'
    % Redraw EEG and change position
    draw_data([],[],fig,p1)
    
  case 'drawb' 
    % Draw background
    draw_background
    
  case 'draws'
    % Redraw EEG and change scale
    change_scale([],[],fig,p1)

  case 'draww'
    % Redraw EEG and change window size
    change_eeg_window_length([],[],fig,p1)
    
  case 'window'  % change window size
    % get new window length with dialog box
    % -------------------------------------
    g = get(fig,'UserData');
	result       = inputdlg2( { fastif(g.trialstag==-1,'New window length (s):', 'Number of epoch(s):') }, 'Change window length', 1,  { num2str(g.winlength) });
	if size(result,1) == 0 return; end

	g.winlength = eval(result{1}); 
	set(fig, 'UserData', g);
	eegplot_adv('drawp',0);	
	return;
    
  case 'winelec_auto'  % change channel window size
                  % get new window length with dialog box
                  % -------------------------------------
   fig = findobj('tag','eegplot_adv');
   g = get(fig,'UserData');
   %g = THINKING(g,1);
   
   g.dispchans = g.chans;

   set(findobj('tag','NumChan'),'String',num2str(g.dispchans));

   set(fig, 'UserData', g);
    ax1 = findobj('tag','eegaxis','parent',fig);
    try
    set(ax1,...
    'YTick', [0:g.spacing:g.chans*g.spacing],...
    'Ylim',  [g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] ); % 'YLim',[0 (g.chans+1)*g.spacing]
    catch
    end

% update scaling eye (I) if it exists
% -----------------------------------
eyeaxes = findobj('tag','eyeaxes','parent',fig);
if ~isempty(eyeaxes)
    eyetext = findobj('type','text','parent',eyeaxes,'tag','thescalenum');
    set(eyetext,'string',num2str(g.spacing,4))
end
   eegplot_adv('setelect');
   try eegplot_adv('updateslider', fig); catch; end
   %eegplot_adv('drawp',0);	
   eegplot_adv('scaleeye', [], fig);

   %g = THINKING(g,0);
   set(fig, 'UserData', g);

  case 'winelec'  % change channel window size
                  % get new window length with dialog box
                  % -------------------------------------
   g = get(fig,'UserData');
   %g = THINKING(g,1);
   
   result = inputdlg2( ...
{ 'Number of channels to display:' } , 'Change number of channels to display', 1,  { num2str(g.dispchans) });
   if size(result,1) == 0 return; end
   
   g.dispchans = eval(result{1});
   if g.dispchans<0 || g.dispchans>g.chans
       g.dispchans = g.chans;
   end
   set(fig, 'UserData', g);
   
   set(findobj('tag','NumChan'),'String',num2str(g.dispchans));

   eegplot_adv('updateslider', fig);
   eegplot_adv('drawp',0);	
   eegplot_adv('scaleeye', [], fig);

   set(fig, 'UserData', g);
   
   return;
   
  case 'winelec_text'  % change channel window size
                  % get new window length with dialog box
                  % -------------------------------------
   g = get(fig,'UserData');

   EChan = findobj('tag','NumChan');
   EChanString = EChan.String;
   % removing letters from text.
   % Exclude characters, which are accepted by sscanf:
   EChanString(ismember(EChan.String, '-+eEgG')) = ' ';
   % Convert to one number and back to a string:
   EChanString = sprintf('%g', sscanf(EChanString, '%g', 1));
   
   if ~isempty(EChanString)
       set(EChan, 'String', EChanString);
       g.dispchans = str2double(EChanString);
   else
       set(EChan, 'String', num2str(g.dispchans));
   end
   
   if isempty(g.dispchans) || g.dispchans < 0 || g.dispchans > g.chans
       g.dispchans = g.chans;
   end

   set(fig, 'UserData', g);
   
   eegplot_adv('updateslider', fig);
   eegplot_adv('drawp',0);	
   eegplot_adv('scaleeye', [], fig);
   %MarkChannel([],[],fig,0,0);
   %Fixing UGO
   %set(fig,'UserData',g);
   %draw_data([],[],fig,0,[],g);
   
   return;

   case 'emaxstring'  % change events' string length  ;  JavierLC
      % get dialog box
      % -------------------------------------
      g = get(fig,'UserData');
      result = inputdlg2({ 'Max events'' string length:' } , 'Change events'' string length to display', 1,  { num2str(g.maxeventstring) });
      if size(result,1) == 0 return; end                 
      g.maxeventstring = eval(result{1});
      set(fig, 'UserData', g);
      eegplot_adv('drawb');
      return;
      
  case 'loadelect' % load channels
	[inputname,inputpath] = uigetfile('*','Channel locations file');
	if inputname == 0 return; end
	if ~exist([ inputpath inputname ],'file')
		error('no such file');
	end

	AXH0 = findobj('tag','eegaxis','parent',fig);
	eegplot_adv('setelect',[ inputpath inputname ],AXH0);
	return;
  
  case 'setelect'
    % Set channels   
    
    g = get(fig,'UserData');
    if nargin < 3
        axeshand = findobj('tag','eegaxis','parent',fig);
    else 
        axeshand = p2;
    end
    if nargin < 2
        eloc_file = g.eloc_file;
    else
        eloc_file = p1;
    end
    
    
    outvar1 = 1;
    if isempty(eloc_file)
      outvar1 = 0;
      return
    end
    
    tmplocs = readlocs(eloc_file);
	YLabels = { tmplocs.labels };
    YLabels = strvcat(YLabels);
    
    YLabels = flipud(char(YLabels,' '));
    set(axeshand,'YTickLabel',YLabels)
  
  case 'title'
    % Get new title
	h = findobj('tag', 'eegplottitle');
	
	if ~isempty(h)
		result       = inputdlg2( { 'New title:' }, 'Change title', 1,  { get(h(1), 'string') });
		if ~isempty(result), set(h, 'string', result{1}); end
	else 
		result       = inputdlg2( { 'New title:' }, 'Change title', 1,  { '' });
		if ~isempty(result), h = textsc(result{1}, 'title'); set(h, 'tag', 'eegplottitle');end
	end
	
	return;

  case 'scaleeye'
    % Turn scale I on/off
    obj = p1;
    figh = p2;
	g = get(figh,'UserData');
    % figh = get(obj,'Parent');

    if ~isempty(obj)
		eyeaxes = findobj('tag','eyeaxes','parent',figh);
		children = get(eyeaxes,'children');
		if ischar(obj)
			if strcmp(obj, 'off')
				set(children, 'visible', 'off');
				set(eyeaxes, 'visible', 'off');
				return;
			else
				set(children, 'visible', 'on');
				set(eyeaxes, 'visible', 'on');
			end
		else
			toggle = get(obj,'checked');
			if strcmp(toggle,'on')
				set(children, 'visible', 'off');
				set(eyeaxes, 'visible', 'off');
				set(obj,'checked','off');
				return;
			else
				set(children, 'visible', 'on');
				set(eyeaxes, 'visible', 'on');
				set(obj,'checked','on');
			end
        end
    end
	
	eyeaxes = findobj('tag','eyeaxes','parent',figh);
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
	YLim = double(get(ax1, 'ylim'));
    
	ESpacing = findobj('tag','ESpacing','parent',figh);
	g.spacing= str2num(get(ESpacing,'string'));
	
	axes(eyeaxes); cla; axis off;
    set(eyeaxes, 'ylim', YLim);
    set(eyeaxes, 'xlim', [0 1]);
    
	Xl = double([.01 .05; .03 .03; .01 .05]);
    Yl = double([ g.spacing g.spacing; g.spacing 0; 0 0] + YLim(1));
	plot(Xl(1,:),Yl(1,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline'); hold on;
	plot(Xl(2,:),Yl(2,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline');
	plot(Xl(3,:),Yl(3,:),'color',DEFAULT_AXIS_COLOR,'clipping','off', 'tag','eyeline');
    set(eyeaxes, 'tag', 'eyeaxes');

    ax1 = findobj('tag','eegaxis','parent',figh);
    try
    set(ax1,...
    'YTick', [0:g.spacing:g.chans*g.spacing],...
    'Ylim',  [g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] ); % 'YLim',[0 (g.chans+1)*g.spacing]
    catch
    end

    
  case 'noui'
      if ~isempty(varargin)
          eegplot_adv( varargin{:} ); fig = fig;
      else 
          fig = findobj('tag', 'eegplot_adv');
      end
      set(fig, 'menubar', 'figure');
      
      % find button and text
      obj = findobj(fig, 'style', 'pushbutton'); delete(obj);
      obj = findobj(fig, 'style', 'edit'); delete(obj);
      obj = findobj(fig, 'style', 'text'); 
      %objscale = findobj(obj, 'tag', 'thescale');
      %delete(setdiff(obj, objscale));
	  obj = findobj(fig, 'tag', 'Eelec');delete(obj);
	  obj = findobj(fig, 'tag', 'Etime');delete(obj);
	  obj = findobj(fig, 'tag', 'Evalue');delete(obj);
	  obj = findobj(fig, 'tag', 'Eelecname');delete(obj);
	  obj = findobj(fig, 'tag', 'Etimename');delete(obj);
	  obj = findobj(fig, 'tag', 'Evaluename');delete(obj);
	  obj = findobj(fig, 'type', 'uimenu');delete(obj);
 
   case 'zoom' % if zoom
      fig = varargin{1};
      ax1 = findobj('tag','eegaxis','parent',fig); 
      ax2 = findobj('tag','backeeg','parent',fig); 
      tmpxlim  = get(ax1, 'xlim');
      tmpylim  = get(ax1, 'ylim');
      tmpxlim2 = get(ax2, 'xlim');
      set(ax2, 'xlim', get(ax1, 'xlim'));
      g = get(fig,'UserData');
      
      % deal with abscissa
      % ------------------
      if g.trialstag ~= -1
          Eposition = str2num(get(findobj('tag','EPosition','parent',fig), 'string'));
          g.winlength = (tmpxlim(2) - tmpxlim(1))/g.trialstag;
          Eposition = Eposition + (tmpxlim(1) - tmpxlim2(1)-1)/g.trialstag;
          Eposition = round(Eposition*1000)/1000;
          set(findobj('tag','EPosition','parent',fig), 'string', num2str(Eposition));
      else
          Eposition = str2num(get(findobj('tag','EPosition','parent',fig), 'string'))-1;
          g.winlength = (tmpxlim(2) - tmpxlim(1))/g.srate;	
          Eposition = Eposition + (tmpxlim(1) - tmpxlim2(1)-1)/g.srate;
          Eposition = round(Eposition*1000)/1000;
          set(findobj('tag','EPosition','parent',fig), 'string', num2str(Eposition+1));
      end 
      
      % deal with ordinate
      % ------------------
      g.elecoffset = tmpylim(1)/g.spacing;
      g.dispchans  = round(1000*(tmpylim(2)-tmpylim(1))/g.spacing)/1000;      
      
      set(fig,'UserData', g);
      eegplot_adv('updateslider', fig);
      eegplot_adv('drawp', 0);
      eegplot_adv('scaleeye', [], fig);

      % reactivate zoom if 3 arguments
      % ------------------------------
      if exist('p2', 'var') == 1
          if ismatlab && verLessThan('matlab','8.4.0')
              set(gcbf, 'windowbuttondownfcn', [ 'zoom(gcbf,''down''); eegplot_adv(''zoom'', gcbf, 1);' ]);
          else
              warning('FIXME: Zoom not work in MATLAB >= 8.4.0')
          end
      end

	case 'updateslider' % if zoom
      fig = varargin{1};
      g = get(fig,'UserData');
      sliider = findobj('tag','eegslider','parent',fig);
      if g.elecoffset < 0
         g.elecoffset = 0;
      end
      if g.dispchans >= g.chans
         g.dispchans = g.chans;
         g.elecoffset = 0;
         set(sliider, 'visible', 'off');
      else
         set(sliider, 'visible', 'on');         
		 set(sliider, 'value', g.elecoffset/g.chans, ...
					  'sliderstep', [1/(g.chans-g.dispchans) g.dispchans/(g.chans-g.dispchans)]);
         %'sliderstep', [1/(g.chans-1) g.dispchans/(g.chans-1)]);
      end
      if g.elecoffset < 0
         g.elecoffset = 0;
      end
      if g.elecoffset > g.chans-g.dispchans
         g.elecoffset = g.chans-g.dispchans;
      end
      set(fig,'UserData', g);
	  eegplot_adv('scaleeye', [], fig);
   
   case 'drawlegend'
      fig = varargin{1};
      g = get(fig,'UserData');

      if ~isempty(g.allevents) % draw vertical colored lines for events, add event name text above
          if isempty(g.allevents)
              g.allevents = g.events;
          end

          nleg = length(unique([g.allevents.type]));
          fig2 = figure('numbertitle', 'off', 'name', 'Select Events to Display','tag','legend', 'visible', 'off', 'menubar', 'none', 'color', DEFAULT_FIG_COLOR);
          pos = get(fig2, 'position');
          set(fig2, 'position', [ pos(1) pos(2) 200 14*nleg+20]);

          if isempty(g.events_show)
              g.events_show = ones(nleg,1);
          end

          set(fig,'UserData',g);

          if ischar(g.allevents(1).type)
              [g.eventtypes2, ~, indexcolor] = unique_bc({g.allevents.type}); % indexcolor countinas the event type
          else [g.eventtypes2, ~, indexcolor] = unique_bc([ g.allevents.type ]);
          end
          %indexcolor=length(indexcolor)-indexcolor+1;
          g.eventcolors2     = { 'r', [0 0.8 0], 'b', 'm', [1 0.5 0],  [0.5 0 0.5], [0.6 0.3 0] };
          g.eventstyle2      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
          g.eventwidths2     = [ 2.5 1 ];
          g.eventtypecolors2 = g.eventcolors2(mod([1:length(g.eventtypes2)]-1 ,length(g.eventcolors2))+1);
          g.eventcolors2     = g.eventcolors2(mod(indexcolor-1               ,length(g.eventcolors2))+1);
          g.eventtypestyle2  = g.eventstyle2 (mod([1:length(g.eventtypes2)]-1 ,length(g.eventstyle2))+1);
          g.eventstyle2      = g.eventstyle2 (mod(indexcolor-1               ,length(g.eventstyle2))+1);

          % for width, only boundary events have width 2 (for the line)
          % -----------------------------------------------------------
          indexwidth = ones(1,length(g.eventtypes2))*2;
          if iscell(g.eventtypes2)
              index=find(ismember(g.eventtypes2,{'boundary'}));
              if ~isempty(index)
                  indexwidth(index) = 1;
                  g.eventtypestyle2{index} = '-';
                  g.eventtypecolors2{index} = 'c';
                  g.eventstyle2(find(indexcolor==index))={'-'};
                  g.eventcolors2(find(indexcolor==index))={'c'};
              end
          end
          g.eventtypewidths2 = g.eventwidths2 (mod(indexwidth([1:length(g.eventtypes2)])-1 ,length(g.eventwidths2))+1);
          g.eventwidths2     = g.eventwidths2 (mod(indexwidth(indexcolor)-1               ,length(g.eventwidths2))+1);

          % latency and duration of events
          % ------------------------------
          g.eventlatencies2  = [ g.allevents.latency ]+1;
          if isfield(g.allevents, 'duration')
              durations = { g.allevents.duration };
              durations(cellfun(@isempty, durations)) = { NaN };
              g.eventlatencyend2   = g.eventlatencies2 + [durations{:}]+1;
          else g.eventlatencyend2   = [];
          end

          for index = 1:nleg
              % Adding checkbox UGO 2023

              line = plot([10 30], [(index-0.5) * 10 (index-0.5) * 10], 'color', g.eventtypecolors2{index}, 'linestyle', ...
                  g.eventtypestyle2{ index }, 'linewidth', g.eventtypewidths2( index ), 'Tag','LINE'); hold on;

              if iscell(g.eventtypes2)
                  th=text(35, (index-0.5)*10, g.eventtypes2{index}, ...
                      'color', g.eventtypecolors2{index}); hold on;
              else
                  th=text(35, (index-0.5)*10, num2str(g.eventtypes2(index)), ...
                      'color', g.eventtypecolors2{index}); hold on;
              end

              %checkcom  = {@checkbox,int2str(index),1};

              check = uicontrol(fig2, 'Style', 'checkbox','Units','Normalized','Tag','check', 'Value',g.events_show(index),'Position',...
                  [.1 index*(.82/nleg)+.1 .08 .02],'Visible','on'); 

               %check = uicontrol(fig2, 'Style', 'checkbox','Units','Normalized','Tag',int2str(index), 'Value',g.events_show(index),'Position',...
               %    [.1 [(index-0.5)*.065]+.25 .08 .08],'Visible','on','Callback',checkcom); 

              %check = uicontrol(fig2, 'Style', 'checkbox','Tag',int2str(index), 'Value',g.events_show(index),'Visible','on','Callback',checkcom);
          end

          %apply_eventchanges = {@apply_eventchanges,~,~};

          ApplyButton = uicontrol(fig2, 'Style','pushbutton','String','Apply','Callback',@apply_eventchanges,'Units', 'normalized','Position',[.05 .05 .5 .05]);
            
          selectallcom = ['set(findobj(findobj(''tag'',''legend''),''tag'',''check''),''Value'',get(findobj(findobj(''tag'',''legend''),''Tag'',''Checkall''),''Value''));'];
          checkall = uicontrol(fig2, 'Style','checkbox','String','Select All','Tag','Checkall','Value',0,'Callback',selectallcom,'Units', 'normalized','Position',[.55 .05 .5 .05]);

          xlim([0 160]);
          ylim([0 nleg*10]);
          axis off;
          set(fig2, 'visible', 'on');
      end


      % motion button: move windows or display current position (channel, g.time and activation)
      % ----------------------------------------------------------------------------------------
      % case moved as subfunction
      % add topoplot
      % ------------
      case 'topoplot'
          fig = varargin{1};
          plot_topoplot(fig);
          %     g = get(fig,'UserData');
          %     if ~isstruct(g.eloc_file) || ~isfield(g.eloc_file, 'theta') || isempty( [ g.eloc_file.theta ])
          %         return;
          %     end
          %     ax1 = findobj('tag','backeeg','parent',fig);
          %     tmppos = get(ax1, 'currentpoint');
          %     ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
          %     % plot vertical line
          %     %yl = ylim(ax1);
          %     %plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
          %
          %     if g.trialstag ~= -1
          %           lowlim = round(g.time*g.trialstag+1);
          %     else, lowlim = round(g.time*g.srate+1);
          %     end
          %     data = get(ax1,'UserData');
          %     datapos = max(1, round(tmppos(1)+lowlim));
          %     datapos = min(datapos, g.frames);
    
    %STOPPED HERE
    
    %axes = get(findobj('tag','Topoplot'));
    %figure; topoplot(data(:,datapos), g.eloc_file);
%     if g.trialstag == -1
%          latsec = (datapos-1)/g.srate;
%          title(sprintf('Latency of %d seconds and %d milliseconds', floor(latsec), round(1000*(latsec-floor(latsec)))));
%     else
%         trial = ceil((datapos-1)/g.trialstag);
%         latintrial = eeg_point2lat(datapos, trial, g.srate, g.limits, 0.001);
%         title(sprintf('Latency of %d ms in trial %d', round(latintrial), trial));
%     end
    
  % release button: check window consistency, add to trial boundaries
  % -------------------------------------------------------------------
  case 'defupcom'
    mouse_up([],[],varargin{1}); % Just for compatibility with original eegplot()
         
  % push button: create/remove window
  % ---------------------------------
  case 'defdowncom'
      mouse_down([],[],varargin{1}); % Just for compatibility with original eegplot()
  case 'make_eloc_file'
    if ~isempty(varargin)
        g = varargin{1};
    else
        g = get(gcf,'UserData');
    end
    g = make_eloc_file(g);
    set(gcf,'UserData',g);
    EEG = g;

  case 'draw_matrix'
    g = get(gcf,'UserData');
    draw_matrix(g);

   otherwise
      error(['Error - invalid eegplot_adv() parameter: ',data])
  end
  
end
function g = make_eloc_file(g)

% this function remakes the g based on the current EEG,
% specifically, eloc_file, events, frames, chans, data, etc!

EEG = g.EEG;

% change filename on the figure title.
fig = findobj('tag','eegplot_adv');
set(fig,'Name',['Advanced EEG Data Editor by Ugo Bruzadin Nunes -- eegplot_adv(): ',EEG.filename]);

% change folder and file name on the dropmenu
%store = ['[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 )'];
% loaddircommand = ['findex = [1];try cd(EEG.filepath); catch, end; filecount = [1];files = dir(''*.set'');findex = find(strcmp({files.name}, EEG.filename));files = dir(''*.set'');set(findobj(''tag'',''FolderList''),''string'',{files(1:end).name},''value'',find(strcmp({files.name}, EEG.filename)));'];
% 
% eval(loaddircommand);
load_directory(EEG,fig)

elecrange = [1:EEG.nbchan];

if ~isempty( EEG.icasphere )
    comprange = [1:size(EEG.icaweights,1)];
end

if ~isempty(EEG.chanlocs)
    g.eloc_file_ch = EEG.chanlocs(elecrange);
end

if ~isempty(EEG.icasphere)
    try
        gcompreject=EEG.reject.gcompreject;
    catch
        gcompreject=zeros(1,size(EEG.icaweights,1));
    end
    tmpcompstruct=struct('badchan',num2cell(gcompreject));
    for index = 1:length(comprange)
        tmpcompstruct(index).labels = int2str(comprange(index));
    end
    g.eloc_file_pc = tmpcompstruct;
    
end
EEG = g.EEG;


if ~isfield(g.EEG, 'plotchannels')
    g.EEG.plotchannels = 1;
end

if EEG.plotchannels == 1
    g.chans = EEG.nbchan;
    g.eloc_file = g.eloc_file_ch;
    g.data = EEG.data;
else
    g.chans = size(EEG.icaweights,1);
    g.eloc_file = g.eloc_file_pc;
    g.data = EEG.icaact;
end

data = g.data;

g.normed = 0;
% 
if g.trialstag > 0
    g.trialstag = EEG.pnts;
end

%if g.limits
%g.limits = [1000*EEG.xmin 1000*EEG.xmin];

g.dispchans  = size(data,1);

set(findobj( 'tag','NumChan'),'String',g.dispchans);

if ~isempty(g.events)
    if ~isfield(g.events, 'type') || ~isfield(g.events, 'latency'), g.events = []; end
end

%[~,g.frames, tmpnb] = size(data);
g.frames = size(EEG.data(:,:),2);

% if g.spacing == 0
%     g=optim_scale(data,g);
% end

g.events = EEG.event;

if ~isempty(g.events)
    if ischar(g.events(1).type)
        [g.eventtypes, ~, indexcolor] = unique_bc({g.events.type}); % indexcolor countinas the event type
    else [g.eventtypes, ~, indexcolor] = unique_bc([ g.events.type ]);
    end
    %indexcolor=length(indexcolor)-indexcolor+1;
    g.eventcolors     = { 'r', [0 0.8 0], 'b', 'm', [1 0.5 0],  [0.5 0 0.5], [0.6 0.3 0] };
    g.eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
    g.eventwidths     = [ 2.5 1 ];
    g.eventtypecolors = g.eventcolors(mod([1:length(g.eventtypes)]-1 ,length(g.eventcolors))+1);
    g.eventcolors     = g.eventcolors(mod(indexcolor-1               ,length(g.eventcolors))+1);
    g.eventtypestyle  = g.eventstyle (mod([1:length(g.eventtypes)]-1 ,length(g.eventstyle))+1);
    g.eventstyle      = g.eventstyle (mod(indexcolor-1               ,length(g.eventstyle))+1);

    % for width, only boundary events have width 2 (for the line)
    % -----------------------------------------------------------
    indexwidth = ones(1,length(g.eventtypes))*2;
    if iscell(g.eventtypes)
        index=find(ismember(g.eventtypes,{'boundary'}));
        if ~isempty(index)
            indexwidth(index) = 1;
            g.eventtypestyle{index} = '-';
            g.eventtypecolors{index} = 'c';
            g.eventstyle(find(indexcolor==index))={'-'};
            g.eventcolors(find(indexcolor==index))={'c'};
        end
    end
    g.eventtypewidths = g.eventwidths (mod(indexwidth([1:length(g.eventtypes)])-1 ,length(g.eventwidths))+1);
    g.eventwidths     = g.eventwidths (mod(indexwidth(indexcolor)-1               ,length(g.eventwidths))+1);

    % latency and duration of events
    % ------------------------------
    g.eventlatencies  = [ g.events.latency ]+1;
    if isfield(g.events, 'duration')
        durations = { g.events.duration };
        durations(cellfun(@isempty, durations)) = { NaN };
        g.eventlatencyend   = g.eventlatencies + [durations{:}]+1;
    else g.eventlatencyend   = [];
    end
    g.plotevent       = 'on';
end
if isempty(g.events)
    g.plotevent      = 'off';
end

update_file_texts(g)

function vertstring = vert_string(string)

for i = 1:length(string)
    if i == 1
        vertstring = strcat('<html><center>',string(i),'<br />');
    elseif i > 1 && i < length(string)
        vertstring = strcat(vertstring,string(i),'<br />');
    elseif i == length(string)
        vertstring = strcat(vertstring,string(i),'</center></html>');
    end
end

function tmprank2 = getrank(tmpdata)
        
tmprank = rank(tmpdata);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Here: alternate computation of the rank by Sven Hoffman
%tmprank = rank(tmpdata(:,1:min(3000, size(tmpdata,2)))); old code
covarianceMatrix = cov(tmpdata', 1);
[~, D] = eig (covarianceMatrix);
rankTolerance = 1e-7;
tmprank2=sum (diag (D) > rankTolerance);
if tmprank ~= tmprank2
    %fprintf('Warning: fixing rank computation inconsistency (%d vs %d) most likely because running under Linux 64-bit Matlab\n', tmprank, tmprank2);
    tmprank2 = min(tmprank, tmprank2);
end


function g = RESET()
   
   fig = findobj('tag','eegplot_adv');
   g = get(fig,'UserData');

   %g.EEG = EEG;

   %if ~isfield(g.EEG,'suffix'); g.EEG.suffix = ''; end
   
   if ~isfield(g.EEG, 'plotchannels')
        g.EEG.plotchannels = 1;
   end
   
   EEG = g.EEG;

   if EEG.plotchannels == 1
       g.data = EEG.data;
   else
       if ~isempty(EEG.icaact)
           g.data = EEG.icaact;
       else
           g = eegplot_adv_methods('SWITCH', g);
       end
   end
   %GET ICA DATA AS WELL

   % make new eloc_file based on new channels/components
   g = make_eloc_file(g);
   %g.winrej = []; g.winrej_pc = []; g.winrej_ch = [];

   % make suffix, store the bool of a NEW vs OLD data.
   %fprintf(strcat('Showing processed dataset after running:', com, '/r'));
  
   % store and draw data
   set(fig,'UserData',g);
   ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
   set(ax1,'UserData',g.data);

   % ONE OF THESE LOWER FUNCTIONS - PROBABLY WHERE THERE IS A BUG! UGO BUG 12-19-2022
   draw_data([],[],fig,9,[],g);
   %eegplot_adv('setelect');
   %eegplot_adv('winelec_auto');

function update_file_texts(g)

EEG = g.EEG;

set(findobj('Tag','Number of Channels'),'string',strcat(num2str(EEG.nbchan),'/',EEG.ref));

set(findobj('Tag','Frames'),'string',strcat(num2str(EEG.pnts),'/',num2str(EEG.srate)));

set(findobj('Tag','Epochs'),'string',strcat(num2str(EEG.trials),'/',num2str(size(EEG.event,2))));

set(findobj('Tag','Epochs time'),'string',strcat(num2str(EEG.xmin),'/', num2str(EEG.xmax)));

tmpdata = reshape( EEG.data(1:EEG.nbchan,:,:), EEG.nbchan, EEG.pnts*EEG.trials);
tmpdata = tmpdata - repmat(mean(tmpdata,2), [1 size(tmpdata,2)]); % zero mean
tmprank = getrank(tmpdata(:,1:min(3000, size(tmpdata,2))));

set(findobj('Tag','ICA weights'),'string',strcat(num2str(size(EEG.icaact,1)),'/', num2str(tmprank)));

function load_directory(EEG,fig)

% loaddircommand = ['findex = [1];try cd(EEG.filepath); catch, end; filecount = [1];files = dir(''*.set'');findex = find(strcmp({files.name}, EEG.filename));files = dir(''*.set'');set(findobj(''tag'',''FolderList''),''string'',{files(1:end).name},''value'',find(strcmp({files.name}, EEG.filename)));'];
% eval(loaddircommand);
if isstruct(EEG)
    findex = [1];
    try cd(EEG.filepath);
    catch
    end
    files = dir('*.set');
    findex = find(strcmp({files.name}, EEG.filename));
    set(findobj(fig,'tag','FolderList'),'string',{files(1:end).name},'value',find(strcmp({files.name}, EEG.filename)));
end

function selectall(src,evt,value)
    
    
    % --- click or unclick the tag
    %clickVal = get(findobj(gcf,'Style','checkbox));
    
    set(findobj(gcf,'Style','checkbox'),'Value', value);
    
    % --- turn button color red or green
    
    clickVal = abs(value);
    
    % --- get all component buttons
    all_buttons = findobj(gcf,'Style','pushbutton');
    % --- 9 is the number of buttons on the end of the page! If I add more buttons
    % IF I AD MORE BUTTONS 9 NEEDS TO CHANGE!
    
    comp_buttons = all_buttons(9:end);
    
    if clickVal == 1
        %set(findobj(gcf,'Style','checkbox'),'BackgroundColor',[1 .5 .5])
        set(comp_buttons,'BackgroundColor',[1 .5 .5])
    else
        %set(findobj(gcf,'Style','checkbox'),'BackgroundColor',[.75 1 .75])
        set(comp_buttons,'BackgroundColor',[.75 1 .75])
    end



function checkbox(src,evt,index,clicked_box,fig)
    
    fig = findobj('Tag','eegplot_adv');

    if nargin < 3
        clicked_box = 0;
    end
    g = get(fig,'UserData');
    
    g.events_show(str2num(index)) = abs(g.events_show(str2num(index)) - 1);

    % remove this event from the events list
    % or add the event back to the events list

    set(fig,'UserData',g)
 
    % --- click or unclick the tag
%     clickVal = get(findobj(fig,'Tag',index),'Value');
%     if clicked_box == 0
%         clickVal = abs(clickVal-1);
%     end

    %set(findobj(fig,'Tag',index),'Value', clickVal);
    
    % --- turn button color red or green
%     
%     if clickVal == 1
%         %set(findobj(gcf,'Style','checkbox'),'BackgroundColor',[1 .5 .5])
%         set(findobj(fig,'Tag',strcat('comp',index)),'BackgroundColor',[1 .5 .5])
%     else
%         %set(findobj(gcf,'Style','checkbox'),'BackgroundColor',[.75 1 .75])
%         set(findobj(fig,'Tag',strcat('comp',index)),'BackgroundColor',[.75 1 .75])
%     end


function apply_eventchanges(src,evt)


fig = findobj('Tag','eegplot_adv');
g = get(findobj('Tag','eegplot_adv'),'UserData');

events = get(findobj(gcf,'tag','check'),'Value');
events2 = flipud(cell2mat(events));
% pop events unselected events out of g.allevents using g.events_show
% redo all events

tmpevents = g.allevents;

g.events_show = events2;

toberemoved = g.eventtypes(~events2);

tmpremovelist = [];

for i = 1:size(g.allevents,2)

    if any(tmpevents(i).type == string(toberemoved))
        tmpremovelist = cat(2,tmpremovelist,double(i));

    end

end

tmpevents(tmpremovelist) = [];

g.events = tmpevents;

  if ~isempty(g.events)
      if ~isfield(g.events, 'type') || ~isfield(g.events, 'latency'), g.events = []; end
  end
      
  if ~isempty(g.events)
      if ischar(g.events(1).type)
           [g.eventtypes, ~, indexcolor] = unique_bc({g.events.type}); % indexcolor countinas the event type
      else [g.eventtypes, ~, indexcolor] = unique_bc([ g.events.type ]);
      end
      %indexcolor=length(indexcolor)-indexcolor+1;
      g.eventcolors     = { 'r', [0 0.8 0], 'b', 'm', [1 0.5 0],  [0.5 0 0.5], [0.6 0.3 0] };  
      g.eventstyle      = { '-' '-' '-'  '-'  '-' '-' '-' '--' '--' '--'  '--' '--' '--' '--'};
      g.eventwidths     = [ 2.5 1 ];
      g.eventtypecolors = g.eventcolors(mod([1:length(g.eventtypes)]-1 ,length(g.eventcolors))+1);
      g.eventcolors     = g.eventcolors(mod(indexcolor-1               ,length(g.eventcolors))+1);
      g.eventtypestyle  = g.eventstyle (mod([1:length(g.eventtypes)]-1 ,length(g.eventstyle))+1);
      g.eventstyle      = g.eventstyle (mod(indexcolor-1               ,length(g.eventstyle))+1);
      
      % for width, only boundary events have width 2 (for the line)
      % -----------------------------------------------------------
      indexwidth = ones(1,length(g.eventtypes))*2;
      if iscell(g.eventtypes)
          index=find(ismember(g.eventtypes,{'boundary'}));
          if ~isempty(index)
              indexwidth(index) = 1;
              g.eventtypestyle{index} = '-';
              g.eventtypecolors{index} = 'c';
              g.eventstyle(find(indexcolor==index))={'-'};
              g.eventcolors(find(indexcolor==index))={'c'};
          end
      end
      g.eventtypewidths = g.eventwidths (mod(indexwidth([1:length(g.eventtypes)])-1 ,length(g.eventwidths))+1);
      g.eventwidths     = g.eventwidths (mod(indexwidth(indexcolor)-1               ,length(g.eventwidths))+1);
      
      % latency and duration of events
      % ------------------------------
      g.eventlatencies  = [ g.events.latency ]+1;
      if isfield(g.events, 'duration')
           durations = { g.events.duration };
           durations(cellfun(@isempty, durations)) = { NaN };
           g.eventlatencyend   = g.eventlatencies + [durations{:}]+1;
      else g.eventlatencyend   = [];
      end
      g.plotevent       = 'on';
  end
  if isempty(g.events)
      g.plotevent      = 'off';
  end

  close(gcf);

  set(fig,'UserData',g);

  eegplot_adv('drawp', 0);

  %draw_data([],[],fig,9,[],g);



