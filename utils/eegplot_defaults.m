function g = eegplot_defaults(g, data, EEG)
% eegplot_defaults() - Initialize all g struct fields with defaults.
%   Single source of truth for the eegplot_adv state struct.
%   Only sets fields that don't already exist in g (user-provided values win).
%
% Usage:
%   g = eegplot_defaults(g, data, EEG)
%
% The g struct fields are organized by category:
%
% DATA STATE
%   .data          []          Current display data matrix
%   .data_ch       []          Channel data backup (from EEG.data)
%   .data_pc       []          Component data backup (from EEG.icaact)
%   .data2         []          Secondary data overlay
%   .EEG           struct      Full EEG struct reference
%
% DISPLAY
%   .srate         256         Sampling rate in Hz
%   .spacing       0           Vertical spacing between channels (0 = auto)
%   .spacing_ch    0           Saved channel spacing
%   .spacing_pc    4           Saved component spacing
%   .winlength     5           Window length in seconds
%   .dispchans     nchans      Number of channels displayed
%   .chans         nchans      Total number of channels
%   .elecoffset    0           Electrode offset for scrolling
%   .submean       'on'        Subtract mean from display ('on'/'off')
%   .envelope      0           Envelope display mode
%   .plotdata2     'off'       Plot secondary data overlay
%
% ELECTRODE/COMPONENT INFO
%   .eloc_file     0           Electrode locations (struct or 0=numbered)
%   .eloc_file_ch  0           Channel electrode locations
%   .eloc_file_pc  0           Component electrode locations
%
% REJECTION/MARKING
%   .winrej        []          Current rejection windows [start end R G B chan1..chanN]
%   .winrej_ch     []          Channel view rejection backup
%   .winrej_pc     []          Component view rejection backup
%   .winstatus     1           Show rejection windows (1=on, 0=off)
%
% NORMALIZATION
%   .normed        0           Normalization state (0=off, 1=on)
%   .normed_ch     0           Channel normalization state
%   .normed_pc     0           Component normalization state
%   .datastd       []          Per-channel standard deviations
%   .datastd_ch    []          Channel std backup
%   .datastd_pc    []          Component std backup
%
% EPOCHS/TRIALS
%   .trialstag     -1          Trial tag (-1 = continuous data)
%   .limits        [auto]      Time limits in ms
%   .isfreq        0           Frequency mode flag
%   .freqs         []          Frequency vector
%   .freqlimits    []          Frequency display limits
%
% EVENTS
%   .events        []          Event structure array
%   .allevents     []          All events (unfiltered)
%   .events_show   []          Event filter
%   .plotevent     'on'        Plot events ('on'/'off')
%   .ploteventdur  'off'       Plot event duration
%   .maxeventstring 20         Max chars for event labels
%
% FIGURE/UI
%   .fullscreen    'on'        Fullscreen mode
%   .position      [50 50 800 500]  Figure position (non-fullscreen)
%   .title         'Scroll...' Figure title
%   .plottitle     ''          Plot title text
%   .tag           'eegplot_adv'  Figure tag
%   .backcolor     [.93 .96 1] Background color
%   .color         'off'       Multi-color channel mode
%   .wincolor      [0 1 0]     Interpolation window color
%   .xgrid         'off'       X grid lines
%   .ygrid         'off'       Y grid lines
%   .scale         'on'        Show scale eye
%   .matrixpos     [pos]       Matrix display position
%   .headpos       [pos]       Topoplot head position
%
% COMMANDS/CALLBACKS
%   .command       ''          Apply button command
%   .command2      ''          Secondary command
%   .savecommand   ''          Save command
%   .savecommand2  ''          Secondary save command
%   .selectcommand {'' '' ''}  Mouse select commands
%   .ctrlselectcommand {'' '' ''} Ctrl+mouse commands
%   .butlabel      'Interpolate & Reject'  Apply button label
%
% INTERNAL STATE
%   .rand          random      Random ID for this instance
%   .old           {}          Undo history
%   .gnumber       1           History position
%   .typing        0           Text input active flag
%   .children      0           Child figure handle
%   .com           ''          Command history string
%   .TBTcom        ''          TBT command history
%   .e             []          Temporary event storage
%
% Author: Ugo Bruzadin Nunes
% Copyright (C) 2021 Ugo Bruzadin Nunes

