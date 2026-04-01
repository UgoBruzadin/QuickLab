% pop_autobssemgQL() - Automatic EMG correction using Blind Source Separation
%
% Usage:
%   >> OUTEEG = pop_autobssemg(INEEG, wl, ws, bss_alg, bss_opt, crit_alg, crit_opt)
%
% Inputs:
%   INEEG    - input EEG dataset
%   wl       - analysis window length (in seconds)
%   ws       - shift between correlative analysis windows (in seconds)
%   bss_alg  - name of the BSS algorithm to use
%   bss_opt  - options to pass to the BSS algorithm as
%              {opt_name1, opt_value1,opt_name2,opt_value2,...}
%   crit_alg - name of the criterion for selecting the components to remove
%   crit_opt  - options to pass to the criterion function as
%              {opt_name1, opt_value1,opt_name2,opt_value2,...}
%
% Outputs:
%   OUTEEG  - output dataset
%
% Notes:
%
% (*) The automatic method for correcting EMG artifacts using CCA was
%     originally proposed by Wim et al. in:
%
%     De Clercq, W. et al., A new muscle artifact removal technique to improve
%     interpretation of the ictal scalp electroencephalogram, Proceedings of
%     EMBC 2005, Shanghai, China, pp. 1136-1139.
%
% (*) When using pop_autobssemg from the command line a pop_up window will
%     be displayed ONLY if the user did not provide the value of the window
%     length, that is, only if there is a single input parameter. 
%
% See also:
%   AUTOBSS, EMG_PSD, EEGLAB

% Modified script - Copyright (C) <2021>  Matthew Gunn matthewpgunn@gmail.com
% Original script - Copyright (C) <2007>  German Gomez-Herrero, http://germangh.com

function [EEGOUT, com] = pop_par_autobssemgQL(EEG, wl, ws, bss_alg, bss_opt, crit_alg, crit_opt)



com = '';
if nargin < 2,
    % at least the first 2 params are required or the pop-up window will appear
    showpopup = true;
else
    showpopup = false; % do not show pop-up window unless completely necessary
end

if nargin < 1,
    help pop_autobssemgNL;
    return;
end

EEGIN = EEG; % ADDED UGO

if isempty(EEGIN.data)
    disp('(pop_autobssemg) error: cannot clean an empty dataset'); return;
end;

% default window length/shift (just a rule of thumb)
% ---------------------------
N = EEGIN.pnts*size(EEGIN.data,3);
def_wl_samples = EEGIN.srate*0.02*EEGIN.nbchan^2;
if size(EEGIN.data,3) > 1
    def_wl_samples = def_wl_samples-mod(def_wl_samples,EEGIN.pnts);
end
def_wl_samples = min(def_wl_samples,N);
def_wl = def_wl_samples/EEGIN.srate;
def_ws = def_wl;

% use default wl and ws?
% ---------------------------
if nargin < 2 || (isempty(wl) && isempty(ws)),
    wl = def_wl;
    ws = def_ws;
elseif nargin < 3,
    ws = wl;
end

% find available algorithms
% -----------------------------
allalgs = {'bsscca','iwasobi','efica','multicombi','fcombi','sobi','fpica', ...
    'runica','jader','fastica','pca'};
selectalg = {};

for index = 1:length(allalgs)
    if exist([allalgs{index} '_ifc'],'file') && exist([allalgs{index}],'file'),
        selectalg = {selectalg{:} allalgs{index}};
    end
end
if isempty(selectalg),
    error('(pop_autobssemg) I could not find an interface function for any BSS algorithm');
end

% use default BSS algorithm with default options?
% ----------------------------------------------------
if nargin < 4 || isempty(bss_alg),
    bss_alg = selectalg{1};
elseif isempty(bss_alg) && nargin > 4 && ~isempty(bss_opt),
    showpopup = true; % wrong input -> show pop-up window!
end
if nargin < 5 || isempty(bss_opt),  
   switch lower(bss_alg),
       case 'bsscca',
           bss_opt = {'eigratio',1e6};           
       otherwise,
           bss_opt = {};           
   end
