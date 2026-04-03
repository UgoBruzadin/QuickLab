function normalize_chan(~,~,fig)

g = get(fig,'userdata');
if g.normed
    disp('Denormalizing...');
else
    disp('Normalizing...');
end

hmenu = findobj(fig, 'Tag', 'Normalize_menu');
hbutton = findobj(fig, 'Tag', 'Norm');
ax1 = findobj(fig,'tag','eegaxis');
data = get(ax1,'UserData');

if isempty(g.datastd)
    g.datastd = std(data(:,1:min(1000,g.frames)),[],2);
end

if g.normed == 1
    for i = 1:size(data,1)

        data(i,:,:) = data(i,:,:)*g.datastd(i);

        if ~isempty(g.data2)
            g.data2(i,:,:) = g.data2(i,:,:)*g.datastd(i);
        end
    end
    set(hbutton,'string', 'Norm');
    try set(findobj(fig,'tag','ESpacing'),'string',num2str(g.oldspacing)); catch; end
else
    g.datastd = std(data(:,1:min(1000,g.frames)),[],2);

    % because of interpolation, a few channels std will be 0, which makes
    % bizarre data display. This substitute the chanel std for the avg std of
    % all channels

    if any(g.datastd < 0.001)
       g.datastd(find(g.datastd < 0.001)) = mean(g.datastd);
    end

    for i = 1:size(data,1)

        data(i,:,:) = data(i,:,:)/g.datastd(i);
        if ~isempty(g.data2)
            g.data2(i,:,:) = g.data2(i,:,:)/g.datastd(i);
        end
    end
    set(hbutton,'string', 'Denorm');
    g.oldspacing = g.spacing;
end

g.normed = 1 - g.normed;
set(hmenu, 'Label', fastif(g.normed,'Denormalize channels','Normalize channels'));
set(fig,'userdata',g);
set(ax1,'UserData',data);
draw_data([],[],fig,0,[],g,ax1);
disp('Done.');
