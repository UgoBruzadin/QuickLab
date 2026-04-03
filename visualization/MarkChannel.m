function MarkChannel(~,~,fig,channel_index,tmppos)

QuickLabDefs;
if nargin < 4
    tmppos = 0;
end

g=get(fig,'UserData');

% COPIED THIS PORTION FROM MOUSEMOVEMENT FUNCTION -- UGO MODS
if g.trialstag ~= -1 % time in second or in trials
    multiplier = g.trialstag;
else
    multiplier = g.srate;
end

% gets low and high limits of the page
lowlim = round(g.time*multiplier+1);
highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
% makes sure click is in valid position
if g.trialstag ~= -1
    point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
else
    point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
end
% if valid, gets temporary TIME value within the displayed eeg window
if point_is_valid
    %if g.trialstag ~= -1
    %    tmpval = mod(tmppos(1)+lowlim-1,g.trialstag)/g.trialstag*(g.limits(2)-g.limits(1)) + g.limits(1);
    %    if g.isfreq, tmpval = tmpval/1000 + g.freqs(1); end
    %else
        tmpval = (tmppos(1)+lowlim-1);%/g.srate; %COMMENTED THIS OUT
        if g.isfreq, tmpval = tmpval+g.freqs(1); end
    %end
    %set(hh, 'string', num2str(tmpval)); % put g.time in the box
else
    %set(hh, 'string', ' ');
    tmpval = 0;
end

%HOW TO GET THE WINREJ TO GET THE CHANNELS IN IT, IN AND OUT

if isempty(g.command)
    clear global in_callback; return;
end

if isfield(g, 'eloc_file')
    %make sure to recreate the badchannel option in the channel struct
    if ~isfield(g.eloc_file, 'badchan')
        for ii=1:length(g.eloc_file)
            g.eloc_file(ii).badchan = 0;
        end
    end

    % UGO MODS

    if channel_index ~= 0
    % badchan is a dummy variable which makes sure only channels selected
    % for complete rejection and added to g.eloc_file.badchan
    % new FAST code
    % --- Creates empty variables
    rejection_indexes = [];
    winrej = [];
    tmpcolor = DEFAULT_PLOT_LINES;

    % if winrej for this channel is empty

    if ~isempty(g.winrej)
        % Checks for click within a rejection window

        rejection_indexes = tmpval >= g.winrej(:,1) & tmpval <= g.winrej(:,2); % get epoch index(es), if any

        % CHECKS FOR MOUSE POSITION WITHIN A REJECTION STRETCH
        if any(rejection_indexes)
            epoch_id = find(rejection_indexes); %get selected epoch number
            winrej = g.winrej(epoch_id,:); % get winrej
            winrej(channel_index+5) = 1 - winrej(channel_index+5); % changes the number from 1 to 0 or vice-versa
            g.winrej(epoch_id,:) = winrej; % alters the original winrej
            if winrej(channel_index+5) == 1
                tmpcolor = DEFAULT_PLOT_SELECTED; % makes color red if channel is rejected
            end
        end
    end

    if ~any(rejection_indexes)
        % no rejection was previously there, so rejects the epoch
        g.eloc_file(channel_index).badchan = 1-g.eloc_file(channel_index).badchan; % changes the number from 1 to 0 or vice-versa

        if g.EEG.plotchannels == 0
            g.EEG.reject.gcompreject(channel_index) = g.eloc_file(channel_index).badchan;
        end

        if g.eloc_file(channel_index).badchan == 1
            tmpcolor = DEFAULT_PLOT_SELECTED; % makes color red if channel is rejected
        end
    end


    % removes all repetitive marks
    %g.winrej = merge_trials(g.winrej);

    % new FAST code
    set(fig,'UserData',g);

    %draw_data([],[],fig,0,[],g); % draws data

    draw_data_quick(gcf,g,channel_index,winrej,tmpcolor)
    %draw_matrix(g); % draws matrix
    end
end
