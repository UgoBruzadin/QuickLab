function change_scale(varargin)

    if nargin >= 3
        fig = varargin{3};
    else
        fig = gcf;
    end
%     if strcmp(get(fig,'tag'),'dialog')
%         fig = get(fig,'UserData');
%     end

    if nargin >= 4
        p1 = varargin{4};
        if ~isnumeric(p1)
            p1 = 0;
        end
    else
        p1 = 0;
    end

    if nargin >= 5
        ax1 = varargin{5};
    else
        ax1 = findobj(fig,'tag','eegaxis'); % axes handle
    end

    g = get(fig,'UserData');
    %g = THINKING(g,1);

    if ~isfield(g,'trialstag')
        return;
    end
    data = get(ax1, 'userdata');
    ESpacing = findobj(fig,'tag','ESpacing');   % ui handle (searches all descendants)
    EPosition = findobj(fig,'tag','EPosition'); % ui handle

    % removing letters from text.
    ESpacing2 = ESpacing.String;
    EPosition2 = EPosition.String;
    % Exclude characters, which are accepted by sscanf:
    ESpacing2(ismember(ESpacing2, '-+eEgG')) = ' ';
    EPosition2(ismember(EPosition2, '-+eEgG')) = ' ';
    % Convert to one number and back to a string:
    ESpacing3 = sprintf('%g', sscanf(ESpacing2, '%g', 1));
    set(ESpacing, 'String', ESpacing3);
    EPosition3 = sprintf('%g', sscanf(EPosition2, '%g', 1));
    set(EPosition, 'String', EPosition3);

    if g.trialstag(1) == -1
        g.time = str2num(get(EPosition,'string'));
    else
        g.time = str2num(get(EPosition,'string'))-1;
    end
    g.spacing = str2num(get(ESpacing,'string'));
    if isempty(g.spacing)
        g.spacing=0;
    end
    switch p1
        case 1
            g.spacing = g.spacing * 1.25;
        case 2
            g.spacing = max(0.005, g.spacing * 0.8);
        case 3
            g.spacing = 0;
        case 4 % keep current spacing (refresh)
    end
    if ismember(p1, [1 2])
        spacing_deka=10^(floor(log10(g.spacing))-1);
        g.spacing = spacing_deka*round(g.spacing/spacing_deka);
    end
    if round(g.spacing*100) == 0
        if g.spacing == 0
            g=optim_scale(data,g);
        else
            maxindex = min(10000, g.frames);
            g.spacing = 0.01*max(max(data(:,1:maxindex),[],2),[],1)-min(min(data(:,1:maxindex),[],2),[],1);  % Set g.spacingto max/min data
        end
    end

    %g.datastd = [];

    %g = THINKING(g,0);
    % update edit box
    % ---------------
    set(ESpacing,'string',num2str(g.spacing,4))
    %set(fig, 'userdata', g);
    draw_data([],[],fig,0,[],g);
    set(ax1,...
        'YTick', [0:g.spacing:g.chans*g.spacing],...
        'Ylim',  [g.elecoffset*g.spacing (g.elecoffset+g.dispchans+1)*g.spacing] ); % 'YLim',[0 (g.chans+1)*g.spacing]

    % update scaling eye (I) if it exists
    % -----------------------------------
    eyeaxes = findobj(fig,'tag','eyeaxes');
    if ~isempty(eyeaxes)
      eyetext = findobj('type','text','parent',eyeaxes,'tag','thescalenum');
      set(eyetext,'string',num2str(g.spacing,4))
    end
    %g = THINKING(g,0);
