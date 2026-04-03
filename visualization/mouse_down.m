function mouse_down(varargin)

fig = findobj('tag','eegplot_adv');
g = get(fig,'UserData');
QuickLabDefs;
%get(fig, 'SelectionType') % prints what selection has been done
if strcmp(get(fig, 'SelectionType'),'extend')

    if g.EEG.plotchannels == 1
        plot_topoplot_CHANNEL(fig,{'v'})
    else
        eegplot_adv('topoplot', fig);
    end
    return;
end
%show_mocap_timer = timerfind('tag','mocapDisplayTimer'); if ~isempty(show_mocap_timer),  end% nima
SelectionType=get(fig, 'SelectionType');
if ismember(SelectionType, {'normal', 'alt'})
    ax1 = findobj(fig,'tag','backeeg');
    tmppos = get(ax1, 'currentpoint');
    g = get(fig,'UserData'); % get data of backgroung image {g.trialstag g.winrej incallback}
    g.thinking = 0;

    %if g.thinking == 0
        if g.incallback ~= 1 % interception of nestest calls
            if g.trialstag ~= -1
                lowlim = round(g.time*g.trialstag+1);
                highlim = round(g.winlength*g.trialstag);
            else
                lowlim  = round(g.time*g.srate+1);
                highlim = round(g.winlength*g.srate);
            end
            if (tmppos(1) >= 0) && (tmppos(1) <= highlim)
                %g = TYPING(g,0);
                if isempty(g.winrej)
                    Allwin=0;
                else
                    Allwin = (g.winrej(:,1) < lowlim+tmppos(1)) & (g.winrej(:,2) > lowlim+tmppos(1));
                end
                if strcmp(SelectionType,'alt') || (any(Allwin) && g.setelectrode)
                    ax2 = findobj(fig,'tag','eegaxis');
                    tmppos = get(ax2, 'currentpoint');
                    tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);
                    tmpelec = min(max(tmpelec, 1), g.chans);
                end
                if strcmp(SelectionType,'alt')
                    if ~isempty(tmpelec)
                        MarkChannel([],[],fig,tmpelec,tmppos);
                    end
                else
                    if any(Allwin) % remove the mark or select electrode if necessary
                        lowlim = find(Allwin==1);
                        if g.setelectrode  % select electrode
                            g.winrej(lowlim,tmpelec+5) = ~g.winrej(lowlim,tmpelec+5); % set the electrode
                        else  % remove mark
                            g.winrej(lowlim,:) = [];
                            draw_data([],[],fig,0,[],g);
                        end
                    else
                        if g.trialstag ~= -1 % find nearest trials boundaries if epoched data
                            alltrialtag = [0:g.trialstag:g.frames];
                            I1 = find(alltrialtag < (tmppos(1)+lowlim) );
                            if ~isempty(I1) && I1(end) ~= length(alltrialtag)
                                g.winrej = [g.winrej' [alltrialtag(I1(end))+1 (alltrialtag(I1(end)+1)) g.wincolor zeros(1,g.chans)]']';
                            end
                        else
                            g.incallback = 1;  % set this variable for callback for continuous data
                            if size(g.winrej,2) < 5
                                g.winrej(:,3:5) = repmat(g.wincolor, [size(g.winrej,1) 1]);
                            end
                            if size(g.winrej,2) < 5+g.chans
                                g.winrej(:,6:(5+g.chans)) = zeros(size(g.winrej,1),g.chans);
                            end
                            tmppos_x=mouse_near_boundary_correction(tmppos(1)+lowlim,g);
                            g.winrej = [g.winrej' [tmppos_x tmppos_x g.wincolor zeros(1,g.chans)]']';
                        end
                    end
                    set(fig,'UserData', g);
                    %draw_data([],[],fig,0,[],g);
                    %draw_background([],[],fig,g); % redraw background
                end
            else
                %g = TYPING(g,1);
            end
        %end
    end
end
