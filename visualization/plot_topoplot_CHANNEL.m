function plot_topoplot_CHANNEL(fig,button)

if nargin < 2
    button = {'b'};
end

g = get(fig,'UserData');
EEG = g.EEG;

if ~isfield(EEG.chanlocs, 'theta') || all(cellfun('isempty', { EEG.chanlocs.theta }))
    return;
end

%if EEG.plotchannels == 1
    if ~isstruct(g.eloc_file) || ~isfield(g.eloc_file, 'theta') || isempty( [ g.eloc_file.theta ])
        g.eloc_file = EEG.chanlocs(:);
        %return;
    end
    ax1 = findobj('tag','backeeg','parent',fig);
    tmppos = get(ax1, 'currentpoint');
    ax1 = findobj('tag','eegaxis','parent',fig); % axes handle

    if g.trialstag ~= -1 % time in second or in trials
        multiplier = g.trialstag;
    else
        multiplier = g.srate;
    end
    lowlim = round(g.time*multiplier+1);
    highlim = round(min((g.time+g.winlength)*multiplier+2,g.frames));
    % makes sure click is in valid position

    if g.trialstag ~= -1
        point_is_valid = tmppos(1) >= 0 && tmppos(1) < g.winlength*g.trialstag;
    else
        point_is_valid = tmppos(1) >= 0 && tmppos(1) <= highlim;
    end

    if point_is_valid
        data = get(ax1,'UserData');
        datapos = max(1, round(tmppos(1)+lowlim));
        datapos = min(datapos, g.frames);

        % finding time value for title purposes
        if g.trialstag ~= -1
            tmpval = mod(tmppos(1)+lowlim-1,g.trialstag)/g.trialstag*(g.limits(2)-g.limits(1)) + g.limits(1);
            if g.isfreq, tmpval = tmpval/1000 + g.freqs(1); end
        else
            tmpval = (tmppos(1)+lowlim-1)/g.srate;
            if g.isfreq, tmpval = tmpval+g.freqs(1); end
        end

        colormap("default")
        ax_pic = findobj(fig,'tag','topo');
        ax_matrix = findobj(fig,'tag','matrix');
        if ~isempty(ax_matrix)
            set(ax_matrix, "Visible",'off');
            try set(ax_matrix.Parent, "Visible",'off'); catch; end %UGO CHANGES .PARENT
        end
%         if isempty(ax_pic)
%             ax_pic = axes('Parent', gcf, 'position',g.matrixpos,'units','normalized','tag','topo','XTickLabel',{[]},'YTickLabel',{[]},Color=[.93 .96 1]);
%         else
%             %delete(ax_pic,ax_matrix);
             ax_pic = axes('Parent', gcf, 'position',g.matrixpos,'units','normalized','tag','topo','XTickLabel',{[]},'YTickLabel',{[]},'Color',[.93 .96 1]);
%         end
        % get color
        BackColor = get(fig,'Color');

        Printed = 0;
        % plot topo % it changes the background color of the figure to EEGLAB's default
        %topoplot(data(:,datapos), g.eloc_file);
        if ~isempty(g.winrej)

            % LOOPS FOR EVERY STRETCH OF REJECTION
            %for k=1:size(g.winrej,1)
            print_id = datapos >= g.winrej(:,1) & datapos <= g.winrej(:,2);
                % CHECKS FOR MOUSE POSITION WITHIN A REJECTION STRETCH
                if any(print_id)
                    rej_part = find(print_id);

                    % finding epoch value for title purposes
                    if g.trialstag ~= -1
                        sel_epoch = floor(datapos/g.trialstag + 1);
                        tmptitle = ['Epoch #',num2str(sel_epoch)];
                    else
                        %sel_epoch = '';
                        tmptitle = ['Region ',num2str(rej_part)];
                    end


                    % Calculates the averageb for that stretch
                    if iscell (button)
                        button = button{:};
                    end
                    switch button
                        case 'v'
                        EpochAverage = var(EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2)),0,2);
                        set(findobj(gcf,'Tag','headmap'),'String',['Mean Var. ', tmptitle]);

                        case 'b'
                        EpochAverage = std((EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2))),0,2);
                        set(findobj(gcf,'Tag','headmap'),'String',['Mean Std. ', tmptitle]);

                        case 'n'
                        EpochAverage = mean(abs(EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2))),2);
                        set(findobj(gcf,'Tag','headmap'),'String',['Abs. Mean ', tmptitle]);

                        case 'm'
                        EpochAverage = mean(log10(abs(EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2)))),2);
                        set(findobj(gcf,'Tag','headmap'),'String',['Mean Log. ', tmptitle]);

                        case 'l'
                          % Is Crashing #bug #Ugo
