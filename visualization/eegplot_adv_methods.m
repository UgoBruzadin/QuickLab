function varargout = eegplot_adv_methods(action, varargin)
% eegplot_adv_methods - Processing methods for eegplot_adv
% Dispatches to local subfunctions: SWITCH, APPLY, PLOTS, ICLABEL, QUICKLAB, TBT,
% update_trial_rejections, merge_trials, detect_flatline

switch action
    case 'SWITCH'
        varargout{1} = SWITCH(varargin{1});
    case 'APPLY'
        varargout{1} = APPLY(varargin{1});
    case 'PLOTS'
        varargout{1} = PLOTS(varargin{1});
    case 'ICLABEL'
        varargout{1} = ICLABEL(varargin{1});
    case 'QUICKLAB'
        varargout{1} = QUICKLAB(varargin{1});
    case 'TBT'
        varargout{1} = TBT(varargin{1});
    case 'update_trial_rejections'
        update_trial_rejections(varargin{1});
    case 'merge_trials'
        varargout{1} = merge_trials(varargin{1});
    case 'detect_flatline'
        varargout{1} = detect_flatline(varargin{:});
end

% =========================================================================
% Local subfunctions
% =========================================================================

function g = SWITCH(g)

% THIS FUNCTION SWITCH BETWEEN EEG DATA AND ICA DATA

    g = get(gcf,'UserData'); % Get data from figure
    if ~isempty(g.EEG.icawinv)

        EEG = g.EEG;
        ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle

        if g.EEG.plotchannels == 1
            g.EEG.plotchannels = 0; % Change the variable that stores whether it is ICA or EEG

            % Store backups of the important variables for EEG mode
            g.eloc_file_ch = g.eloc_file;
            g.datastd_ch = g.datastd;
            g.normed_ch = g.normed;
            g.winrej_ch = g.winrej;
            g.data_ch = g.data;
            g.spacing_ch = g.spacing; % Store current spacing for EEG mode

            % Collect the ICA/PCA variables
            g.eloc_file = g.eloc_file_pc;
            g.datastd = g.datastd_pc;
            g.normed = g.normed_pc;
            g.winrej = g.winrej_pc;
            if isempty(EEG.icaact)
                g.data = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
                g.data_pc = eeg_getdatact(EEG, 'component', [1:size(EEG.icaweights,1)]);
            else
                g.data = EEG.icaact;
                g.data_pc = EEG.icaact;
            end
            g.chans = size(EEG.icaact,1);

            % Restore the last-used spacing for ICA mode
            g.spacing = g.spacing_pc; % Restore stored spacing for ICA mode
            try set(findobj('tag','ESpacing','parent',gcf),'string',num2str(g.spacing)); catch; end
            fprintf('Showing ICA data \n');

        else
            g.EEG.plotchannels = 1;

            % Store backups of the important variables for ICA mode
            g.eloc_file_pc = g.eloc_file;
            g.datastd_pc = g.datastd;
            g.normed_pc = g.normed;
            g.winrej_pc = g.winrej;
            g.data_pc = g.data;
            g.spacing_pc = g.spacing; % Store current spacing for ICA mode

            % Collect the Channel variables
            g.eloc_file = g.eloc_file_ch;
            g.datastd = g.datastd_ch;
            g.normed = g.normed_ch;
            g.winrej = g.winrej_ch;
            g.data = EEG.data;
            g.data_ch = EEG.data;
            g.chans = EEG.nbchan;

            % Restore the last-used spacing for EEG mode
            g.spacing = g.spacing_ch; % Restore stored spacing for EEG mode
            try set(findobj('tag','ESpacing','parent',gcf),'string',num2str(g.spacing)); catch; end

            fprintf('Showing EEG data \n');
        end

        g.normed = 0;
        hmenu = findobj(gcf, 'Tag', 'Normalize_menu');
        hbutton = findobj(gcf, 'Tag', 'Norm');


        set(hbutton, 'string', fastif(g.normed,'Denorm','Norm'));
        %set(hmenu, 'string', fastif(g.normed,'Denormalize channels','Normalize channels'));
        % Set updated data and settings in figure properties
        set(gcf,'UserData',g);
        set(ax1,'UserData',g.data);