end

% find available criteria to remove components
% ---------------------------------------------
sptver = ver('signal');

if isempty(sptver) || (str2double(sptver.Version)<6.2 && datenum(sptver.Date)<datenum('1-Jan-2007')),
    error('(pop_autobssemg) all available criteria require MATLAB''s Signal Processing Toolbox v.6.2 or newer');
else
    allcrits = {'emg_psd'};
end
selectcrit = {};
for index = 1:length(allcrits)
    if exist([allcrits{index}],'file') && exist([allcrits{index}],'file'),
        selectcrit = {selectcrit{:} allcrits{index}};
    end
end
if isempty(selectcrit),
    error('(pop_autobssemg) I could not find any criterion function');
end

% user wants to use the default criterion with default options
% ----------------------------------------------------
if nargin < 6 || isempty(crit_alg),
    crit_alg = selectcrit{1};
elseif isempty(crit_alg) && nargin > 6 && ~isempty(crit_alg),
    showpopup = true; % wrong input -> show pop-up window!
end

if nargin < 7 || isempty(crit_opt),
    % user wants def. criterion options    
    switch lower(crit_alg),
        case 'emg_psd',
            sl = min(floor(EEGIN.srate/2),floor(wl/5)*EEGIN.srate); % 5 windows will be used by default
            estimator = spectrum.welch({'Hamming'},sl);
            crit_opt = {'ratio',10,'fs',num2str(EEGIN.srate),'femg',15,'estimator',...
                estimator,'range',[0 floor(EEGIN.nbchan/2)]};
        otherwise,
            crit_opt = {};
    end
end

% default spectral estimator (assumes default criterion is emg_psd)
% ---------------------------
if ~strcmpi(selectcrit{1},'emg_spd'),
    sl = min(floor(EEGIN.srate/2),floor(wl/5)*EEGIN.srate); % 5 windows will be used by default
    def_estimator = ['spectrum.welch({''Hamming''},' num2str(sl) ')'];           
else
    def_estimator = '';
end

