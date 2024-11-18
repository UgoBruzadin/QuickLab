% POP_VIEWPROPS2 See  common properties of many EEG channel or component
%   Creates a figure containing a scalp topography or channel location for
%   each selected component or channel. Pressing the button above the scalp
%   topopgraphies will open pop_prop_extended for that component or
%   channel. If pop_viewprops is called with only the first two arguments,
%   a GUI opens to select the rest. If only one argument is given, typecomp
%   will be set to channels (1) and the GUI will open.
%
%   Inputs
%       EEG: EEGLAB EEG structure
%       typecomp: 0 for component, 1 for channel
%       chanorcomp:  channel or component index to plot
%       spec_opt:  cell array of options which are passed to spectopo()
%       erp_opt:  cell array of options which are passed to erpimage()
%       scroll_event:  0 to hide events in scroll plot, 1 to show them
%       classifier_name:  string indicating which component classifier to
%           use (must match a field name in EEG.etc.ic_classification)
%       fig: figure handle for the figure to use.
%
%   See also: pop_prop_extended2()
%
%   Adapted from pop_selectcomps Luca Pion-Tonachini (2017)
%   Modified by: Ugo Bruzadin Nunes
%
% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
% Copyright (C) 2021 Ugo Bruzadin Nunes

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

% 01-25-02 reformated help & license -ad

function [EEG,com,fig] = pop_viewprops_adv_ax( EEG, typecomp, newcommand, chanorcomp, spec_opt, erp_opt, fig_opts, scroll_event, classifier_name, fig,visible)

COLACC = [0.75 1 0.75];
PLOTPERFIG = size(EEG.icawinv,2);
com = '';

QuickLabDefs;
%COLACC = DEFAULT_FIG_COLOR;
if nargin < 11 || isempty(visible)
    visible = 'on';
end

if nargin < 1
    help pop_viewprops2;
    return;
end

if nargin < 2 || isempty(typecomp)
    typecomp = 1; % default
end

if nargin < 3 || isempty(newcommand)
    newcommand = '';
end

if nargin < 4 || isempty(chanorcomp)
    if typecomp
        chanorcomp = [1:EEG.nbchan];
    else
        chanorcomp = [1:size(EEG.icawinv,2)];
    end
end

if nargin < 5 || isempty(spec_opt)
    spec_opt = FREQDISPLAYDEFS(1:2);
    %spec_opt = [2:60];
% end
% if nargin < 6 || isempty(erp_opt)
    erp_opt = {};