% Ensure g is a struct before anything else
if nargin < 1 || isempty(g) || ~isstruct(g)
    g = struct();
end

% Load color defaults
try
    QuickLabDefs;
catch
    DEFAULT_PLOT_INTERP = [0 1 0];
end

ORIGINAL_POSITION = [50 50 800 500];

% --- Static defaults (no dependencies) ---
static = struct( ...
    'data',             [], ...
    'data2',            [], ...
    'rand',             floor(rand()*1000), ...
    'old',              {{}}, ...
    'gnumber',          1, ...
    'typing',           0, ...
    'srate',            256, ...
    'spacing',          0, ...
    'spacing_ch',       0, ...
    'spacing_pc',       4, ...
    'eloc_file',        0, ...
    'eloc_file_ch',     0, ...
    'eloc_file_pc',     0, ...
    'winlength',        5, ...
    'fullscreen',       'on', ...
    'position',         ORIGINAL_POSITION, ...
    'title',            'Scroll activity -- eegplot_adv()', ...
    'plottitle',        '', ...
    'trialstag',        -1, ...
    'winrej',           [], ...
    'winrej_pc',        [], ...
    'winrej_ch',        [], ...
    'winstatus',        1, ...
    'command',          '', ...
    'command2',         '', ...
    'tag',              'eegplot_adv', ...
    'xgrid',            'off', ...
    'ygrid',            'off', ...
    'backcolor',        [0.93 .96 1], ...
    'color',            'off', ...
    'wincolor',         DEFAULT_PLOT_INTERP, ...
    'submean',          'on', ...
    'children',         0, ...
    'freqs',            [], ...
    'freqlimits',       [], ...
    'butlabel',         'Interpolate & Reject', ...
    'scale',            'on', ...
    'events',           [], ...
    'events_show',      [], ...
    'e',                [], ...
    'ploteventdur',     'off', ...
    'plotdata2',        'off', ...
    'mocap',            'off', ...
    'selectcommand',    {{'' '' ''}}, ...
    'ctrlselectcommand',{{'' '' ''}}, ...
    'datastd',          [], ...
    'datastd_ch',       [], ...
    'datastd_pc',       [], ...
    'normed',           0, ...
    'normed_ch',        0, ...
    'normed_pc',        0, ...
    'envelope',         0, ...
    'maxeventstring',   20, ...
    'isfreq',           0, ...
    'savecommand',      '', ...
    'savecommand2',     '', ...
    'matrixpos',        [0.922 0.25 0.075 0.13], ...
    'headpos',          [0.915 0.25 0.080 0.13], ...
    'com',              '', ...
    'TBTcom',           '', ...
    'panels',           [] ...
);

% Compare struct (pre/post comparison — see design/TABBED_UI_DESIGN.m)
if ~isfield(g, 'compare')
    g.compare = struct('storage','none', 'diff_sparse',[], 'tempfile','', ...
        'undo_entry',[], 'compat',0, 'mode','off', 'msg','', ...
        'pre_nbchan',0, 'pre_pnts',0, 'pre_trials',0, 'timestamp',0);
end

% Apply static defaults: only set fields that don't already exist
fields = fieldnames(static);
for i = 1:length(fields)
    if ~isfield(g, fields{i})
        g.(fields{i}) = static.(fields{i});
    end
end

% --- Dynamic defaults (depend on data, EEG, or other g fields) ---
if ~isfield(g, 'data_ch')
    try g.data_ch = EEG.data; catch, g.data_ch = []; end
end
if ~isfield(g, 'data_pc')
    try g.data_pc = EEG.icaact; catch, g.data_pc = []; end
end
if ~isfield(g, 'limits')
    g.limits = [0 1000*(size(data,2)-1)/g.srate];
end
if ~isfield(g, 'dispchans')
    g.dispchans = size(data,1);
end
if ~isfield(g, 'colmodif')
    g.colmodif = { g.wincolor };
end
if ~isfield(g, 'allevents')
    g.allevents = g.events;
end