% build the string of default criterion options
% ---------------------------
switch lower(selectcrit{1}),
    case 'emg_psd',
        def_criterion_opts = ['''ratio'',10,''fs'',' num2str(EEGIN.srate) ...
    ',''femg'',15,''estimator'',' def_estimator ',''range'',[' ... 
        num2str([0 floor(EEGIN.nbchan/2)]) ']'];
    otherwise,
        def_criterion_opts = '';        
end


% display input dialog
% ---------------------------
datais = EEGIN.trials;
if EEGIN.trials == 1
    datais = 'Continuous';    
    def_w2 = 1+(rem(EEGIN.xmax,1)/floor(EEGIN.xmax));
    userdata.Cur = 1;
else
    datais = 'Epoched';
    def_w2 = (abs(EEGIN.xmax)+abs(EEGIN.xmin))*2;
    userdata.Cur = 2;
end
userdata.T = (abs(EEGIN.xmax)+abs(EEGIN.xmin))*EEGIN.trials;
userdata.TT =  EEGIN.trials;
userdata.TO = def_w2;
cb_i = [ 'AA = get(gca,''Parent'');AB = get(AA,''userdata'');'...
    'AB.Cur = floor(AB.Cur) + 1;'...
    'if AB.TT == 1;'...
    'def_w2 = AB.T/(floor(AB.T)/AB.Cur);'...
    'else;'...
    'def_w2 = AB.Cur*(AB.T/AB.TT);'...
    'end;'...
    'set(findobj(AA, ''tag'', ''QLw1''),''string'', string(def_w2));'...
    'set(findobj(AA, ''tag'', ''QLw2''),''string'', string(def_w2));'...
    'set(get(gca,''Parent''), ''UserData'', AB);'];
cb_c = [ 'AA = get(gca,''Parent'');AB = get(AA,''userdata'');'...
    'AB.Cur = floor(str2double(get(findobj(AA, ''tag'', ''QLw1''),''string'')));'...
        'if floor(AB.Cur) < 1 ||(AB.T*(floor(AB.T)/AB.Cur))<= AB.TO || AB.Cur*(AB.T/AB.TT)<= AB.TO;'...
            'if AB.TT == 1;'...
                 'AB.Cur = 1;'...
                 'def_w2 = AB.T/(floor(AB.T)/AB.Cur);'...
            'else;'...
                 'AB.Cur = 2;'...    
                 'def_w2 = AB.Cur*(AB.T/AB.TT);'...
            'end;'...
        'end;'...
        'if AB.TT == 1;'...
            'def_w2 = AB.T/(floor(AB.T)/AB.Cur);'...
        'else;'...
        'if (floor(AB.Cur/2)*(AB.T/AB.TT)) <= AB.TO;'...
        'def_w2 =  AB.TO;'...
        'else;'...
            'def_w2 = floor(AB.Cur/2)*(AB.T/AB.TT);'...
            'end;'...
        'end;'...
    'set(findobj(AA, ''tag'', ''QLw1''),''string'', string(def_w2));'...
    'set(findobj(AA, ''tag'', ''QLw2''),''string'', string(def_w2));'...
    'set(get(gca,''Parent''), ''UserData'', AB);'];
cb_c2 = [ 'AA = get(gca,''Parent'');AB = get(AA,''userdata'');'...
    'AB.Cur = floor(str2double(get(findobj(AA, ''tag'', ''QLw2''),''string'')));'...
        'if floor(AB.Cur) < 1 ||(AB.T*(floor(AB.T)/AB.Cur))<= AB.TO || AB.Cur*(AB.T/AB.TT)<= AB.TO;'...
            'if AB.TT == 1;'...
                 'AB.Cur = 1;'...
                 'def_w2 = AB.T/(floor(AB.T)/AB.Cur);'...
            'else;'...
                 'AB.Cur = 2;'...    
                 'def_w2 = AB.Cur*(AB.T/AB.TT);'...
            'end;'...
        'end;'...
        'if AB.TT == 1;'...
            'def_w2 = AB.T/(floor(AB.T)/AB.Cur);'...
        'else;'...
        'if (floor(AB.Cur/2)*(AB.T/AB.TT)) <= AB.TO;'...
        'def_w2 =  AB.TO;'...
        'else;'...
            'def_w2 = floor(AB.Cur/2)*(AB.T/AB.TT);'...
            'end;'...
        'end;'...
    'set(findobj(AA, ''tag'', ''QLw2''),''string'', string(def_w2));'...
    'set(get(gca,''Parent''), ''UserData'', AB);'];
cb_d = [ 'AA = get(gca,''Parent'');AB = get(AA,''userdata'');'...
        'if floor(AB.Cur) - 1 < 1;'...
            'return;'...
        'else;'...
            'AB.Cur = floor(AB.Cur) - 1;'...
            'if (AB.T*(floor(AB.T)/AB.Cur))+.0001<= AB.TO || AB.Cur*(AB.T/AB.TT)+.0001<= AB.TO ;'...
                'AB.Cur = floor(AB.Cur) + 1;'...
                'return;'...
            'end;'...    
        'end;'...
    'if AB.TT == 1;'...
        'def_w2 = AB.T/(floor(AB.T)/AB.Cur);'...
    'else;'...
        'def_w2 = AB.Cur*(AB.T/AB.TT);'...
    'end;'...
    'set(findobj(AA, ''tag'', ''QLw1''),''string'', string(def_w2));'...
    'set(findobj(AA, ''tag'', ''QLw2''),''string'', string(def_w2));'...
    'set(get(gca,''Parent''), ''UserData'', AB);'];
cb_cb1 = ['AA = get(gca,''Parent'');AB = get(AA,''userdata'');'...
    'set(findobj(AA, ''tag'', ''NL2''),''Value'', 0);'];
cb_cb2 = ['AA = get(gca,''Parent'');AB = get(AA,''userdata'');'...
    'set(findobj(AA, ''tag'', ''NL1''),''Value'', 0);'];
%showpopup = 1;
if showpopup
    uigeom = {[1.5 1] 1 [1 1 1 1 1 1 1] [1.5 1 1] [1.5 1 1 ] 1 [1.5 1 1] [1.5 1 1 ] 1 1 1 1 [1.5 1] 1 1};
    uilist = { { 'style' 'text'      'string'    'BSS algorithm:'} { 'style' 'popupmenu' 'string'    selectalg} ...
        {} ...
        {'style'  'text'      'string'    'Defaults to QuickLab' 'fontweight', 'bold'} ...
        {'style'  'text'      'string'    strcat('Data is:',{' '}, datais) 'fontweight', 'bold'} ...
        {'style'  'text'      'string'    strcat('Time Per epoch:',{' '}, num2str(userdata.T)) 'fontweight', 'bold'} ...
        { 'Style', 'pushbutton', 'string', 'Increase Window',  'callback', [cb_i]} ...
        { 'Style', 'pushbutton', 'string', 'Decrease Window',  'callback', [cb_d]} ...
        {} {}...
        {'style'  'text'      'string'    'QuickLab - Analysis window length (seconds):'} {'style'  'edit'      'string'    num2str(def_w2),'tag','QLw1','Value',userdata.Cur,'callback', cb_c} { 'Style', 'checkbox'  , 'string', 'Check to use these values', 'value', 1,'tag','NL1','callback', cb_cb1}  ...      
{'style'  'text'   'string'    'QuickLab - Shift between correlative windows (seconds):'} {'style'  'edit'      'string'    num2str(def_w2),'tag','QLw2','Value',userdata.Cur,'callback', cb_c2} {}...
        {} ...
        {'style'  'text'      'string'    'EEGLAB - Analysis window length (seconds):'}   {'style'  'edit'      'string'    num2str(def_wl)} { 'Style', 'checkbox'  , 'string', 'Check to use these value', 'value', 0,'tag','NL2','callback', cb_cb2}...
        {'style'  'text'      'string'    'EEGLAB - Shift between correlative windows (seconds):'} {'style'  'edit'      'string'    num2str(def_ws)} {}......
        {} ...
        {'style'  'text'      'string'    'Options to pass to the BSS algorithm ([option_name],[value],...):'} ...
        {'style'  'edit'      'string'    '''eigratio'',1e6'} ...
        {'style'  'text'      'string'    ''} ...
        { 'style' 'text'      'string'    'Criterion to remove components:'} ...
        { 'style' 'popupmenu' 'string'    selectcrit} ...
        {'style'  'text'      'string'    'Options to pass to the criterion ([option_name],[value],...):'} ...
        {'style'  'edit'      'string'    def_criterion_opts} ...
        };
    guititle = 'Correct EMG using BSS -- pop_autobssemg()';
