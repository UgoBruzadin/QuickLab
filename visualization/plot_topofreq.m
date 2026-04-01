function plot_topofreq(index)

currentPoint = get(gca, 'CurrentPoint');
power = currentPoint(1,2);
freq = currentPoint(1,1);

global EEG;

set(findobj(gcf,'Tag','power'),'String',power)
set(findobj(gcf,'Tag','freq'),'String',freq)
set(findobj('Tag','channel'),'String', EEG.chanlocs(index).labels);


mainfig = findobj('Tag','Data');

%mainfig = gca;
g = mainfig.UserData;

eegspecdB = g.eegspecdB;

if size(eegspecdB,1) ~= 1
%[power,freq] = getPlotPoint(index);
    disp(strcat('Channel selected ','...', num2str(index)));
    A = g.freqs - freq;
    f = find(abs(A) == min(abs(A)));
    topodata = eegspecdB(:,f)-nan_mean(eegspecdB(:,f));

    axes('Parent', gcf, 'position',[ 0.91 0.50 0.085 0.15 ],'units','normalized');

    topoplot(topodata,g.chanlocs);
end

