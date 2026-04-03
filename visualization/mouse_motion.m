function mouse_motion(varargin)

try

fig = varargin{3};
%eegplot_adv('topoplot', fig);
% --- idea: make plot component headmap if mouse changes component?
ax0 = varargin{4};
try tmppos = get(ax0, 'currentpoint'); catch return; end
try g = get(fig,'UserData'); catch return; end

if iscell(g)
    g = g(1);
    g = g{:};
    set(fig,'UserData',g);
end
g.thinking = 0;
%if g.thinking == 0
    g.thinking = 1; % THIS IS THE FIX hopefully the damn error of mouse_motion
    set(fig,'UserData',g);
    if g.trialstag ~= -1
        lowlim = round(g.time*g.trialstag+1);
        highlim = round(g.winlength*g.trialstag);
    else
        lowlim  = round(g.time*g.srate+1);
        highlim = round(g.winlength*g.srate);
    end

    if g.incallback && g.trialstag == -1
        tmppos_x=mouse_near_boundary_correction(tmppos(1)+lowlim,g);
        g.winrej = [g.winrej(1:end-1,:)' [g.winrej(end,1) tmppos_x g.winrej(end,3:end)]']';
        set(fig,'UserData', g);
        if tmppos_x < lowlim - highlim * 0.03
            draw_data([],[],fig,2,[],g);
        elseif tmppos_x > lowlim + highlim * 1.03
            draw_data([],[],fig,3,[],g);
        else
            draw_background([],[],fig,g);
        end
    else
      hh = varargin{6}; % h = findobj(fig,'tag','Etime');
      if ~isnumeric(hh) && isobject(hh) && isvalid(hh)
        ax1 = varargin{5};% ax1 = findobj(fig,'tag','eegaxis');
        hv = varargin{7}; % hh = findobj(fig,'tag','Evalue');
        he = varargin{8}; % hh = findobj(fig,'tag','Eelec');  % put electrode in the box
        if g.trialstag ~= -1
            point_is_valid=tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
        else
            point_is_valid=tmppos(1) >= 0 && tmppos(1) <= highlim;
        end
        if point_is_valid
            %g = TYPING(g,0);
            if g.trialstag ~= -1
                tmpval = mod(tmppos(1)+lowlim-1,g.trialstag)/g.trialstag*(g.limits(2)-g.limits(1)) + g.limits(1);
                if g.isfreq, tmpval = tmpval/1000 + g.freqs(1); end
            else
                tmpval = (tmppos(1)+lowlim-1)/g.srate;
                if g.isfreq, tmpval = tmpval+g.freqs(1); end
            end
            set(hh, 'string', num2str(tmpval)); % put g.time in the box
        else
            %g = TYPING(g,1);
            set(hh, 'string', ' ');
        end
        if ~g.envelope && point_is_valid
            %g = TYPING(g,0);
            eegplotdata = get(ax1, 'userdata');
            if isempty(eegplotdata); return; end
            tmppos = get(ax1, 'currentpoint');
            tmpelec = round(tmppos(1,2) / g.spacing);
            tmpelec = min(max(double(tmpelec), 1),g.chans);
            labls = get(ax1, 'YtickLabel');
            set(hv, 'string', num2str(eegplotdata(g.chans+1-tmpelec, min(g.frames,max(1,double(round(tmppos(1)+lowlim)))))));  % put value in the box
            Class = '';
%             if issubfield(g,'EEG.etc.ic_classification.ICLabel.classifications') && g.EEG.plotchannels == 2
%                 Classification = g.EEG.etc.ic_classification.ICLabel.classifications(tmpelec,:);
%                 Classes = g.EEG.etc.ic_classification.ICLabel.classes;
%                 ClassName = Classes(ismember(Classification,max(Classification)));
%                 ClassName = ClassName{:};
%                 Percent = string(round(max(Classification)*100,1));
%                 Class = strcat({' '},ClassName,{' '},Percent,'%');
%             end
            set(he, 'string', strcat(labls(tmpelec+1,:),Class));
        else
            %g = TYPING(g,1);
            set(hv, 'string', ' ');
            set(he, 'string', ' ');
        end

      end
    %end

end
g.thinking = 0;
catch
    try g.thinking = 0; catch ;end
end