%     
%     promptstr    = { fastif(typecomp,'Channel indices to plot:','Component indices to plot:') ...
%         'Spectral options (see spectopo() help):','Erpimage options (see erpimage() help):' ...
%         [' Draw events over scrolling ' fastif(typecomp,'channel','component') ' activity']};
%     if typecomp
%         inistr       = { ['1:' int2str(length(EEG.chanlocs))] ['''freqrange'', [2 ' num2str(min(55, EEG.srate/2)) ']'] '' 1};
%     else
%         inistr       = { ['1:' int2str(size(EEG.icawinv, 2))] ['''freqrange'', [2 ' num2str(min(55, EEG.srate/2)) ']'] '' 1};
%     end
%     stylestr     = {'edit', 'edit', 'edit', 'checkbox'};
%     
%     % labels when available
     if ~typecomp && isfield(EEG.etc, 'ic_classification')
         
         classifiers = fieldnames(EEG.etc.ic_classification);
         if ~isempty(classifiers)
             iclabel_ind = find(strcmpi(classifiers, 'ICLabel'));
             %promptstr = [promptstr {classifiers}];
             %inistr = [inistr {fastif(isempty(iclabel_ind), 1, iclabel_ind)}];
             %stylestr = [stylestr {'popupmenu'}];
         end
     end
%     
%     try
%         result       = inputdlg3( 'prompt', promptstr,'style', stylestr, ...
%             'default',  inistr, 'title', 'View many chan or comp. properties -- pop_viewprops2');
%     catch
%         result = [];
%     end
%     if size( result, 1 ) == 0
%         return; end
%     
%     chanorcomp   = eval( [ '[' result{1} ']' ] );
%     spec_opt     = eval( [ '{' result{2} '}' ] );
%     erp_opt     = eval( [ '{' result{3} '}' ] );
%     scroll_event     = result{4};
    if ~typecomp && isfield(EEG.etc, 'ic_classification') && ~isempty(classifiers)
        classifiers = fieldnames(EEG.etc.ic_classification);
        classifier_name = 'ICLabel';
    end
    
    %     if length(chanorcomp) > PLOTPERFIG
    %         ButtonName=questdlg2(strvcat(['More than ' int2str(PLOTPERFIG) fastif(typecomp,' channels',' components') ' so'],...
    %             'this function will pop-up several windows'), 'Confirmation', 'Cancel', 'OK','OK');
    %         if  ~isempty( strmatch(lower(ButtonName), 'cancel')), return; end;
    %     end;
    
end

if nargin < 7
    fig_opts = {1}; % planning for 1 for headmaps, 2 for ERP, 3 for freq, 4 for dipfit
end
if isempty(fig_opts)
    fig_opts = {1};
end
if ~isempty(fig_opts)
    if iscell(fig_opts{1})
        fig_opts = fig_opts{:};
    end
    if fig_opts{1} == 2
        tmpevent = EEG.event;
        if size(fig_opts,2) < 2
            [fig_opts{2},chanliststr] = pop_chansel( { EEG.chanlocs.labels } ); % choose channel projection
        end
        if size(fig_opts,2) < 3
            [fig_opts{3},tmpstr] = pop_chansel(unique({ tmpevent.type })); % choose event
        end
    end
end

if ~exist('spec_opt', 'var') || ~iscell(spec_opt) || isempty(spec_opt)
    spec_opt = {}; end
if ~exist('erp_opt', 'var') || ~iscell(erp_opt) || isempty(erp_opt)
    erp_opt = {}; end
if ~exist('scroll_event', 'var') || isempty(scroll_event)
    scroll_event = 1; end
if ~exist('classifier_name', 'var') || isempty(classifier_name)
    classifier_name = ''; end
fprintf('Drawing figure...\n');
currentfigtag = ['topo' num2str(floor(rand*1000))]; % generate a random figure tag

if length(chanorcomp) > PLOTPERFIG
    for index = 1:PLOTPERFIG:length(chanorcomp)
        pop_viewprops3_par(EEG, typecomp, chanorcomp(index:min(length(chanorcomp),index+PLOTPERFIG-1)), ...
            spec_opt, erp_opt, scroll_event, classifier_name);
    end
    com = sprintf('pop_viewprops2( %s, %d, %s, %s, %s, %d, ''%s'' )', ...
        inputname(1), typecomp, hlp_tostring(chanorcomp), hlp_tostring(spec_opt), ...
        hlp_tostring(erp_opt), scroll_event, classifier_name);
    return;
end

try
    icadefs;
    QuickLabDefs;
catch
    BACKCOLOR = [0.8 0.8 0.8];
    DEFAULT_FONT_COLOR = [0 0 0];
end

% set up the figure
% -----------------
column = ceil(sqrt( length(chanorcomp) ));
rows = ceil(length(chanorcomp)/column);
incx = 120;
incy = 110;
sizewx = 100/column;
if rows > 2
    sizewy = 90/rows;
else
    sizewy = 80/rows;
end
if ~exist('fig','var') || isempty(fig)
    fig = figure('name', [ 'View ' fastif(typecomp,'channels','components') ' properties - pop_viewprops2() (dataset: ' EEG.filename ')'], 'tag', currentfigtag, ...
        'numbertitle', 'off', 'color', BACKCOLOR,'Visible',visible);
    set(fig,'MenuBar', 'none');
    pos = get(fig,'Position');
    if ~typecomp && isfield(EEG.etc, 'ic_classification')
        set(fig,'Position', [pos(1) 20 800/7*column 600/5*rows*1.2]);
    else
        set(fig,'Position', [pos(1) 20 800/7*column 600/5*rows]);
    end    
end
pos = get(gca,'position'); % plot relative to current axes
q = [pos(1) pos(2) 0 0];
s = [pos(3) pos(4) pos(3) pos(4)]./100;
axis off;

% figure rows and columns
% -----------------------
if ~typecomp && EEG.nbchan > 64
    disp('More than 64 electrodes: electrode locations not shown');
    plotelec = 0;
else
    plotelec = 1;
end

classifier_name = 'ICLabel';
plot_labels = 1;
if size(EEG.icawinv, 2) ~= size(EEG.etc.ic_classification.(classifier_name).classifications, 1)
    warning(['The number of ICs do not match the number of IC classifications. This will result in incorrectly plotted labels. Please rerun ' classifier_name])
    plot_labels = 0;
end

count = 1;
tic
X = zeros(length(chanorcomp),1);
Y = zeros(length(chanorcomp),1);

DEFAULT_FONT_COLOR;

haspar = [];
haspar = ver('parallel');
%haspar = [];

switch fig_opts{1}
    case 1
        to = zeros(size(chanorcomp));
    case 2
        to = cell(size(chanorcomp));
    case 3
        to = cell(size(chanorcomp));
end

if ~isempty(haspar)
    parfor ri = chanorcomp
        %% plot the topoplot headmap
        %QuickLabDefs;
        figs(ri) = figure('tag',strcat('fig',int2str(ri),currentfigtag),'Visible','off');
        ax(ri) = axes('Tag',strcat('Ax',int2str(ri),currentfigtag));
        if typecomp
            switch fig_opts{1}
                case 1
                    to(ri) = topoplot( ri, EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
                        'electrodes','off', 'style', 'blank', 'emarkersize1chan', 12);
                case 2
                    [A,B,C,D,axhndls]  = pop_erpimage_ql(EEG,0, [ri],[[fig_opts{2}]],'',10,1,{'type'},fig_opts{3},'','yerplabel','erp','on','cbar','off'); %,'topo', { EEG.icawinv(:,[ri]) EEG.chanlocs EEG.chaninfo } );
                    to{ri} = axhndls;
                case 3
                    axhndls = quick_erpimage(EEG,ri);
                    to{ri} = axhndls; 
            end
        end

        switch fig_opts{1}
            case 1
                if plotelec
                    to(ri) = topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                        'off', 'style' , 'fill', 'chaninfo', EEG.chaninfo, 'numcontour', 8);
                else
                    to(ri) = topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                        'off', 'style' , 'fill','electrodes','off', 'chaninfo', EEG.chaninfo, 'numcontour', 8);
                end
            case 2
                     [A,B,C,D,axhndls] = pop_erpimage_ql(EEG,0, [ri],[[fig_opts{2}]],'',10,1,{'type'},fig_opts{3},'' ,'yerplabel','','erp','on','cbar','off');
                     to{ri} = axhndls;  
            case 3
                    axhndls = quick_erpimage(EEG,ri);
                    to{ri} = axhndls; 
        end
        checkcom = {@checkbox,int2str(ri),0};
        switch fig_opts{1}
            case 1
                set(to(ri),'ButtonDownFcn', checkcom);
            case 2
                set(axhndls{1},'ButtonDownFcn', checkcom);
            case 3
                set(axhndls{1},'ButtonDownFcn', checkcom);
        end
        axis square;

        % NEED TO PLOT ICLABEL
        if plot_labels == 1
            if ~typecomp && isfield(EEG.etc, 'ic_classification')
                classifiers = fieldnames(EEG.etc.ic_classification);
                if ~isempty(classifiers)
                    classifier_name = 'ICLabel';
                    [prob, classind] = max(EEG.etc.ic_classification.(classifier_name).classifications(ri, :));
                    t = title(sprintf('%s : %.1f%%', ...
                        EEG.etc.ic_classification.(classifier_name).classes{classind}, ...
                        prob*100));
                    set(t, 'Position', get(t, 'Position') .* [1 -1.2 1],'Color',DEFAULT_FONT_COLOR);
                end
            end
        end
    end
