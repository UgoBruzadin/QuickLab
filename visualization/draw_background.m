% Draw background
% ---------------------------------
function draw_background(varargin)
QuickLabDefs;

if nargin >= 3
    fig = varargin{3};
else
    fig = findobj('tag','eegplot_adv');
end

if nargin >= 4
    g = varargin{4};
else
    g = get(fig,'UserData');  % Data (Note: this could also be global);
end
if ~isfield(g,'trialstag')
    return;
end

ax0 = findobj(fig,'tag','backeeg','parent',fig); % axes handle
ax1 = findobj('tag','eegaxis','parent',fig); % axes handle

% compare versions once, because it slows down drawing
verLessThan_matlab_9 = ismatlab && verLessThan('matlab','9.0.0');

% Plot data and update axes
if verLessThan_matlab_9
    axes(ax0); % changing axes very slows down drawing
end
cla(ax0);
hold(ax0,'on');
% plot rejected windows
if g.trialstag ~= -1
    multiplier = g.trialstag;
else
    multiplier = g.srate;
end

% draw rejection windows
% ----------------------

lowlim = round(g.time*multiplier+1);

highlim = round(min((g.time+g.winlength)*multiplier+1, g.frames));

%displaymenu = findobj('tag','displaymenu','parent',gcf);
if ~isempty(g.winrej) && g.winstatus

        event2plot1 = find ( g.winrej(:,1) >= lowlim & g.winrej(:,1) <= highlim ); % start events
        event2plot2 = find ( g.winrej(:,2) >= lowlim & g.winrej(:,2) <= highlim ); % end events
        event2plot3 = find ( g.winrej(:,1) <  lowlim & g.winrej(:,2) >  highlim ); % in between events
        event2plot  = union_bc(union(event2plot1, event2plot2), event2plot3);
        total_winrej = g.winrej(event2plot,:);

nowinrej = [];
lowlim2 = lowlim;
highlim2 = highlim;

% COLORS2022
%for tpmi = 1:(g.time+g.winlength)
    for tpmi = event2plot(:)'
        %if tpmi == event2plot
        if size(g.winrej,2) > 2
            tmpcols  = g.winrej(tpmi,3:5);
        else
            tmpcols  = g.wincolor;
        end
        winrej=[g.winrej(tpmi,1)-lowlim g.winrej(tpmi,2)-lowlim ...
            g.winrej(tpmi,2)-lowlim g.winrej(tpmi,1)-lowlim];

        patch_params={winrej, [0 0 1 1], tmpcols,'EdgeColor', tmpcols};

        if verLessThan_matlab_9
            patch(patch_params{:});
        else
            patch(ax0, patch_params{:});
        end
    end
    count = 0;
    if size(event2plot,1) > 0
        % 3 ifs: for spaces before, after, and in-between events
        %BEFORE
        if min(total_winrej(:,1)) > lowlim
            nowinrej = [ 0 min(total_winrej(:,1))-lowlim ...
                min(total_winrej(:,1))-lowlim 0];
            patch_params = {nowinrej, [0 0 1 1], DEFAULT_PLOT_BACKGROUND, 'EdgeColor',DEFAULT_PLOT_BACKGROUND};
            if verLessThan_matlab_9
                patch(patch_params{:});
            else
                patch(ax0, patch_params{:});
            end
            count = count + 1;
        end
        %AFTER
        if max(total_winrej(:,2)) < highlim
            nowinrej = unique(nowinrej,'rows');
            nowinrej = sortrows(nowinrej,'ascend');
            nowinrej = [ max(total_winrej(:,2))-lowlim highlim-lowlim...
                highlim-lowlim max(total_winrej(:,2))-lowlim];
            patch_params={nowinrej, [0 0 1 1], DEFAULT_PLOT_BACKGROUND, 'EdgeColor',DEFAULT_PLOT_BACKGROUND};
            if verLessThan_matlab_9
                patch(patch_params{:});
            else
                patch(ax0, patch_params{:});
            end
            count = count + 1;
        end
        if size(event2plot,1) > 1
            for i = 1:size(event2plot,1)-1
                if max(total_winrej(:,2))-lowlim < highlim
                    %reorganize total_winrej in order
                    total_winrej = unique(total_winrej,'rows');
                    total_winrej = sortrows(total_winrej,'ascend');
                    %nowinrej = merge_trials(nowinrej);
                    nowinrej = [ total_winrej(i,2)-lowlim total_winrej((i+1),1)-lowlim...
                        total_winrej((i+1),1)-lowlim total_winrej((i),2)-lowlim];
                    patch_params={nowinrej, [0 0 1 1], DEFAULT_PLOT_BACKGROUND, 'EdgeColor',DEFAULT_PLOT_BACKGROUND};
                    if verLessThan_matlab_9
                        patch(patch_params{:});
                    else
                        patch(ax0, patch_params{:});
                    end
                end
            end
            count = count + 1;
        end
        % I added this count variable, to be sure that all plot areas are
        % painted even if there's no area currently selected.
        if count == 0
            nowinrej = [0 highlim ...
                highlim 0];
            patch_params={nowinrej, [0 0 1 1], DEFAULT_PLOT_BACKGROUND, 'EdgeColor',DEFAULT_PLOT_BACKGROUND};
            if verLessThan_matlab_9
                patch(patch_params{:});
            else
                patch(ax0, patch_params{:});
            end
        end
    end