%     result = inputgui( uigeom, uilist, 'pophelp(''pop_autobssemg'')', guititle, [],'normal');
    result = inputgui( 'geometry', uigeom, 'uilist', uilist, 'helpcom', ...
        'pophelp(''pop_autobssemgQL'');', 'title', guititle,'mode', 'normal', 'geomvert',[], ...
        'userdata', userdata);
    if isempty(result), return; end

    % Which pararams
    % -------------------
    if result{1,3} == 1
        result(:,5:7 ) = [];
        result(:,3 ) = [];
    elseif result{1,6} == 1
        result(:,6 ) = [];
        result(:,2:4 ) = [];
    end
    % reading params
    % -------------------
    bss_alg = selectalg{result{1}};
%     wl = eval(['[' result{2} ']']);
%     ws = eval(['[' result{3} ']']);    
    wl = wl + (((abs(EEG.xmin)+abs(EEG.xmax)))/EEG.pnts)*5;
    ws = ws + (((abs(EEG.xmin)+abs(EEG.xmax)))/EEG.pnts)*5;
    if size(EEG.data,3) > 1
        wl = eval(['[' result{2} ']']);
        ws = eval(['[' result{3} ']']);
    end

    % read BSS parameters
    % -------------------
    bss_opt = eval(['{' result{4} '}']);

    % criterion
    % -----------
    crit_alg = selectcrit{result{5}};

    % criterion parameters
    % ---------------------
    crit_opt = eval(['{' result{6} '}']);   