%         if g.normed_pc ~= g.normed_ch
%             g = normalize_chan_noplot([],g,gcf);
%         end

        % Redraw data with the new settings

        eegplot_adv('drawp', 0); % 9 or 0, they may do the same thing
        eegplot_adv('winelec_auto');
        eegplot_adv('draw_matrix');
        eegplot_adv('draws', 1);

    end



function g = APPLY(g)
    QuickLabDefs;
    g = get(gcf,'UserData');
    %g = THINKING(g,1); %blocks all clicks and movements to avoid crashes and errors

    EEG = g.EEG;
    %eegplot_adv('drawp', 0);

    %store current g in backup g.old
%     if ~isfield(g,'old')
%         g.old = {};
%         g.old{1} = {g};
%         g.gnumber = 1;
%     else
%         g.old{end+1} = g;
%         g.gnumber = length(g.old);
%     end

    set(gcf,'UserData',g); %store info in the plot

    if ~isfield(g.eloc_file, 'badchan')
        for ii=1:length(g.eloc_file)
            g.eloc_file(ii).badchan = 0;
        end
    end

    EEG.save = 1;
    EEG.ICA = 0;
    if g.EEG.plotchannels == 1
        g.winrej_ch = g.winrej;
        applycom_ch = 'NEW=EEG;[NEW LASTCOM1] = eeg_eegrej_adv(NEW,g.winrej,1,find([g.eloc_file.badchan])); ' ; %modified for eegrej2
        eval(applycom_ch);
        g.winrej_ch = [];
        g.winrej = [];
    else
        g.winrej_pc = g.winrej;
        applycom_pc = 'NEW=EEG;[NEW LASTCOM1] = eeg_eegrej_adv(NEW,g.winrej,2,find([g.eloc_file.badchan])); ' ; %modified for eegrej2
        eval(applycom_pc);
        g.winrej_pc = [];
        g.winrej = [];
%         if isempty(NEW.icaact)
%             NEW.icaact = (NEW.icaweights*NEW.icasphere)*NEW.data(NEW.icachansind,:);
%         end
        %g = SWITCH(g);
        %g.EEG.icaact = []; g.EEG.icawinv = []; g.EEG.icasphere = []; g.EEG.icaweights = []; g.EEG.icachansind = [];
    end
    % collect new EEG
    g.EEG = NEW;
    % clear winrej variables of the new file


    % clear suffix
    if SAVEBACKUP == 1
        g.EEG.suffix = [];
        set( findobj(gcf,'tag','SaveNowText'),'String','');
    else
        set( findobj(gcf,'tag','SaveNowText'),'String',g.EEG.suffix);
    end
    % reset norm
    g.normed = 0;

    % get correct data
    if isfield(g.EEG,'plotchannels')
        %fastif(EEG.plotchannels,g.data = g.EEG.data;g.data = g.EEG.icaact;)
        if g.EEG.plotchannels == 1
            g.data = g.EEG.data;
        else
            if isempty(g.EEG.icaact)
                g.EEG.icaact = eeg_getdatact(g.EEG, 'component', [1:size(g.EEG.icaweights,1)]);

                g.data = g.EEG.icaact;
            else
                g.data = g.EEG.icaact;
            end
        end
    end

    % make new eloc_file based on new channels/components
    g = eegplot_adv('make_eloc_file', g);
    % turn on mouse movement and key presses
    %g = THINKING(g,0);

    % save new backup
%     g.old{end+1} = g;
%     g.gnumber = g.gnumber +1;

    % make suffix, store the bool of a NEW vs OLD data.

    fprintf('Rejections applied to new dataset');

    set(gcf,'UserData',g);
    %[g.EEG] = eeg_store([], g.EEG);
    ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
    set(ax1,'UserData',g.data);

    update_trial_rejections(g);

    % creates strings for printing

    eegplot_adv('drawp', 0);
    eegplot_adv('winelec_auto');

