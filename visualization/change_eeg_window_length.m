% Redraw EEG and change window size
function change_eeg_window_length(~,~,fig,p1)
    g = get(fig,'UserData');
    switch p1
        case 0
            g.winlength = 5 ;
        case 1
            if g.trialstag==-1
                g.winlength = g.winlength * 0.8 ;
            else
                g.winlength = max(1, g.winlength - 1) ;
            end
        case 2
            if g.trialstag==-1
                g.winlength = g.winlength * 1.25 ;
            else
                g.winlength = g.winlength + 1 ;
            end
    end
	%set(fig, 'UserData', g);
	draw_data([],[],fig,0,[],g);
