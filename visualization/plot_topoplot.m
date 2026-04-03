function plot_topoplot(fig)

g = get(fig,'UserData');
EEG = g.EEG;

if EEG.plotchannels == 1
    if ~isstruct(g.eloc_file) || ~isfield(g.eloc_file, 'theta') || isempty( [ g.eloc_file.theta ])
        return;
    end
    ax1 = findobj('tag','backeeg','parent',fig);
    tmppos = get(ax1, 'currentpoint');
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    % plot vertical line
    %yl = ylim(ax1);
    %plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end
    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
    % makes sure click is in valid position

    if g.trialstag ~= -1
        point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
    else
        point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
    end
    if point_is_valid
        data = get(ax1,'UserData');
        datapos = max(1, round(tmppos(1)+lowlim));
        datapos = min(datapos, g.frames);

        axes('Parent', fig, 'position',g.headpos,'units','normalized');

        % get color
        BackColor = get(fig,'Color');

        Printed = 0;
        % plot topo % it changes the background color of the figure to EEGLAB's default
        %topoplot(data(:,datapos), g.eloc_file);
        if ~isempty(g.winrej)
            % LOOPS FOR EVERY STRETCH OF REJECTION
            for k=1:size(g.winrej,1)

                % CHECKS FOR MOUSE POSITION WITHIN A REJECTION STRETCH
                if datapos >= g.winrej(k,1) && datapos <= g.winrej(k,2)
                    % Calculates the average for that stretch
                    EpochAverage = mean(data(:,g.winrej(k,1):g.winrej(k,2)),2);
                    %EpochAverage = std(data(:,g.winrej(k,1):g.winrej(k,2)),0,2);
                    MeanDeviation = mean(EpochAverage);
                    EpochAverage = EpochAverage - MeanDeviation;
                    % PLOTS AVERAGE OF THAT STRETCH
                    topoplot(EpochAverage, g.eloc_file);
                    % This makes sure it only prints once
                    Printed = 1;
                    break;
                end
            end
            if ~Printed
                % if no prints have been done, then there's no matching
                % rejected areas, therefore prints normal topoplot for that
                % column
                topoplot(data(:,datapos), g.eloc_file);
            end
        else
            topoplot(data(:,datapos), g.eloc_file);
        end

        % set background color back to whatever it was before.
        set(fig,'Color',BackColor);
    end
else
    %     ax1 = findobj('tag','backeeg','parent',fig);
    %     tmppos = get(ax1, 'currentpoint');
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle
    tmppos = get(ax1, 'currentpoint');
    % plot vertical line
    %yl = ylim(ax1);
    %plot(ax1, [ tmppos tmppos ], yl, 'color', [0.8 0.8 0.8]);
    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end
    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
    % makes sure click is in valid position

    if g.trialstag ~= -1
        point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
    else
        point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
    end
    if point_is_valid
        tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);
        tmpelec = min(max(tmpelec, 1), g.chans);

        %labls = get(ax1, 'YtickLabel');
        %component = str2num(labls(tmpelec+1,:));

        pop_prop_extended_adv(EEG, 0, tmpelec,'NaN',{'freqrange', [2 55]});
    end
end
%     if g.trialstag == -1
%          latsec = (datapos-1)/g.srate;
%          title(sprintf('Latency of %d seconds and %d milliseconds', floor(latsec), round(1000*(latsec-floor(latsec)))));
%     else
%         trial = ceil((datapos-1)/g.trialstag);
%         latintrial = eeg_point2lat(datapos, trial, g.srate, g.limits, 0.001);
%         title(sprintf('Latency of %d ms in trial %d', round(latintrial), trial));
%     end