%% ALL METHODS START HERE

   function g = PLOTS(g)

   g = get(gcf,'UserData');
   EEG = g.EEG;
   if ~isfield(g,'NEW')
       g.NEW = [];
   end
   % get methods
   method = findobj(gcf,'tag', 'ALLmethods');
   options = findobj(gcf,'tag', 'ALLoptions');
   nbadchans = findobj(gcf,'tag', 'TBTnchans');
   pctbadtrial = findobj(gcf,'tag', 'TBT%');
   opt = options.String;
   %opt = str2num(options(1).String);
   if isempty(opt)
       opt = '[]';
   end
   % run methods
   suffix = '';
   com = '';
   display_eeg_or_ica = 1; % if 1 EEG, if 2 ICA
   switch method(1).Value
       case 1
           newcom = ['quick_spectra(EEG,', opt, ');'];
           %quick_spectra(EEG,opt(1),opt(2),opt(3));
       case 2
           newcom = ['[EEG,com] = quick_IClabel(g.EEG,[],[],[],[],[''eegplot_adv(''''MERGE_REJECTION'''')'']);'];
       case 3
           newcom = ['[EEG,com] = pop_viewprops_adv(EEG, 0, [], 1:size(EEG.icawinv,2), {''freqrange'',[2 55]},{},' , opt ,');'];
   end

   eval(newcom);

   function g = ICLABEL(g)

   g = get(gcf,'UserData');
   EEG = g.EEG;
   % set parameters
%    if EEG.plotchannels == 1
%        g = SWITCH(g);
%    end

   g.EEGpre = EEG;
   if ~isfield(g,'NEW')
       g.NEW = [];
   end
   % get methods
   method = findobj(gcf,'tag', 'ALLmethods');
   options = findobj(gcf,'tag', 'ALLoptions');
   nbadchans = findobj(gcf,'tag', 'TBTnchans');
   pctbadtrial = findobj(gcf,'tag', 'TBT%');
   mybadcomps = [];
   % run methods
   [NEW] = pop_iclabel(EEG, 'default');

   opt = str2num(options(1).String);

   switch method(1).Value
       case 1
           [NEW] = pop_par_icflag(NEW, [NaN NaN;opt(1) opt(2);opt(1) opt(2);opt(1) opt(2);opt(1) opt(2);NaN NaN;NaN NaN]);
       case 2
           [NEW] = pop_par_icflag(NEW, [opt(1) opt(2);NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
       case 3
           [NEW] = pop_par_icflag(NEW, [NaN NaN;opt(1) opt(2);NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
       case 4
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;opt(1) opt(2);NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
       case 5
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;NaN NaN;opt(1) opt(2);NaN NaN;NaN NaN;NaN NaN]);
       case 6
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;NaN NaN;NaN NaN;opt(1) opt(2);NaN NaN;NaN NaN]);
       case 7
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN;opt(1) opt(2);NaN NaN]);
       case 8
           [NEW] = pop_par_icflag(NEW, [NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN;NaN NaN;opt(1) opt(2)]);
   end

   % store new data in .NEW and .EEG
   g.EEG = NEW;
   %g.NEW = NEW;

   if EEG.plotchannels == 1
       g = SWITCH(g);
   end

   mybadcomps = find(NEW.reject.gcompreject);
   if ~isempty(mybadcomps)
       for ind = 1:size(mybadcomps)
           g.eloc_file(mybadcomps(ind)).badchan = 1; % marks channels as bad
       end
   end

   % make suffix, store the bool of a NEW vs OLD data.
   g.EEG.suffix = 'IcL';
   fprintf('Showing Tagged ICLABEL dataset');

   % store and draw data
   set(gcf,'UserData',g);
   ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
   %set(ax1,'UserData',g);

   eegplot_adv('drawp', 0);
   eegplot_adv('draw_matrix');
   eegplot_adv('setelect');
   eegplot_adv('drawp',0);


   function g = QUICKLAB(g)

   g = get(gcf,'UserData');
   EEG = g.EEG;
   if ~isfield(g,'NEW')
       g.NEW = [];
   end
   % get methods
   method = findobj(gcf,'tag', 'ALLmethods');
   options = findobj(gcf,'tag', 'ALLoptions');
   nbadchans = findobj(gcf,'tag', 'TBTnchans');
   pctbadtrial = findobj(gcf,'tag', 'TBT%');
   opt = options.String;
   if isempty(opt)
       opt = '[]';
   end
   % run methods
   suffix = '';
   com = '';
   display_eeg_or_ica = 1; % if 1 EEG, if 2 ICA
   switch method(1).Value
       case 1
           newcom = ['[NEW] = quick_PCA(EEG,' opt ');'];
           %NEW = quick_PCA(EEG,[],'binica',0);
           suf = str2num(opt(1:4));
           if isempty(suf)
               suffix = 'ICA';
           else
               suffix = strcat('PCA',num2str(suf));
           end
           display_eeg_or_ica = 2;
       case 2
           newcom = [strcat('[NEW,com] = quick_bss2(EEG,', opt, ');')];
           suffix = 'BSS';
       case 3
           newcom = [strcat('[NEW,com] = quick_reref(EEG,', opt, ');')];
           suffix = opt;