else
    for ri = chanorcomp
        %% plot the topoplot headmap

        figs(ri) = figure('tag',strcat('fig',int2str(ri),currentfigtag),'Visible','off');
        ax(ri) = axes('Tag',strcat('Ax',int2str(ri),currentfigtag));
        
        if typecomp
            switch fig_opts{1}
                case 1
                    to(ri) = topoplot( ri, EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
                        'electrodes','off', 'style', 'blank', 'emarkersize1chan', 12);
                case 2
                    [A,B,C,D,axhndls] = pop_erpimage_ql(EEG,0, [ri],[[fig_opts{2}]],'',10,1,{'type'},fig_opts{3},'','yerplabel','erp','on','cbar','off'); %,'topo', { EEG.icawinv(:,[ri]) EEG.chanlocs EEG.chaninfo } );
                    to{ri} = axhndls; 
                case 3
                    axhndls = quick_erpimage(EEG,ri);
                    to{ri} = axhndls; 
            end
        end

        switch fig_opts{1}
            case 1
                if plotelec
                    to(ri) = topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                        'off', 'style' , 'fill', 'chaninfo', EEG.chaninfo, 'numcontour', 8);
                else
                    to(ri) = topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                        'off', 'style' , 'fill','electrodes','off', 'chaninfo', EEG.chaninfo, 'numcontour', 8);
                end
            case 2
                    [A,B,C,D,axhndls] = pop_erpimage_ql(EEG,0, [ri],[[fig_opts{2}]],'',10,1,{'type'},fig_opts{3},'' ,'yerplabel','','erp','on','cbar','off');
                    to{ri} = axhndls;  
            case 3
                    axhndls = quick_erpimage(EEG,ri);
                    to{ri} = axhndls; 
        % end
        end
        checkcom = {@checkbox,int2str(ri),0};
        switch fig_opts{1}
            case 1
                set(to(ri),'ButtonDownFcn', checkcom);
            case 2
                set(axhndls{1},'ButtonDownFcn', checkcom);
            case 3
                set(axhndls{1},'ButtonDownFcn', checkcom);
        end
        axis square;

        % NEED TO PLOT ICLABEL
        if plot_labels == 1
            if ~typecomp && isfield(EEG.etc, 'ic_classification')
                classifiers = fieldnames(EEG.etc.ic_classification);
                if ~isempty(classifiers)
                    classifier_name = 'ICLabel';
                    [prob, classind] = max(EEG.etc.ic_classification.(classifier_name).classifications(ri, :));
                    t = title(sprintf('%s : %.1f%%', ...
                        EEG.etc.ic_classification.(classifier_name).classes{classind}, ...
                        prob*100));
                    set(t, 'Position', get(t, 'Position') .* [1 -1.2 1],'Color',DEFAULT_PLOT_TEXT)
                end
            end
        end
    end
end

