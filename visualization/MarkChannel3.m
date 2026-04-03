function MarkChannel3(fig)

ax1 = findobj(fig,'tag','backeeg');
tmppos = get(ax1, 'currentpoint');
g = get(fig,'UserData'); % get data of backgroung image {g.trialstag g.winrej incallback}

if g.incallback ~= 1 % interception of nestest calls
    if g.trialstag ~= -1
        lowlim = round(g.time*g.trialstag+1);
        highlim = round(g.winlength*g.trialstag);
    else
        lowlim  = round(g.time*g.srate+1);
        highlim = round(g.winlength*g.srate);
    end
    if (tmppos(1) >= 0) && (tmppos(1) <= highlim)
        if isempty(g.winrej)
            Allwin=0;
        else
            Allwin = (g.winrej(:,1) < lowlim+tmppos(1)) & (g.winrej(:,2) > lowlim+tmppos(1));
        end
        %if any(Allwin) && g.setelectrode
            ax2 = findobj(fig,'tag','eegaxis');
            tmppos = get(ax2, 'currentpoint');
            tmpelec = g.chans + 1 - round(tmppos(1,2) / g.spacing);
            tmpelec = min(max(tmpelec, 1), g.chans);
        %end
        if ~isempty(tmpelec)
            %MarkChannel2([],[],fig,tmpelec,tmppos);
            %g = get(fig,'UserData');
            %channel_index=get(channel_obj,'userdata')
            if isempty(g.command)
                clear global in_callback; return;
            end
            if isfield(g, 'eloc_file')
                if ~isfield(g.eloc_file, 'badchan')
                    for ii=1:length(g.eloc_file)
                        g.eloc_file(ii).badchan = 0;
                    end
                end
                g.eloc_file(tmpelec).badchan = 1-g.eloc_file(tmpelec).badchan;
                %set(fig,'UserData',g);
                draw_data([],[],fig,0,[],g);
                draw_matrix(g);

            end
        end
    end
end