%        case 4
%            newcom = ['[NEW,com] = quick_HM94(EEG);'];
%            suffix = 'HM94';
       case 4
           newcom = [strcat('[NEW,com] = quick_epoch(EEG,', opt, ');')];
           suffix = 'Ep6';
%        case 5
%            newcom = '[NEW,com] = quick_dotloc(EEG)';
           %suffix = 'Hm92Ep6bssICA';
%        case 7
%            newcom = '[NEW,com] = quick_bss2(EEG);[NEW,com] = quick_PCA(NEW,[],[],0);';
%            suffix = 'BSSICA';
       case 5
           newcom = [strcat('[NEW,com] = quick_dipfit(EEG,', opt, ');')];
           suffix = 'DF';
       case 6
           newcom = strcat(opt,';','NEW = EEG;');
           suffix = '';
%        case 9
%            newcom = '[NEW,com] = quick_icrejBSS(EEG)';

%            suffix = strcat('ICAPJ_BSSICA');
   end

   eval(newcom);
   % store new data in .NEW and .EEG

   try g.EEG = NEW; catch; end;
   if ~isfield(g.EEG,'suffix'); g.EEG.suffix = ''; end

   currsuf = get(findobj(gcf,'tag','SaveNowText'),'String');
   set( findobj(gcf,'tag','SaveNowText'),'String',strcat(currsuf,suffix));
   g.EEG.suffix = strcat(g.EEG.suffix,suffix);

   %g.NEW = NEW;

   if g.EEG.plotchannels == 1
       g.data = NEW.data;
   else
       if ~isempty(NEW.icaact)
           g.data = NEW.icaact;
       else
           g = SWITCH(g); % THIS DOESNT WORK
       end
   end
   %GET ICA DATA AS WELL

   % make new eloc_file based on new channels/components
   g.com = [g.com,com];
   g = eegplot_adv('make_eloc_file', g);
   g.winrej = []; g.winrej_pc = []; g.winrej_ch = [];

   % make suffix, store the bool of a NEW vs OLD data.
   fprintf(strcat('Showing processed dataset after running:', newcom, com, '/r'));

   % store and draw data
   set(gcf,'UserData',g);
   ax1 = findobj('tag','eegaxis','parent',gcf); % axes handle
   set(ax1,'UserData',g.data);

   % ONE OF THESE LOWER FUNCTIONS - PROBABLY WHERE THERE IS A BUG! UGO BUG 12-19-2022
   eegplot_adv('drawp', 0);
   eegplot_adv('setelect');
   %eegplot_adv('winelec_auto');

    function g = TBT(g)
        % This function was adapted from TBT plugin by

        g = get(gcf,'UserData');
        EEG = g.EEG;

        % storing old data
        g.EEGpre = EEG;
        g.winrejPRE = g.winrej;

        if EEG.plotchannels ~= 1
            icacomp = '0';
            chancomps = '1:size(EEG.icaact,1)';
            ica = 'ica';
        else
            icacomp = '1';
            chancomps = '1:EEG.nbchan';
            ica = '';
        end
        method = findobj(gcf,'tag', 'ALLmethods');
        options = findobj(gcf,'tag', 'ALLoptions');
        nbadchans = findobj(gcf,'tag', 'TBTnchans');
        pctbadtrial = findobj(gcf,'tag', 'TBT%');

        splits = split(options.String,']');
        if ~isempty(eval(strcat(splits{1},']')))
            chancomps = strcat(splits{1},']');
        end


        first_comma = strfind(options(1).String,']');
        all_options = options(1).String(first_comma(1)+2:end);


        switch method(1).Value

            case 7
                opt = options(1).String;
                g = detect_flatline(g);
                update_trial_rejections(g);
                return;
            case 1
                comrej  = ['EEG = pop_eegthresh(EEG, ' icacomp ',' chancomps ',' all_options ', 1, 0);'];
                chosen_func    = 'rejthreshE';
            case 2
                comrej  = ['[EEG, comrej] = pop_rejtrend(EEG, ' icacomp ', ' chancomps ',' all_options ', 1, 0,0);'];
                chosen_func    = 'rejconstE';
            case 3
                comrej  = ['[EEG, ~,~,~,comrej] = pop_jointprob(EEG, ' icacomp ', ' chancomps ',' all_options ', 1, 0, 0);'];
                chosen_func    = 'rejjpE';
            case 4
                comrej  = ['[EEG, ~,~,~,comrej] = pop_rejkurt(EEG, ' icacomp ', ' chancomps ',' all_options ', 1, 0, 0);'];
                chosen_func    = 'rejkurtE';
            case 5
                comrej  = ['[EEG, ~, comrej]    = pop_rejspec(EEG, ' icacomp ',' all_options , ',''elecrange'',' chancomps ');'];
                chosen_func    = 'rejfreqE';
            case 6
                if EEG.plotchannels ~= 1
                    comrej  = ['[EEG, comrej]    = pop_eegmaxmin_ica(EEG,' all_options ');'];
                    chosen_func    = 'rejmaxminICA';
                else
                    comrej  = ['[EEG, comrej]    = pop_eegmaxmin(EEG,' all_options ');'];
                    chosen_func    = 'rejmaxminE';
                end
                ica = ''; %rejmaxminE doesn't have options for ICA
            case 8
                comrej = ['[EEG,comrej] = pop_eegchannelpop(EEG,' icacomp ',' chancomps ',' all_options ');'];
                chosen_func = 'rejchanpops';
        end

        fprintf(strcat('Running function:',comrej)); % Prints function being run
        % RUN FUNCTION!
        eval(comrej);

        winrej = EEG.reject.(strcat(ica,chosen_func)); % Gets rejected data into winrej