for ri = chanorcomp

    X(ri) = mod(count-1, column)/column * incx-10;
    Y(ri)  = (rows-floor((count-1)/column))/rows * incy - sizewy*1.3;
    count = count +1;

    %fig = findobj('tag', currentfigtag);
    
    checkcom = {@checkbox,int2str(ri),0};
    switch fig_opts{1}
        case 1

            headplot = ax(ri);

            cmap = colormap(headplot);
            children = ax(ri).Children;
            newtopo(ri) = copyobj(headplot,fig,'legacy');

            set(newtopo(ri),'Units','Normalized', 'Position',[X(ri) Y(ri) sizewx sizewy].*s+q,'colormap',cmap);
            set(newtopo(ri),'ButtonDownFcn', checkcom);

            delete(headplot.Parent);
        case 2

           axhndls = to(ri); % get fig parent
            axhndls2 = axhndls{:};
            ERP = axhndls2{1}; % get ERPs
            %parfig = ERP.Parent; % get fig parent
            ERPsum = axhndls2{3}; % get ERP bar

            cmap = colormap(ERP);
            cmap2 = colormap(ERPsum);
            newERP = copyobj(ERP,figs(ri),'legacy');
            newERPsum= copyobj(ERPsum,figs(ri),'legacy');

            set(newERP,'Units','Normalized', 'Position',[X(ri) Y(ri)+sizewy*.3 sizewx sizewy*.7].*s+q,'colormap',cmap);
            set(newERPsum,'Units','Normalized', 'Position',[X(ri) Y(ri)+sizewy*.1 sizewx sizewy*.2].*s+q,'colormap',cmap2);

            set(newERP,'ButtonDownFcn', checkcom);

            delete(ERP.Parent);
            
            if plot_labels == 1
                if ~typecomp && isfield(EEG.etc, 'ic_classification')
                    classifiers = fieldnames(EEG.etc.ic_classification);
                    if ~isempty(classifiers)
                        classifier_name = 'ICLabel';
                        [prob, classind] = max(EEG.etc.ic_classification.(classifier_name).classifications(ri, :));
                        t = title(newERPsum,sprintf('%s : %.1f%%', ...
                            EEG.etc.ic_classification.(classifier_name).classes{classind}, ...
                            prob*100));
                        set(t, 'Position', get(t, 'Position') .* [1 -1.2 1],'Color',DEFAULT_FONT_COLOR);
                    end
                end
            end

        case 3
            axhndls = to(ri); % get fig parent
            axhndls2 = axhndls{:};
            ERP = axhndls2{1}; % get ERPs
            %parfig = ERP.Parent; % get fig parent
            ERPsum = axhndls2{3}; % get ERP bar

            cmap = colormap(ERP);
            cmap2 = colormap(ERPsum);
            newERP = copyobj(ERP,figs(ri),'legacy');
            newERPsum= copyobj(ERPsum,figs(ri),'legacy');
            
            set(newERP,'Units','Normalized', 'Position',[X(ri) Y(ri)+sizewy*.3 sizewx sizewy*.7].*s+q,'colormap',cmap);
            set(newERPsum,'Units','Normalized', 'Position',[X(ri) Y(ri)+sizewy*.1 sizewx sizewy*.2].*s+q,'colormap',cmap2);

            set(newERP,'ButtonDownFcn', checkcom);
            delete(ERP.Parent);

            if plot_labels == 1
                if ~typecomp && isfield(EEG.etc, 'ic_classification')
                    classifiers = fieldnames(EEG.etc.ic_classification);
                    if ~isempty(classifiers)
                        classifier_name = 'ICLabel';
                        [prob, classind] = max(EEG.etc.ic_classification.(classifier_name).classifications(ri, :));
                        t = title(newERPsum,sprintf('%s : %.1f%%', ...
                            EEG.etc.ic_classification.(classifier_name).classes{classind}, ...
                            prob*100));
                        set(t, 'Position', get(t, 'Position') .* [1 -1.2 1],'Color',DEFAULT_FONT_COLOR);
                    end
                end
            end
    end

end

count = 1;
for ri = chanorcomp
%     if exist('fig','var')
%         button = findobj('parent', fig, 'tag', ['comp' num2str(ri)]);
%         if isempty(button)
%             error( 'pop_viewprops2(): figure does not contain the component button');
%         end
%     else
         button = [];
%     end
    
    if isempty( button )
        % compute coordinates
        % -------------------
        X = mod(count-1, column)/column * incx-10;
        Y = (rows-floor((count-1)/column))/rows * incy - sizewy*1.3;
%                 
        %% plot the button
        % ---------------
%         if ~strcmp(get(fig, 'tag'), currentfigtag)
%             figure(findobj('tag', currentfigtag));
%         end
        % alterations by Ugo 2021, original commented
        % button = uicontrol(fig, 'Style', 'pushbutton', 'Units','Normalized', 'Position',...
        %    [X Y+sizewy sizewx/3 sizewy*0.18].*s+q, 'tag', ['comp' num2str(ri)]);
        
        % make the buttons smaller
        
        button = uicontrol(fig, 'Style', 'pushbutton', 'Units','Normalized', 'Position',...
            [X(1,1)  Y(1,1)+sizewy sizewx/3 sizewy*0.18].*s+q, 'tag', ['comp' num2str(ri)]);
        set( button, 'callback', {@pop_prop_extended_adv, EEG, typecomp, ri, NaN, spec_opt, erp_opt, scroll_event, classifier_name} );
    
        %         hr = uicontrol(gfc, 'Style', 'pushbutton', 'backgroundcolor', eval(fastif(status,COLREJ,COLACC)), ...
        % 				'string', fastif(status, 'REJECT', 'ACCEPT'), 'Units','Normalized', 'Position', [40 -10 15 6].*s+q, 'userdata', status, 'tag', 'rejstatus');
        % -------------
        
        % --- get components status to give value to checkboxes
        if isfield(EEG,'reject')
            if isfield(EEG.reject,'gcompreject')
                if ~isempty(EEG.reject.gcompreject)
                    status = EEG.reject.gcompreject(chanorcomp);
                else
                    status = 0;
                end
            else
                status = 0;
            end
        else
            status = 0;
        end

        %% --- plots checkboxes # Added by Ugo Nunes Jun/2021
        checktag  = int2str(ri);
        
        % checkcom = ['pop_viewprops2_checkbox(' int2str(ri) ' )'];
        checkcom  = {@checkbox,int2str(ri),1};