%                         EpochAverage = mean(exp(EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2))),2);
%                         set(findobj(gcf,'Tag','headmap'),'String',['Mean Exp. ', tmptitle]);

                        case 'h'
                        EpochAverage2 = var((EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2))),0,2);
                        FullAverage = var((EEG.data(:,:)),0,2);
                        EpochAverage = FullAverage - EpochAverage2;
                        set(findobj(gcf,'Tag','headmap'),'String',['Data Var - Var ', tmptitle]);

                        case 'g'
                        %EpochAverage2 = std((EEG.data(:,g.winrej(rej_part,1):g.winrej(rej_part,2))),0,2);
                        EpochAverage = var((EEG.data(:,:)),0,2);
                        %EpochAverage = FullAverage - EpochAverage2;
                        set(findobj(gcf,'Tag','headmap'),'String','Data Avg. Std');

                    end
                    MeanDeviation = mean(EpochAverage);
                    EpochAverage = EpochAverage - MeanDeviation;
                    % PLOTS AVERAGE OF THAT STRETCH
                    colormap("default");
                    topoplot(EpochAverage, EEG.chanlocs(:));
                    %set(topo,'tag','topo');
                    % This makes sure it only prints once
                    Printed = 1;
                    %break;
                end
            %end
            if ~Printed
                % if no prints have been done, then there's no matching
                % rejected areas, therefore prints normal topoplot for that
                % column
                %
                %ax_pic = axes('Parent', gcf, 'position',g.matrixpos,'units','normalized','tag','topo','XTickLabel',{[]},'YTickLabel',{[]},Color=[.93 .96 1]);
                colormap("default")
                topoplot(EEG.data(:,datapos), EEG.chanlocs(:));
                set(findobj(gcf,'Tag','headmap'),'String',['Heatmap at time: ',num2str(tmpval)]);
                %set(topo,'tag','topo');
            end
        else
            %ax_pic = axes('Parent', gcf, 'position',g.matrixpos,'units','normalized','tag','topo','XTickLabel',{[]},'YTickLabel',{[]},Color=[.93 .96 1]);
            colormap("default")
            topoplot(EEG.data(:,datapos), EEG.chanlocs(:));
            set(findobj(gcf,'Tag','headmap'),'String',['Heatmap at time: ',num2str(tmpval)]);
            %set(topo,'tag','topo');
        end

        % set background color back to whatever it was before.
        set(fig,'Color',BackColor);
    end


%% These functions below are brand new, to be used by the new METHODS section

    function change_list(x,y)
        g = get(gcf,'UserData');
        list = findobj(gcf,'tag', 'ListPopup');

        choice = list.Value;

        met = findobj(gcf,'tag', 'ALLmethods');
        opt = findobj(gcf,'tag', 'ALLoptions');
        hint = findobj(gcf,'tag', 'ALLhints');
        switch choice
            case 1
                met.String = g.tbtmethods;
                g.currentoptions = g.tbtoptions;
            case 2
                met.String = g.eegmethods;
                g.currentoptions = g.eegoptions;
            case 3
                met.String = g.iclmethods;
                g.currentoptions = g.icloptions;
            case 4
                met.String = g.plotmethods;
                g.currentoptions = g.plotoptions;
        end
        met.Value = 1;
        set(gcf,'UserData',g);
        change_options(x,y);

    function change_options(x,y)
        g = get(gcf,'UserData');

        list = findobj(gcf,'tag', 'ListPopup');

        met = findobj(gcf,'tag', 'ALLmethods');
        opt = findobj(gcf,'tag', 'ALLoptions');
        hint = findobj(gcf,'tag', 'ALLhints');

        current = g.currentoptions;

        try opt(1).String = current{met(1).Value}; catch, end
        try hint(1).String = current{met(1).Value,2};catch, end

    function g = methods(g)

        g = get(gcf,'UserData');
        %set(gcf,'UserData',g);

        list = findobj(gcf,'tag', 'ListPopup');

%         if ~isfield(g,'old')
%             if isempty(g.old)
%                 g.old{1} = g;
%                 g.gnumber = 1;
%             end
%         end
        %g = THINKING(g,1);
        %g.old(end) = g;
        set(gcf,'UserData',g);

        switch list.Value
            case 1
                g = eegplot_adv_methods('TBT', g);
            case 2
                g = eegplot_adv_methods('QUICKLAB', g);
                g = make_eloc_file(g);
            case 3
                g = eegplot_adv_methods('ICLABEL', g);
                g = make_eloc_file(g);
            case 4
                g = eegplot_adv_methods('PLOTS', g);
        end

        %g = THINKING(g,0);
       %set(gcf,'Color',[g.backcolor]);
%
%         g.old{end+1} = g;
%         g.gnumber = length(g.old);

        %g = make_eloc_file(g);
        set(gcf,'UserData',g);
        eegplot_adv('setelect');
        eegplot_adv('winelec_auto');
        draw_matrix(g);