else % paints everything
        nowinrej = [0 highlim ...
        highlim 0];
        patch_params={nowinrej, [0 0 1 1], DEFAULT_PLOT_BACKGROUND, 'EdgeColor',DEFAULT_PLOT_BACKGROUND};
        if verLessThan_matlab_9
            patch(patch_params{:});
        else
            patch(ax0, patch_params{:});
        end
end

% draw events if any
% ------------------
if strcmpi(g.plotevent, 'on')
    % JavierLC ###############################
    MAXEVENTSTRING = g.maxeventstring;
    if MAXEVENTSTRING<0
        MAXEVENTSTRING = 0;
    elseif MAXEVENTSTRING>100
        MAXEVENTSTRING=100;
    end
    % JavierLC ###############################
    %AXES_POSITION = [0.05 0.03 0.865 1-(MAXEVENTSTRING-4)/100];
    % FIXED BUG WHERE WINDOW WOULD INCREASE IN SIZE
    AXES_POSITION = get(findobj('tag','eegaxis'),'Position');

else % JavierLC
    %AXES_POSITION = [0.05 0.03 0.865 0.94];
    % FIXED BUG WHERE WINDOW WOULD INCREASE IN SIZE
    AXES_POSITION = get(findobj('tag','eegaxis'),'Position');
end

if ~isempty(g.events)
      if ischar(g.events(1).type)
          eventlist={g.events.type};
          evnt_groups=g.eventtypes;
      else
          eventlist=arrayfun(@(x) num2str(g.events(x).type), 1:length(g.events),'UniformOutput',false);
          evnt_groups=arrayfun(@(x) num2str(g.eventtypes(x)), 1:length(g.eventtypes),'UniformOutput',false);
      end
else
    eventlist={};