%         checktag  = uicontrol(fig, 'Style', 'checkbox','Units','Normalized','Tag',int2str(ri), 'Value',EEG.reject.gcompreject(ri),'Position',...
%             [X(ri) +sizewx*2/3 Y(ri) +sizewy sizewx/3 sizewy*0.18].*s+q,'Visible','on','Callback',checkcom);  

        check = uicontrol(fig, 'Style', 'checkbox','Units','Normalized','Tag',int2str(ri), 'Value',EEG.reject.gcompreject(ri),'Position',...
            [X+sizewx*2/3 Y+sizewy sizewx/3 sizewy*0.18].*s+q,'Visible','on','Callback',checkcom,'BackgroundColor',BACKCOLOR); 

                        % --- edits to the topoplots
        topotag = strcat('T',checktag);

    end
    if typecomp
        set( button, 'backgroundcolor', COLACC, 'string', EEG.chanlocs(ri).labels);
    else
        set( button, 'backgroundcolor', COLACC, 'string', int2str(ri));
    end
%     if ~rem(ri,30) % plots 30 at a time, still slower tahn just waiting to plot all.
%         drawnow;
%     end
    count = count +1;
end

toc
%% CANCEL button
% -------------
cancel  = uicontrol(fig, 'Style', 'pushbutton', 'backgroundcolor', DEFAULT_OFF_COLOR, 'string', 'Cancel', 'Units','Normalized','Position',[-10 -10 10 6].*s+q, 'callback', 'close(fig);');

% Plot ScrollPlot button
% -------------
commandPlot = ['pop_eegplot_adv(EEG, 2, 2, 1, 1);'];
        
