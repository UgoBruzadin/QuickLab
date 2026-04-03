function eegplot_readkey(~,evnt,varargin)
%try
if nargin >= 3
    fig = varargin{1};
else
    fig = gcf;
end

try g = get(fig,'UserData'); catch return; end
%g = get(fig,'UserData');

ax1 = findobj(fig,'tag','backeeg');
ax2 = findobj(fig,'tag','eegaxis');

tmppos = get(ax1, 'currentpoint');

    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end

    if g.trialstag ~= -1
        lowlim = round(g.time*g.trialstag+1);
        highlim = round(g.winlength*g.trialstag);
    else
        lowlim  = round(g.time*g.srate+1);
        highlim = round(g.winlength*g.srate);
    end

    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));

% if g.trialstag ~= -1
%     lowlim = round(g.time*g.trialstag+1);
%     highlim = round(g.winlength*g.trialstag);
% else
%     lowlim  = round(g.time*g.srate+1);
%     highlim = round(g.winlength*g.srate);
% end

% if g.trialstag ~= -1
%     point_is_valid = tmppos(1) >= 0 && tmppos(1) <= highlim;
% else
     point_is_valid = tmppos(1) >= 0 && tmppos(1) <= highlim;
% end

if point_is_valid

    modifiers = get(fig,'currentModifier');
    switch evnt.Key
        case 'pageup'
            draw_data([],[],fig,1,[],g);
        case 'leftarrow'
            draw_data([],[],fig,2,[],g);
        case 'rightarrow'
            draw_data([],[],fig,3,[],g);
        case 'pagedown'
            draw_data([],[],fig,4,[],g);
        case {'home' 'end'}
            EPosition = findobj(fig,'tag','EPosition');
            id=find(ismember({'home' 'end'},evnt.Key));
            if g.trialstag == -1
                limi=[g.limits(1)/1000 ceil(g.limits(2)/1000-g.winlength)];
            else
                limi=[1 1 + g.frames/g.trialstag - g.winlength];
            end
            set(EPosition,'string',num2str(limi(id)));
            draw_data([],[],fig,0,[],g);
        case 'uparrow'
            if ismember('control',modifiers)
                change_eeg_window_length([],[],fig,2);
            elseif ismember('alt',modifiers)
                change_scale([],[],fig,1);
            end
        case 'downarrow'
            if ismember('control',modifiers)
                change_eeg_window_length([],[],fig,1);
            elseif ismember('alt',modifiers)
                change_scale([],[],fig,2);
            end
        case {'insert'} %CHANGED UGO
            eegplot_adv('window');

        case {'tab'}
            eegplot_adv('winelec');

        case {'z'} % MARK FULL CHANNEL FOR INTERPOLATION, REGARDLESS OF EPOCH STATUS
            %plot_topoplot_CHANNEL(fig,evnt.Key)
            MarkChannel3(fig)

        case {'g'} % VARIANCE
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'h'} % VARIANCE
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'v'} % VARIANCE
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'b'} % STD DEV
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'n'} % ABS MEAN
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'m'} % LOG
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'l'} % EXPONENTIAL
            plot_topoplot_CHANNEL(fig,evnt.Key)

        case {'s'} % CHANGE REJECTION MODE
            eegplot_adv('rejection')

        case {'a'} % GO BACK
            draw_data([],[],fig,1,[],[])

        case {'d'} % GO FORWARD
            draw_data([],[],fig,4,[],[])

        case {'t'} % GO FORWARD
            eegplot_adv('TBT')

%         case {'y'}% TAG AND SAVE
%             eegplot_adv('SAVE')

        case {'q'} % GO back to beginning
            draw_data([],[],fig,8,[],[])

%         case {'`'}
%             %g = THINKING(g,0);
%             set(gcf,'UserData',g);

        case {'r'}
            normalize_chan([],[],fig);

        case {'e'} % GO FORWARD to end
            draw_data([],[],fig,7,[],[])

        case {'w'} % GO FORWARD to end
            eegplot_adv('SWITCH')

        case {'p'}
            %g = THINKING(g,0);

        case {'x'}
            change_scale([],[],fig,1,ax2)

        case {'c'}
            change_scale([],[],fig,2,ax2)

    end
    if nargin > 3
        %mouse_motion([],[],varargin{:})
    end
%else
%     ax1 = findobj(fig,'tag','backeeg');
%     ax2 = findobj(fig,'tag','eegaxis');
%
%     modifiers = get(fig,'currentModifier');
%     switch evnt.Key
%         case 'u'
%             %g = THINKING(g,0);
%             set(gcf,'UserData',g);
%     end
%end
%g.thinking = 0;

%catch g.thinking = 0; return;
end
