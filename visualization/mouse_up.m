function mouse_up(varargin)
fig = varargin{3};
fig = findobj('tag','eegplot_adv');
g = get(fig,'UserData');

if strcmp(get(fig, 'SelectionType'),'extend')
    return;
end

%if g.thinking == 1

g.incallback = 0;
%set(fig,'UserData', g);  % early save in case of bug in the following
%if strcmp(g.mocap,'on'), g.winrej = g.winrej(end,:);end % nima
if ~isempty(g.winrej)
    if g.winrej(end,1) == g.winrej(end,2) % remove unitary windows
        g.winrej = g.winrej(1:end-1,:);
    else
        if g.winrej(end,1) > g.winrej(end,2) % reverse values if necessary
            g.winrej(end, 1:2) = [g.winrej(end,2) g.winrej(end,1)];
        end
        g.winrej(end,1) = max(1, g.winrej(end,1));
        g.winrej(end,2) = min(g.frames, g.winrej(end,2));
        if g.trialstag == -1 % find nearest trials boundaries if necessary
            I1 = find((g.winrej(end,1) >= g.winrej(1:end-1,1)) & (g.winrej(end,1) <= g.winrej(1:end-1,2)) );
            if ~isempty(I1)
                g.winrej(I1,2) = max(g.winrej(I1,2), g.winrej(end,2)); % extend epoch
                g.winrej = g.winrej(1:end-1,:); % remove if empty match
            else
                I2 = find((g.winrej(end,2) >= g.winrej(1:end-1,1)) & (g.winrej(end,2) <= g.winrej(1:end-1,2)) );
                if ~isempty(I2)
                    g.winrej(I2,1) = min(g.winrej(I2,1), g.winrej(end,1)); % extend epoch
                    g.winrej = g.winrej(1:end-1,:); % remove if empty match
                else
                    I2 = find((g.winrej(end,1) <= g.winrej(1:end-1,1)) & (g.winrej(end,2) >= g.winrej(1:end-1,1)) );
                    if ~isempty(I2)
                        g.winrej(I2,:) = []; % remove if empty match
                    end
                end
            end
        end
    end
    g.winrej = sortrows(g.winrej,'ascend');
end

eegplot_adv_methods('update_trial_rejections', g)

set(fig,'UserData', g);

draw_background([],[],fig,g);

% if strcmp(g.mocap,'on')
%     show_mocap_for_eegplot_adv(g.winrej);
%     g.winrej = g.winrej(end,:);
% end % nima
%end