plotComp = uicontrol(fig, 'Style', 'pushbutton', 'backgroundcolor', DEFAULT_ON_COLOR, 'string', 'Plot Component Scroll', 'Units','Normalized','Position',[30 -10 15 6].*s+q, 'callback', commandPlot');

%% SAVE CORRMAP button
% -------------
commandSave = [ 'tmpstatus = get( findobj(''parent'', fig, ''Style'', ''checkbox''), ''value'');'...
        'A = fliplr([tmpstatus{:}]);'...
 		'EEG.reject.gcompreject(' num2str(chanorcomp(1)) ' : ' num2str(chanorcomp(end)) ' ) = A;'...
        'EEG = eegh(com, EEG);'...
        'save_corrmaps(EEG)'];
        
saveComp = uicontrol(fig, 'Style', 'pushbutton', 'backgroundcolor', DEFAULT_ON_COLOR, 'string', 'Save CorrMaps', 'Units','Normalized','Position',[45 -10 15 6].*s+q, 'callback', commandSave');

%% Reject and run N-1 PCA button
% -------------

% commandN1PCA = [ 'tmpstatus = get( findobj(''parent'', fig, ''Style'', ''checkbox''), ''value'');'...
%     'A = fliplr([tmpstatus{:}]);'...
%     'EEG.reject.gcompreject(' num2str(chanorcomp(1)) ' : ' num2str(chanorcomp(end)) ' ) = A;'...
%     'EEG = eegh(com, EEG);'...
%     'close(fig);'...
%     'IC = size(A,2) - sum(A) - 1;'...
%     '[EEG,com] = quick_PCA(EEG,IC)'];
%     
% rjandpca  = uicontrol(fig, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'Reject & N-1 PCA', 'Units','Normalized', 'Position', [65 -10 15 6].*s+q, 'callback', commandN1PCA);

%% Just Reject & Remove button
% --------- 
commandReject = [ 'tmpstatus = get( findobj(''parent'', fig, ''Style'', ''checkbox''), ''value'');'...
        'A = fliplr([tmpstatus{:}]);'...
 		'EEG.reject.gcompreject(' num2str(chanorcomp(1)) ' : ' num2str(chanorcomp(end)) ' ) = A;'...
        '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);'...
        'mybadcomps = find(EEG.reject.gcompreject);'...
        'if ~isempty(mybadcomps);'...
        '[EEG,com] = pop_subcomp(EEG, mybadcomps, 0);'...
        'EEG = eegh(com, EEG);'...
        'end;'...
        'close(fig);'...
        'eeglab redraw;'];
    
 rej  = uicontrol(fig, 'Style', 'pushbutton', 'string', 'Remove Components', 'backgroundcolor', GUIBUTTONCOLOR, 'Units','Normalized', 'Position',[80 -10 15 6].*s+q);
 set( rej, 'callback', commandReject);

%% Just Reject button
% --------- 
  	commandSelect = [ 'tmpstatus = get( findobj(''parent'', fig, ''Style'', ''checkbox''), ''value'');'...
        'A = fliplr([tmpstatus{:}]);'...
 		'EEG.reject.gcompreject(' num2str(chanorcomp(1)) ' : ' num2str(chanorcomp(end)) ' ) = A;'...
        '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);'...
        'EEG = eegh(com, EEG);'...
        'close(fig);'...
        'eeglab redraw;'];

%     okcommand = ['tmpstatus = get( findobj(''parent'', fig, ''tag'', ''rejstatus''), ''value'');'...
%         'tmpstatus = fliplr(transpose(cat(tmpstatus{:,:})))']

% tmpstatus = [];
% okcommand = ['tmpstatus = get( findobj(''parent'', fig, ''tag'', ''rejstatus''), ''value'');']
%     %'EEG.reject.gcompreject(' num2str(chanorcomp) ') = tmpstatus;' ];

ok  = uicontrol(fig, 'Style', 'pushbutton', 'string', 'Add Comps to Rej list', 'backgroundcolor', GUIBUTTONCOLOR, 'Units','Normalized', 'Position',[95 -10 15 6].*s+q);

 if isempty(newcommand) 
    set( ok, 'callback', commandSelect);
else
    set( ok, 'callback', newcommand);
    set( ok, 'backgroundcolor', [1 1 0]);
end
 
%% CLEAR ALL button
% -------------
commandClear = {@selectall,0};
        
clearComp = uicontrol(fig, 'Style', 'pushbutton', 'backgroundcolor', DEFAULT_OFF_COLOR, 'string', 'Clear Values', 'Units','Normalized','Position',[0 -10 10 6].*s+q, 'callback', commandClear');

% SELECT ALL button
% -------------
commandSelAll = {@selectall,1};
        
selectAll = uicontrol(fig, 'Style', 'pushbutton', 'backgroundcolor', DEFAULT_OFF_COLOR, 'string', 'Select All', 'Units','Normalized','Position',[10 -10 10 6].*s+q, 'callback', commandSelAll');

%% com for eegh

com = sprintf('pop_viewprops3_par( %s, %d, %s, %s, %s, %d, ''%s'' )', ...
    inputname(1), typecomp, hlp_tostring(chanorcomp), hlp_tostring(spec_opt), ...
    hlp_tostring(erp_opt), scroll_event, classifier_name);
end

%% The following 2 functions were added by Ugo Bruzadin Nunes for the QuickLab EEGLAB plugin, Summer 2022

% Copyright (C) Ugo Bruzadin Nunes
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

function selectall(src,evt,value)
    
    
    % --- click or unclick the tag
    %clickVal = get(findobj(fig,'Style','checkbox));
    
    set(findobj(fig,'Style','checkbox'),'Value', value);
    
    % --- turn button color red or green
    
    clickVal = abs(value);
    
    % --- get all component buttons
    all_buttons = findobj(fig,'Style','pushbutton');
    % --- 9 is the number of buttons on the end of the page! If I add more buttons
    % IF I AD MORE BUTTONS 9 NEEDS TO CHANGE!
    
    comp_buttons = all_buttons(9:end);
    
    if clickVal == 1
        %set(findobj(fig,'Style','checkbox'),'BackgroundColor',[1 .5 .5])
        set(comp_buttons,'BackgroundColor',[1 .5 .5])
    else
        %set(findobj(fig,'Style','checkbox'),'BackgroundColor',[.75 1 .75])
        set(comp_buttons,'BackgroundColor',[.75 1 .75])
    end

end

function checkbox(src,evt,index,clicked_box)
    if nargin < 3
        clicked_box = 0;
    end
    % --- click or unclick the tag
    clickVal = get(findobj(fig,'Tag',index),'Value');
    if clicked_box == 0
        clickVal = abs(clickVal-1);
    end

    set(findobj(fig,'Tag',index),'Value', clickVal);
    
    % --- turn button color red or green
    
    if clickVal == 1
        %set(findobj(fig,'Style','checkbox'),'BackgroundColor',[1 .5 .5])
        set(findobj(fig,'Tag',strcat('comp',index)),'BackgroundColor',[1 .5 .5])
    else
        %set(findobj(fig,'Style','checkbox'),'BackgroundColor',[.75 1 .75])
        set(findobj(fig,'Tag',strcat('comp',index)),'BackgroundColor',[.75 1 .75])
    end

end


% inputdlg3() - A comprehensive gui automatic builder. This function takes
%               text, type of GUI and default value and builds
%               automatically a simple graphic interface.
%
% Usage:
%   >> [outparam outstruct] = inputdlg3( 'key1', 'val1', 'key2', 'val2', ... );
%
% Inputs:
%   'prompt'     - cell array of text
%   'style'      - cell array of style for each GUI. Default is edit.
%   'default'    - cell array of default values. Default is empty.
%   'tags'       - cell array of tag text. Default is no tags.
%   'tooltip'    - cell array of tooltip texts. Default is no tooltip.
%
% Output:
%   outparam   - list of outputs. The function scans all lines and
%                add up an output for each interactive uicontrol, i.e
%                edit box, radio button, checkbox and listbox.
%   userdat    - 'userdata' value of the figure.
%   strhalt    - the function returns when the 'userdata' field of the
%                button with the tag 'ok' is modified. This returns the
%                new value of this field.
%   outstruct  - returns outputs as a structure (only tagged ui controls
%                are considered). The field name of the structure is
%                the tag of the ui and contain the ui value or string.
%
% Note: the function also adds three buttons at the bottom of each
%       interactive windows: 'CANCEL', 'HELP' (if callback command
%       is provided) and 'OK'.
%
% Example:
%   res = inputdlg3('prompt', { 'What is your name' 'What is your age' } );
%   res = inputdlg3('prompt', { 'Chose a value below' 'Value1|value2|value3' ...
%                   'uncheck the box' }, ...
%                   'style',  { 'text' 'popupmenu' 'checkbox' }, ...
%                   'default',{ 0 2 1 });
%
% Author: Arnaud Delorme, Tim Mullen, Christian Kothe, SCCN, INC, UCSD
%
% See also: supergui(), eeglab()

% Copyright (C) Arnaud Delorme, SCCN, INC, UCSD, 2010, arno@ucsd.edu
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

function [result, userdat, strhalt, resstruct] = inputdlg3( varargin);

if nargin < 2
    help inputdlg3;
    return;
end;

% check input values
% ------------------
[opt addopts] = finputcheck(varargin, { 'prompt'  'cell'  []   {};
    'style'   'cell'  []   {};
    'default' 'cell'  []   {};
    'tag'     'cell'  []   {};
    'tooltip','cell'  []   {}}, 'inputdlg3', 'ignore');
if isempty(opt.prompt),  error('The ''prompt'' parameter must be non empty'); end;
if isempty(opt.style),   opt.style = cell(1,length(opt.prompt)); opt.style(:) = {'edit'}; end;
if isempty(opt.default), opt.default = cell(1,length(opt.prompt)); opt.default(:) = {0}; end;
if isempty(opt.tag),     opt.tag = cell(1,length(opt.prompt)); opt.tag(:) = {''}; end;

% creating GUI list input
% -----------------------
uilist = {};
uigeometry = {};
outputind  = ones(1,length(opt.prompt));
for index = 1:length(opt.prompt)
    if strcmpi(opt.style{index}, 'edit')
        uilist{end+1} = { 'style' 'text' 'string' opt.prompt{index} };
        uilist{end+1} = { 'style' 'edit' 'string' opt.default{index} 'tag' opt.tag{index} 'tooltip' opt.tag{index}};
        uigeometry{index} = [2 1];
    else
        uilist{end+1} = { 'style' opt.style{index} 'string' opt.prompt{index} 'value' opt.default{index} 'tag' opt.tag{index} 'tooltip' opt.tag{index}};
        uigeometry{index} = [1];
    end;
    if strcmpi(opt.style{index}, 'text')
        outputind(index) = 0;
    end;
end;

[tmpresult, userdat, strhalt, resstruct] = inputgui('uilist', uilist,'geometry', uigeometry, addopts{:});
result = cell(1,length(opt.prompt));
result(find(outputind)) = tmpresult;
end


% the following functions are from BCILAB
function str = hlp_tostring(v,stringcutoff,prec)
% Get an human-readable string representation of a data structure.
% String = hlp_tostring(Data,StringCutoff)
%
% The resulting string representations are usually executable, but there are corner cases (e.g.,
% certain anonymous function handles and large data sets), which are not supported. For
% general-purpose serialization, see hlp_serialize/hlp_deserialize.
%
% In:
%   Data : a data structure
%
%   StringCutoff : optional maximum string length for atomic fields (default: 0=off)
%
%   Precision : maximum significant digits (default: 15)
%
% Out:
%   String : string form of the data structure
%
% Notes:
%   hlp_tostring has builtin support for displaying expression data structures.
%
% Examples:
%   % get a string representation of a data structure
%   hlp_tostring({'test',[1 2 3], struct('field','value')})
%
% See also:
%   hlp_serialize
%
%                                Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%                                2010-04-15
%
%                                adapted from serialize.m
%                                (C) 2006 Joger Hansegord (jogerh@ifi.uio.no)

% Copyright (C) Christian Kothe, SCCN, 2010, christian@sccn.ucsd.edu
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU
% General Public License as published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
% even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program; if not,
% write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
% USA

if nargin < 2
    stringcutoff = 0; end
if nargin < 3
    prec = 15; end

str = serializevalue(v);


    function val = serializevalue(v)
        % Main hub for serializing values
        if isnumeric(v) || islogical(v)
            val = serializematrix(v);
        elseif ischar(v)
            val = serializestring(v);
        elseif isa(v,'function_handle')
            val = serializefunction(v);
        elseif is_impure_expression(v)
            val = serializevalue(v.tracking.expression);
        elseif has_canonical_representation(v)
            val = serializeexpression(v);
        elseif is_dataset(v)
            val = serializedataset(v);
        elseif isstruct(v)
            val = serializestruct(v);
        elseif iscell(v)
            val = serializecell(v);
        elseif isobject(v)
            val = serializeobject(v);
        else
            try
                val = serializeobject(v);
            catch
                error('Unhandled type %s', class(v));
            end
        end
    end

    function val = serializestring(v)
        % Serialize a string
        if any(v == '''')
            val = ['''' strrep(v,'''','''''') ''''];
            try
                if ~isequal(eval(val),v)
                    val = ['char(' serializevalue(uint8(v)) ')']; end
            catch
                val = ['char(' serializevalue(uint8(v)) ')'];
            end
        else
            val = ['''' v ''''];
        end
        val = trim_value(val,'''');
    end

    function val = serializematrix(v)
        % Serialize a matrix and apply correct class and reshape if required
        if ndims(v) < 3 %#ok<ISMAT>
            if isa(v, 'double')
                if size(v,1) == 1 && length(v) > 3 && isequal(v,v(1):v(2)-v(1):v(end))
                    % special case: colon sequence
                    if v(2)-v(1) == 1
                        val = ['[' num2str(v(1)) ':' num2str(v(end)) ']'];
                    else
                        val = ['[' num2str(v(1)) ':' num2str(v(2)-v(1)) ':' num2str(v(end)) ']'];
                    end
                elseif size(v,2) == 1 && length(v) > 3 && isequal(v',v(1):v(2)-v(1):v(end))
                    % special case: colon sequence
                    if v(2)-v(1) == 1
                        val = ['[' num2str(v(1)) ':' num2str(v(end)) ']'''];
                    else
                        val = ['[' num2str(v(1)) ':' num2str(v(2)-v(1)) ':' num2str(v(end)) ']'''];
                    end
                else
                    val = mat2str(v,prec);
                end
            else
                val = mat2str(v,prec,'class');
            end
            val = trim_value(val,']');
        else
            if isa(v, 'double')
                val = mat2str(v(:),prec);
            else
                val = mat2str(v(:),prec,'class');
            end
            val = trim_value(val,']');
            val = sprintf('reshape(%s, %s)', val, mat2str(size(v)));
        end
    end

    function val = serializecell(v)
        % Serialize a cell
        if isempty(v)
            val = '{}';
            return
        end
        cellSep = ', ';
        if isvector(v) && size(v,1) > 1
            cellSep = '; ';
        end
        
        % Serialize each value in the cell array, and pad the string with a cell
        % separator.
        vstr = cellfun(@(val) [serializevalue(val) cellSep], v, 'UniformOutput', false);
        vstr{end} = vstr{end}(1:end-2);
        
        % Concatenate the elements and add a reshape if requied
        val = [ '{' vstr{:} '}'];
        if ~isvector(v)
            val = ['reshape('  val sprintf(', %s)', mat2str(size(v)))];
        end
    end

    function val = serializeexpression(v)
        % Serialize an expression
        if numel(v) > 1
            val = ['['];
            for k = 1:numel(v)
                val = [val serializevalue(v(k)), ', ']; end
            val = [val(1:end-2) ']'];
        else
            if numel(v.parts) > 0
                val = [char(v.head) '('];
                for fieldNo = 1:numel(v.parts)
                    val = [val serializevalue(v.parts{fieldNo}), ', ']; end
                val = [val(1:end-2) ')'];
            else
                val = char(v.head);
            end
        end
    end

    function val = serializedataset(v) %#ok<INUSD>
        % Serialize a data set
        val = '<EEGLAB data set>';
    end

    function val = serializestruct(v)
        % Serialize a struct by converting the field values using struct2cell
        fieldNames   = fieldnames(v);
        fieldValues  = struct2cell(v);
        if ndims(fieldValues) > 6
            error('Structures with more than six dimensions are not supported');
        end
        val = 'struct(';
        for fieldNo = 1:numel(fieldNames)
            val = [val serializevalue( fieldNames{fieldNo}) ', '];
            val = [val serializevalue( permute(fieldValues(fieldNo, :,:,:,:,:,:), [2:ndims(fieldValues) 1]) ) ];
            val = [val ', '];
        end
        if numel(fieldNames)==0
            val = [val ')'];
        else
            val = [val(1:end-2) ')'];
        end
        if ~isvector(v)
            val = sprintf('reshape(%s, %s)', val, mat2str(size(v)));
        end
    end

    function val = serializeobject(v)
        % Serialize an object by converting to struct and add a call to the copy constructor
        val = sprintf('%s(%s)', class(v), serializevalue(struct(v)));
    end


    function val = serializefunction(v)
        % Serialize a function handle
        try
            val = ['@' char(get_function_symbol(v))];
        catch
            val = char(v);
        end
    end

    function v = trim_value(v,appendix)
        if nargin < 2
            appendix = ''; end
        % Trim a serialized value to a certain length
        if stringcutoff && length(v) > stringcutoff
            v = [v(1:stringcutoff) '...' appendix]; end
    end
end

function result___ = get_function_symbol(expression___)
% internal: some function_handle expressions have a function symbol (an @name expression), and this function obtains it
% note: we are using funny names here to bypass potential name conflicts within the eval() clause further below
if ~isa(expression___,'function_handle')
    error('the expression has no associated function symbol.'); end

string___ = char(expression___);
if string___(1) == '@'
    % we are dealing with a lambda function
    if is_symbolic_lambda(expression___)
        result___ = eval(string___(27:end-21));
    else
        error('cannot derive a function symbol from a non-symbolic lambda function.');
    end
else
    % we are dealing with a regular function handle
    result___ = expression___;
end
end

function res = is_symbolic_lambda(x)
% internal: a symbolic lambda function is one which generates expressions when invoked with arguments (this is what exp_symbol generates)
res = isa(x,'function_handle') && ~isempty(regexp(char(x),'@\(varargin\)struct\(''head'',\{.*\},''parts'',\{varargin\}\)','once'));
end

function res = is_impure_expression(x)
% an impure expression is a MATLAB structure with a .tracking.expression field
res = isfield(x,'tracking') && isfield(x.tracking,'expression');
end

function res = is_dataset(x)
% Determine whether some object is a data set.
res = all(isfield(x,{'data','srate'}));
end

function res = has_canonical_representation(x)
% determine whether an expression is represented as a struct with the fields 'head' and 'parts'.
res = all(isfield(x,{'head','parts'}));
end