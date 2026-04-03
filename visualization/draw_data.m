% Redraw EEG and change position
% ---------------------------------
function draw_data(varargin)


    try
        QuickLabDefs;
    catch
        DEFAULT_PLOT_LINES = [0 0 0.2]; %darkblue
        DEFAULT_PLOT_SELECTED = [1 0 0]; %red
    end
    if nargin >= 3
        figh = varargin{3};
        %figure(figh);
    else
        figh = findobj('tag','eegplot_adv');
    end

    if strcmp(get(figh,'tag'),'dialog')
        figh = get(figh,'UserData');
    end

    if nargin >= 4
        p1 = varargin{4};
        if ~isnumeric(p1)
            p1 = 0;
        end
    else
        p1 = 0;
    end

    if nargin >= 5 % Children Object
        p2 = varargin{5};
    else
        p2 = [];
    end

    g = [];
    if nargin >= 6
        g = varargin{6};
    end
    if isempty(g)
        g = get(figh,'UserData');
    end
    if ~isfield(g,'trialstag')
        return;
    end

    ax1 = [];
    if nargin >= 7
        ax1 = varargin{7};
    end
    if isempty(ax1)
        ax1 = findobj('tag','eegaxis','parent',figh); % axes handle
    end

    if nargin >= 8
        custom_command = varargin{8};
    else
        custom_command = '';
    end

    % compare versions once, because it slows down drawing
    verLessThan_matlab_9 = ismatlab && verLessThan('matlab','9.0.0');

    %axes(ax1);
    data = get(ax1,'UserData');
    ESpacing  = findobj('tag','ESpacing', 'parent',figh); % ui handle
    EPosition = findobj('tag','EPosition','parent',figh); % ui handle
    if ~isempty(EPosition) && ~isempty(ESpacing)
        EPosition_new = str2num(get(EPosition,'string'));
        if ~isempty(EPosition_new)
            g.time = EPosition_new;
        end
        if g.trialstag(1) ~= -1
            g.time = g.time - 1;
        end
        g.spacing = str2num(get(ESpacing,'string'));
    end

    if ~isempty(custom_command)
        try eval(custom_command); catch, end
    end

    switch p1
        case 1
            g.time = g.time-g.winlength;     % << subtract one window length
        case 2
            g.time = g.time-g.winlength/5;   % < subtract one second
        case 3
            g.time = g.time+g.winlength/5;   % > add one second
        case 4
            g.time = g.time+g.winlength;     % >> add one window length
        case 5
            % switched bewteen epoched and unepoched
            tmpEEG = g.EEG;
            epoch = abs(tmpEEG.xmin - tmpEEG.xmax);
            if g.trialstag(1) ~= -1
                g.time = (g.time + 1) / epoch;
            else
                g.time = (g.time - 1) * epoch;
            end
        case 6 % refresh (no time change)
        case 7
            tmpEEG = g.EEG;
            epoch = abs(tmpEEG.xmin - tmpEEG.xmax);
        if g.trialstag(1) ~= -1
            g.time = epoch*tmpEEG.trials;
        else
            g.time = tmpEEG.xmax;
        end
        case 8
            g.time = 0;
        case 9
            data = g.data;
        case 10
            g.time = p2;
        case {11, 12} % go to previous (11) or next (12) winrej
            if ~isempty(g.winrej)
                % Convert current time to bins/samples
                if g.trialstag(1) ~= -1
                    currentBin = floor(g.time) * g.EEG.pnts + 1;
                else
                    currentBin = round(g.time * g.EEG.srate);
                end

                % Find closest winrej in the requested direction
                starts = g.winrej(:, 1);
                if p1 == 11 % previous
                    candidates = find(starts < currentBin);
                    if ~isempty(candidates)
                        [~, idx] = max(starts(candidates));
                        targetBin = starts(candidates(idx));
                    else
                        targetBin = [];
                    end
                else % next
                    candidates = find(starts > currentBin);
                    if ~isempty(candidates)
                        [~, idx] = min(starts(candidates));
                        targetBin = starts(candidates(idx));
                    else
                        targetBin = [];
                    end
                end

                % Navigate to the found winrej
                if ~isempty(targetBin)
                    if g.trialstag(1) ~= -1
                        g.time = floor(targetBin / g.EEG.pnts);
                    else
                        g.time = targetBin / g.EEG.srate;
                        g.time = min(g.time, g.frames/g.EEG.srate - g.winlength);
                    end
                end
            end
    end

    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end

    % Update edit box
    % ---------------
    g.time = max(0,min(g.time,ceil((g.frames-1)/multiplier)-g.winlength));
    if g.trialstag(1) == -1
        set(EPosition,'string',num2str(g.time));
    else
        set(EPosition,'string',num2str(g.time+1));
    end
    set(figh, 'userdata', g);

    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));

    switch lower(g.submean) % subtract the mean ?
        case 'on'
            if ~isempty(g.data2)
                meandata = nan_mean(g.data2(:,lowlim:highlim)');
            else
                meandata = nan_mean(data(:,lowlim:highlim)');
            end
        otherwise, meandata = zeros(1,g.chans);
    end

    if strcmpi(g.plotdata2, 'off')
        cla(ax1);
    end

    oldspacing = g.spacing;
    if g.envelope
        g.spacing = 0;
    end

    % plot data
    % ---------
    hold(ax1,'on');

    chans_list_bad = [];
    chans_list_good = [];
    if isfield(g, 'eloc_file') && isstruct(g.eloc_file)
        if ~isfield(g.eloc_file, 'badchan')
            for ii=1:length(g.eloc_file)
                g.eloc_file(ii).badchan = 0;
            end
        end
        chans_list_bad = g.chans - find([g.eloc_file.badchan]) + 1;
        chans_list_good = setdiff(1:g.chans, chans_list_bad);
    end

    % plot channels whose "badchan" field is set to 1.
    % Bad channels are plotted first so that they appear behind the good
    % channels in the eegplot_adv figure window.

    % Plot bad channels in red, good channels in blue
    if ~isempty(chans_list_bad)
        tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,chans_list_bad,lowlim,highlim);
        plot(ax1,tmp_plot_data_y', 'color', DEFAULT_PLOT_SELECTED, 'clipping','on');
    end

    % Plot good channels
    if ~isempty(chans_list_good)
        chans_list_good_N=length(chans_list_good);
        tmp_plot_data_x_N=length(lowlim:highlim);
        plot_at_once=2; % mode: 0, 1 or 2
        if strcmpi(g.plotdata2, 'on')
            tmpcolor = DEFAULT_PLOT_SELECTED;
        elseif length(g.color) == 1
            tmpcolor = DEFAULT_PLOT_LINES;
            %tmpcolor = [1 0 0];
        else
            plot_at_once=0; % in this case only mode "0" allowed
        end
        switch plot_at_once
            case 1
                tmp_plot_data_x=1:tmp_plot_data_x_N;
                tmp_plot_data_y=nan(length(chans_list_good),tmp_plot_data_x_N);
            case 2
                tmp_plot_data_x= repmat([1:tmp_plot_data_x_N NaN],1,chans_list_good_N);
                tmp_plot_data_y= nan(1, chans_list_good_N*(tmp_plot_data_x_N+1));
        end
        for ii = 1:chans_list_good_N
            i=chans_list_good(ii);
            tmp_plot_data_y_i=data(g.chans-i+1,lowlim:highlim) ...
                - meandata(g.chans-i+1)+i*g.spacing ...
                + (g.dispchans+1)*(oldspacing-g.spacing)/2 ...
                + g.elecoffset*(oldspacing-g.spacing);
            switch plot_at_once
                case 0
                    tmpcolor = g.color{mod(g.chans-i,length(g.color))+1};
                    plot(tmp_plot_data_y_i, 'color', tmpcolor, 'clipping','on');
                case 1
                    tmp_plot_data_y(ii,tmp_plot_data_x)=tmp_plot_data_y_i;
                case 2
                    tmp_plot_data_y(1,(ii-1)*(tmp_plot_data_x_N+1)+[1:tmp_plot_data_x_N])=tmp_plot_data_y_i;
            end
        end
        switch plot_at_once
            case 1
                plot(ax1,tmp_plot_data_y', 'color', tmpcolor, 'clipping','on');
                %plot(ax1,tmp_plot_data_x,tmp_plot_data_y, 'color', tmpcolor, 'clipping','on');
            case 2
                plot(ax1,tmp_plot_data_x,tmp_plot_data_y, 'color', tmpcolor, 'clipping','on');
        end
    end

    % draw selected channels
    % ------------------------
    if ~isempty(g.winrej) && size(g.winrej,2) > 2
        winrej = g.winrej( (g.winrej(:,1) >= lowlim) & (g.winrej(:,1) <= highlim) | ...
            (g.winrej(:,2) >= lowlim & g.winrej(:,2) <= highlim) | ...
            (g.winrej(:,1) <= lowlim & g.winrej(:,2) >= highlim),:);

        for tpmi = 1:size(winrej,1) % scan rows

            abscmin = max(1,round(winrej(tpmi,1)-lowlim));
            abscmax = round(winrej(tpmi,2)-lowlim);
            chanrej = find(winrej(tpmi,6:end));
            chanrej = abs(chanrej - g.chans - 1);
            for i = chanrej
                plot(ax1,abscmin+1:abscmax+1,data(g.chans-i+1,abscmin+lowlim:abscmax+lowlim) ...
                    -meandata(g.chans-i+1)+i*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing), 'color',DEFAULT_PLOT_SELECTED,'clipping','on');
            end
        end
    end
    g.spacing = oldspacing;
    set(ax1, 'Xlim', [1 g.winlength*multiplier+1]);

    % ordinates: even if all elec are plotted, some may be hidden
    set(ax1, 'ylim',[g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] );

    if g.children ~= 0
        draw_data([],[],g.children,p1,p2);
        figure(figh);
    end

     % draw second data if necessary
     if ~isempty(g.data2)
         tmpdata = data;
         set(ax1, 'userdata', g.data2);
         g.data2 = [];
         g.plotdata2 = 'on';
         set(figh, 'userdata', g);
         draw_data([],[],figh,0,[],g,ax1);
         g.plotdata2 = 'off';
         g.data2 = get(ax1, 'userdata');
         set(ax1, 'userdata', tmpdata);
         set(figh, 'userdata', g);
     else
         draw_background([],[],figh,g);
     end