end

% correct wl,ws so that they will be an integer number of trials
% -------------------
wl = min(floor(wl*EEGIN.srate),EEGIN.pnts*EEGIN.trials);
ws = min(floor(ws*EEGIN.srate),EEGIN.pnts*EEGIN.trials);
if size(EEGIN.data,3) > 1,
    wl = wl-mod(wl,EEGIN.pnts);
    ws = ws-mod(ws,EEGIN.pnts);
end

opt = struct;

% build BSS parameters structure
% -------------------------------
if exist('bss_opt','var'),
    opt.bss_opt = struct;
    for i = 1:2:length(bss_opt),
        opt.bss_opt.(bss_opt{i}) = bss_opt{i+1};
    end
end

% build criterion parameters structure
% -------------------------------
if exist('crit_opt','var'),
    opt.crit_opt = struct;
    for i = 1:2:length(crit_opt),
        opt.crit_opt.(crit_opt{i}) = crit_opt{i+1};
    end
end
opt.crit_opt.eogref = [];

% rest of parameters
% -------------------
opt.wl = wl;
opt.ws = ws;
opt.bss_alg = bss_alg;
opt.crit_alg = crit_alg;
opt.crit_opt.fs = EEGIN.srate;

% run the EMG correction
% -------------------
EEGIN.data = par_autobss(reshape(EEGIN.data,EEGIN.nbchan,EEGIN.pnts*EEGIN.trials),opt);
EEGIN.data = reshape(EEGIN.data,[EEGIN.nbchan,EEGIN.pnts,EEGIN.trials]);


% command history
% -------------------
bss_opt_str = [];
for i = 1:2:length(bss_opt),
    if isnumeric(bss_opt{i+1}),
        bss_opt_str = [bss_opt_str ',''' bss_opt{i} ''', [' num2str(bss_opt{i+1}) ']'];
    elseif ischar(bss_opt{i+1}),
        bss_opt_str = [bss_opt_str ',''' bss_opt{i} ''',''' bss_opt{i+1} ''''];
    else
        bss_opt_str = [bss_opt_str ',''' bss_opt{i} ''',''' class(bss_opt{i+1}) ''''];        
    end
end
if ~isempty(bss_opt_str),
    bss_opt_str(1)=[];
end

crit_opt_str = [];
for i = 1:2:length(crit_opt),
    if isnumeric(crit_opt{i+1}),
        crit_opt_str = [crit_opt_str ',''' crit_opt{i} ''', [' num2str(crit_opt{i+1}) ']'];
    elseif ischar(crit_opt{i+1}),
        crit_opt_str = [crit_opt_str ',''' crit_opt{i} ''',''' crit_opt{i+1} ''''];
    else
        crit_opt_str = [crit_opt_str ',''' crit_opt{i} ''',' class(crit_opt{i+1})];
    end
end
if ~isempty(crit_opt_str),
    crit_opt_str(1)=[];
end

EEGdiff = EEGIN.data - EEG.data;
    %eegplot_w( EEGdiff, 'srate', EEGIN.srate, 'title', [ 'DIFFERENCE PRE AND POST CHANNEL/COMPONENT INTERPOLATION -- eegplot_w(): ' EEGIN.setname], ...
    %    'limits', [EEGIN.xmin EEGIN.xmax]*1000 )% , 'command', command, eegplotoptions{:}, varargin{:});

EEGOUT = EEGIN;
    
com = sprintf( '%s = pop_autobssemg( %s, [%s], [%s], ''%s'', {%s}, ''%s'', {%s});', inputname(1), ...
    inputname(1), num2str(wl/EEGIN.srate), num2str(ws/EEGIN.srate), bss_alg, ...
    bss_opt_str, crit_alg, crit_opt_str);

return;
