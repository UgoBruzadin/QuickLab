% DRAW DATA QUICK FUNCTION: FAST PLOTTING ONE CHANNEL OR ONE PART AT A TIME.

function draw_data_quick(figh,g,channel,winrej,tmpcolor)
%tic
ax1 = findobj(figh,'tag','eegaxis');

data = get(ax1,'UserData');

%meandata = zeros(1,g.chans);

if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
else
        multiplier = g.srate;
end

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

oldspacing = g.spacing;

% plot data
% ---------
hold(ax1,'on')

% fixes the channel order
channel = abs(channel - g.chans - 1);
% --- plotting individual bad region or area
if isempty(winrej)

    tmp_plot_data_y = plotChannel(oldspacing,meandata,data,g,channel,lowlim,highlim);
    plot(ax1,tmp_plot_data_y', 'color', tmpcolor, 'clipping','on');

else

    winrej2 = winrej( (winrej(:,1) >= lowlim) & (winrej(:,1) <= highlim) | ...
        (winrej(:,2) >= lowlim & winrej(:,2) <= highlim) | ...
        (winrej(:,1) <= lowlim & winrej(:,2) >= highlim),:);

    abscmin = max(1,round(winrej2(1,1)-lowlim));
    abscmax = round(winrej2(1,2)-lowlim);

    plot(ax1,abscmin+1:abscmax+1,data(g.chans-channel+1,abscmin+lowlim:abscmax+lowlim) ...
        -meandata(g.chans-channel+1)+channel*g.spacing + (g.dispchans+1)*(oldspacing-g.spacing)/2 +g.elecoffset*(oldspacing-g.spacing), 'color',tmpcolor,'clipping','on')

end