%
%         if ~isempty(winrej)
%            winrej = winrej | g.winrej(:,6:end);
%         end

        %% Find bad trials and Channels

        % Find channels that have been marked as bad in more than X% of trials:
        channel_index       = sum(winrej,2)/EEG.trials >= str2double(pctbadtrial(1).String)/100;   % boolean list
        % if sum(channel_index)
        %     bChan_lab           = EEG.chanlocs(channel_index).labels;     % Channel label list
        %     nbadchan            = length(bChan_lab);                    % count bad channels
        %     %winrej(channel_index,:)   = 1;                                    % mark for plotting
        % else
        %     bChan_lab = [];
        %     nbadchan = 0;
        % end
        if ~isfield(g.eloc_file, 'badchan')
            for ii=1:length(g.eloc_file)
                g.eloc_file(ii).badchan = 0;
            end
        end

        % Collects rejected trials BUG
        if sum(channel_index)
            badchannels = find(channel_index);
            for ind = badchannels'
                g.eloc_file(ind).badchan = 1; % marks channels as bad
                % removes these channels from trial rejections!
                winrej(ind,:) = 0;
            end
        end

        % Find trial with more than X bad channels:
        trials_ind  = 1:EEG.trials;
        bTrial_ind  = sum(winrej,1) >= str2double(nbadchans(1).String);     % boolean list
        bTrial_num  = trials_ind(bTrial_ind);	% trial list
        nbadtrial   = length(bTrial_num);       % count bad trials

        % trying to combine the trials