end
if strcmpi(g.plotevent, 'on') || ismember('boundary',eventlist)
    % find event to plot
    % ------------------
    event2plot    = find ( g.eventlatencies >=lowlim & g.eventlatencies <= highlim );
    if ~isempty(g.eventlatencyend)
        event2plot2 = find ( g.eventlatencyend >= lowlim & g.eventlatencyend <= highlim );
        event2plot3 = find ( g.eventlatencies  <  lowlim & g.eventlatencyend >  highlim );
        event2plot  = union_bc(union(event2plot, event2plot2), event2plot3);
    end
    [event2plot_ut,~,event2plot_uti]=unique_bc(eventlist(event2plot));
    if ~strcmpi(g.plotevent, 'on')
        event2plot=event2plot(find(ismember(eventlist(event2plot),{'boundary'})));
        event2plot_ut=eventlist(event2plot);
        event2plot_uti=ones(1,length(event2plot));
    end
    for evnt_group_idx_tmp=1:length(event2plot_ut)
        %Just repeat for the first one
        if evnt_group_idx_tmp == 1
            EVENTFONT = ' \fontsize{10} ';
            ylims=ylim(ax0);
        end
        evnt_group=event2plot_ut{evnt_group_idx_tmp};
        evnt_group_idx=find(ismember(evnt_groups,evnt_group));
        evnt_group_color = g.eventtypecolors{evnt_group_idx};
        event2plot_activ = event2plot(find(event2plot_uti==evnt_group_idx_tmp));

        % draw latency line
        % -----------------
        tmplat = g.eventlatencies(event2plot_activ)-lowlim-1; % [lat1 lat2]
        plot_x = reshape([ tmplat; tmplat; NaN(1,length(tmplat))], [1 3*length(tmplat)]); % [lat1 lat1 NaN lat2 lat2 NaN]
        plot_y = repmat([ylims NaN],1,length(tmplat));
        plot(ax0, plot_x, plot_y, ...
            'color', evnt_group_color,...
            'linestyle', g.eventtypestyle{evnt_group_idx}, ...
            'linewidth', g.eventtypewidths(evnt_group_idx));

        if ~strcmpi(g.plotevent, 'on')
            break;
        end
        % schtefan: add Event types text above event latency line
        % -------------------------------------------------------
        evntxt = strrep(evnt_group,'_','-');
        if length(evntxt)>MAXEVENTSTRING
            evntxt = [ evntxt(1:MAXEVENTSTRING-1) '...' ]; % truncate
        end
        for index = 1:length(event2plot_activ)
            tmplat1=tmplat(index);
            %try
            % This if is a QoL to make events close together more visible. Ugo 2023
            % odds vs evens
            if mod(index,2) || length(evntxt) > 10
                lift = -0.005;
                rotation = 30;
            else
                lift = 0.005;
                rotation = 45;
            end

                text_prop={tmplat1, ylims(2)+lift, [EVENTFONT evntxt], ...
                    'color', evnt_group_color, ...
                    'horizontalalignment', 'left',...
                    'rotation',rotation}; % CHANGED ROTATION from 90 to variable; UGO 2023
                %'TooltipString'

                if verLessThan_matlab_9
                    text(text_prop{:});
                else
                    text(ax0, text_prop{:});
                end
            %catch
            %end

            % draw duration is not 0
            % ----------------------
            if g.ploteventdur && ~isempty(g.eventlatencyend) ...
                    && g.eventtypewidths(evnt_group_idx) ~= 2.5 % do not plot length of boundary events
                tmplatend = g.eventlatencyend(event2plot_activ(index))-lowlim-1;
                if tmplatend ~= 0
                    tmplim = ylims;
                    patch_params = {[ tmplat1 tmplatend tmplatend tmplat1 ], ...
                        [ tmplim(1) tmplim(1) tmplim(2) tmplim(2) ], ...
                        evnt_group_color, ...  % this argument is color
                        'EdgeColor', 'none' };
                    if verLessThan_matlab_9
                        patch(patch_params{:});
                    else
                        patch(ax0, patch_params{:});
                    end
                end
            end
        end
    end
end