%         old_bad_trials = find(g.winrej(:,3) == 1 & g.winrej(:,4) ~= 1)';
%         old_chan_interp = find(g.winrej(:,4) == 1 & g.winrej(:,3) ~= 1)';
%
        % Paints rejections red-ish and interpolations green-ish
        if ~isempty(winrej)
            mark                    = ones([0,5] + size(winrej'));
            mark(:,6:end)           = double(winrej');
            mark(:,1)               = 1:EEG.pnts:EEG.pnts*EEG.trials;   % start sample
            mark(:,2)               = mark(:,1)+EEG.pnts-1;               % end   sample

            mark(bTrial_ind,3)      = 1;                                % R for bad trials
            mark(bTrial_ind,4)      = 0.8;                              % G for bad trials
            mark(bTrial_ind,5)      = 0.9;                              % B for bad trials

            mark(~bTrial_ind,3)      = 0.7;                              % R for bad chans
            mark(~bTrial_ind,4)      = 1;                                % G for bad chans
            mark(~bTrial_ind,5)      = 0.8;                              % B for bad chans


            % paints the trials with empty selected channels white
            %mark((sum(mark(:,5:end),2) < 1),3:5) = 1;                    % cleaner code compared with the for loop
            mark((sum(mark(:,5:end),2) < 1),:) = [];                    % cleaner code compared with the for loop

            % clean non-rejected trials from winrej.
            %mark((sum(mark(:,5:end),2) < 1),3:5) = 1
%             for i=size(mark,1):-1:1
%                 if ~sum(mark(i,6:end))
%                     mark(i,3:5) = 1; % paint their background white!
%                 end
%             end

            % collects all marks and adds to g.winrej
             %try
                 % combines previous g.winrej with new marks
             %    g.winrej(:,6:end) = g.winrej(:,6:end) | mark(:,6:end);
                 % combine the paints of greens, reds and whites.
                 %mark(mark(:,3:5) == [1,0.8,0.9])
                 %not greens)

             %catch
            g.winrej = [g.winrej;mark];
             %end

            % --- Updating and organizing winrej
            g.winrej = unique(g.winrej,'rows');
            g.winrej = sortrows(g.winrej,'ascend');
            g.winrej = merge_trials(g.winrej);
            % --- storing new winrej
            g.winrejNEW = g.winrej;
            update_trial_rejections(g);

        end


function update_trial_rejections(g)
%% this function updates the tags for trial rejection and partial interpolations
%g = get(gcf,'UserData');

% calculate total numbers of rejections and interpolations
g.winrej = sortrows(g.winrej,'ascend');

reds = num2str(0);
greens = num2str(0);
bad_chans = num2str(0);
partial_interps = num2str(0);

% removes all repetitive marks
g.winrej = unique(g.winrej,'rows');

if ~isempty(g.winrej)
    % calculate reds and greens using RGB 'R' (3) and 'G' (4)
    reds = num2str(sum(g.winrej(:,3) == 1));
    greens = num2str(sum(g.winrej(:,4) == 1));

% gets total sum of bad channels and partial interpolations
if ~isfield(g.eloc_file, 'badchan')
    for ii=1:length(g.eloc_file)
        g.eloc_file(ii).badchan = 0;
    end
end
    try bad_chans = num2str(sum([g.eloc_file.badchan])); catch; end
    partial_interps = num2str(sum(sum(g.winrej(find(g.winrej(:,4) == 1),6:end),2))); %finds greends, get columns sum, get total sum
end
% creates strings for printing
total_chanmarks = strcat('Marked Channels: ',{' '},bad_chans,' (', partial_interps, ' P','arts)');
total_marks = strcat('Marked Trials: ',{' '},reds,' Red,',{' '}, greens, ' G','reen');

% prints on menu using these tags
set(findobj(gcf, 'Tag', 'Count_Channels'),'string',total_chanmarks);%
set(findobj(gcf, 'Tag', 'Count_Trials'),'string',total_marks);%

eegplot_adv('drawp', 0);
eegplot_adv('draw_matrix');




% function tf = issubfield(S,FIELD)
% % Posted by Geoff McVittie on Matlab Answers on https://www.mathworks.com/matlabcentral/answers/103924-is-it-possible-to-check-for-existence-of-fields-in-nested-structures-with-isfield-in-matlab-8-1-r20
% %ISSUBFIELD Determine if FIELD is valid in struct S
% %   Determine if the specified FIELD or nested FIELD is present in the
% %   given structure.
% %
% %   A.b.c.d = 1;
% %   issubfield(A,"b.c.d")       % TRUE
% %   issubfield(A,"b")           % TRUE
% %   issubfield(A,"b.c.d.e")     % FALSE
% %   issubfield(A,"f")           % FALSE
% % arguments
% %      S (1,1)  = struct
% %      FIELD (1,1)  = string
% % end
% SUBFIELD = strsplit(FIELD,'.');
% if numel(SUBFIELD) == 1
%     tf = isfield(S,FIELD);
%     return;
% end
% tf = true;
% for i = 2:numel(SUBFIELD)
%     S = S.(SUBFIELD(i-1));
%     if ~isfield(S,SUBFIELD(i))
%         tf = false;
%         break;
%     end
% end


function winrej_merged = merge_trials(winrej)
    %% merges repetitive regions rejection

    % get bollean list of repetitive
    % merge
    % make it red if X, green if > 1, delete if empty;
    winrej_merged = [];
    og_winrej = winrej;
    counter = 0;

    winrej = sortrows(winrej,'ascend');

    for i = 1:size(winrej,1)
        if size(winrej,1) < i-counter
            break;
        else
        %try
            copies = winrej( winrej(:,1) == winrej(i-counter,1) & winrej(:,2) == winrej(i-counter,2),: );
        %catch
        %    break;
        %end
        if size(copies,1) > 1
            %fullcopies = rejlist(rejlist(:,1) == copies(1),:);

            new_rej_row      = zeros(1,size(winrej,2));
            new_rej_row(1,1:2) = copies(1,1:2);
            new_rej_row(1,3:5) = copies(1,3:5);                              % R for bad chans

            %for j = 1:size(copies,1)-1

            %templist(1,6:end) = copies(j,6:end) | copies(j+1,6:end);

            % --- collects aany flagged channels in this trial
            new_rej_row(6:end) = any(copies(:,6:end));

            % --- gets any of the copies that is red, if any
            anyreds = copies(copies(1:size(copies,1),3) == 1,3:5);

            % --- if any of the flagged channels are red, paint new flag red
            if size(anyreds,1) > 0
                new_rej_row(3:5) = anyreds(1,:);
            end
            %end
            %--- merges the new line in the new flags
            winrej_merged = [winrej_merged;new_rej_row];

            % --- adds number of flagged copies to counter
            counter = counter + size(copies,1)-1;
            winrej(winrej(:,1) == copies(1),:) = [];
        else
            winrej_merged = [winrej_merged;copies];
        end
        end
    end


function g = detect_flatline(g,max_flatline_duration,max_allowed_jitter)
   % modified from cleanline plugin
   % Copyright (C) Christian Kothe, SCCN, 2012, ckothe@ucsd.edu

   EEG = g.EEG;
   if nargin < 2
       max_flatline_duration = 5;
       max_allowed_jitter = 0.1;
   end
   for c = 1:EEG.nbchan
       zero_intervals = reshape(find(diff([false abs(diff(EEG.data(c,:)))<(max_allowed_jitter) false])),2,[])';
       if max(zero_intervals(:,2) - zero_intervals(:,1)) > max_flatline_duration*EEG.srate
           g.eloc_file(c).badchan = 1;
       end
   end