if g.trialstag(1) ~= -1

    % plot trial limits
    % -----------------
    tmptag = [lowlim:highlim];
    tmpind = find(mod(tmptag-1, g.trialstag) == 0);
    for index = tmpind
        plot(ax0, [tmptag(index)-lowlim-1 tmptag(index)-lowlim-1], [0 1], DEFAULT_TRIAL_DIVISION); % #COLORS2022
    end
    alltag = tmptag(tmpind);

    % compute Xticks
    % --------------
    tagnum = (alltag-1)/g.trialstag+1; % modified, added FLOOR to make sure epoched # displayed was correct. UGO
    set(ax0,'XTickLabel', tagnum,'YTickLabel', [],...
        'Xlim',[0 g.winlength*multiplier],...
        'XTick',alltag-lowlim+g.trialstag/2, 'YTick',[], 'tag','backeeg');

    tagpos  = [];
    if ~isempty(alltag)
        alltag = [alltag(1)-g.trialstag alltag alltag(end)+g.trialstag]; % add border trial limits
    else
        alltag = [ floor(lowlim/g.trialstag)*g.trialstag ceil(highlim/g.trialstag)*g.trialstag ]+1;
    end

    nbdiv = 20/g.winlength; % approximative number of divisions
    divpossible = [ 100000./[1 2 4 5] 10000./[1 2 4 5] 1000./[1 2 4 5] 100./[1 2 4 5 10 20]]; % possible increments
    [~, indexdiv] = min(abs(nbdiv*divpossible-(g.limits(2)-g.limits(1)))); % closest possible increment
    incrementpoint = divpossible(indexdiv)/1000*g.srate;

    % tag zero below is an offset used to be sure that 0 is included
    % in the absicia of the data epochs
    if g.limits(2) < 0, tagzerooffset  = (g.limits(2)-g.limits(1))/1000*g.srate+1;
    else                tagzerooffset  = -g.limits(1)/1000*g.srate;
    end
    if tagzerooffset < 0, tagzerooffset = 0; end

    for i=1:length(alltag)-1
        if ~isempty(tagpos) && tagpos(end)-alltag(i)<2*incrementpoint/3
            tagpos  = tagpos(1:end-1);
        end
        if ~isempty(g.freqlimits)
            tagpos  = [ tagpos linspace(alltag(i),alltag(i+1)-1, nbdiv) ];
        else
            if tagzerooffset ~= 0
                tmptagpos = [alltag(i)+tagzerooffset:-incrementpoint:alltag(i)];
            else
                tmptagpos = [];
            end
            tagpos  = [ tagpos [tmptagpos(end:-1:2) alltag(i)+tagzerooffset:incrementpoint:(alltag(i+1)-1)]];
        end
    end

    % find corresponding epochs
    % -------------------------
    if ~g.isfreq
        tmplimit = g.limits;
        tpmorder = 1E-3;
    else
        tmplimit = g.freqlimits;
        tpmorder = 1;
    end
    tagtext = eeg_point2lat(tagpos, floor((tagpos)/g.trialstag)+1, g.srate, tmplimit,tpmorder);
    set(ax1,'XTickLabel', tagtext,'XTick', tagpos-lowlim);
%if g.trialstag(1) == -1
    else
    DEFAULT_GRID_SPACING = 10^ceil(log10(g.winlength)-1);
    if g.winlength / DEFAULT_GRID_SPACING < 2
        DEFAULT_GRID_SPACING = DEFAULT_GRID_SPACING / 2;
    end
    set(ax0,'XTickLabel', [],'YTickLabel', [],...
        'Xlim', [0 g.winlength*multiplier],...
        'XTick',[], 'YTick',[], ...
        'Position', AXES_POSITION);
    set(ax1,'Position', AXES_POSITION);
    if g.isfreq
        set(ax1,'XTick', [1:multiplier*DEFAULT_GRID_SPACING:g.winlength*multiplier+1]);
        set(ax1,'XTickLabel', num2str((g.freqs(1):DEFAULT_GRID_SPACING:g.freqs(end))'));
    else
        XTickStartSec = DEFAULT_GRID_SPACING*ceil(g.time/DEFAULT_GRID_SPACING);
        XTickStart = multiplier*(XTickStartSec-g.time) + 1;
        set(ax1,'XTick', [XTickStart:(multiplier*DEFAULT_GRID_SPACING):(g.winlength*multiplier+1)]);
        set(ax1,'XTickLabel', num2str((XTickStartSec:DEFAULT_GRID_SPACING:g.time+g.winlength)'));
    end
end
if verLessThan_matlab_9
    axes(ax1); % changing axes very slows down drawing
end
