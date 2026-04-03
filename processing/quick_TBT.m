function EEG = quick_TBT(EEG,plotchannels,method,options,nbadchans,pctbadtrial)
% This function was adapted from TBT plugin by Mattan S. Ben-Shachar
% Copyright (C) 2017 Mattan S. Ben-Shachar
% Copyright (C) 2024 Ugo Bruzadin Nunes ugobruzadin@gmail.com

% Usage: 
%           >> quick_TBT(EEG, 
% plotchannels: 0 or 1. 1 means channel analysis, 0 means component              
% method: 1 to 8, 1 = eegthresh, 2 = rejtrend, 3 = joinprob, 4 = rejkurt, 5
% = rejspec, 6 = eegmaxmin, 7 = flatline, 8 channelpop
% options: string of options given to each method
% nbadchans: % of bad channels necessary to make a trial bad for rejection
% pctbadtrials: number of trials necessary to make a channel bad for interpolation
%
% option for each method: 
%   1: ['-500 , 500 ,' num2str(EEG.xmin) ' , ' num2str(EEG.xmax)]
%   2: [num2str(EEG.pnts) ' , 0.5 , 0.3']
%   3: '3 , 3'
%   4: '3 , 3'
%   5: ['''method'' , ''FFT'' , ''threshold'' , [-70 , 15] ,''freqlimits'' , [20 , 55]']
%   6: ['[1:' num2str(EEG.nbchan) '],[' num2str([EEG.xmin EEG.xmax]*1000) '],100,' num2str([EEG.xmax - EEG.xmin]*1000) ',1,0']
%   7: ['5, 20']
%   8: ['{5, 8, 100, 2, [],''mean''}']

% storing old data
EEGpre = EEG;
if isfield(EEG,'winrej')
    winrejPRE = EEG.winrej;
else
    EEG.winrej = [];
    winrejPRE = [];
end
if isfield(EEG,'badchans')
    EEG.badchans = zeros(size(EEG.data,1),1);
else
    
end

if plotchannels ~= 1
    icacomp = '0';
    chancomps = '1:size(EEG.icaact,1)';
    ica = 'ica';
else
    icacomp = '1';
    chancomps = '1:EEG.nbchan';
    ica = '';
end

% method = findobj(gcf,'tag', 'ALLmethods');
% options = findobj(gcf,'tag', 'ALLoptions');
% nbadchans = findobj(gcf,'tag', 'TBTnchans');
% pctbadtrial = findobj(gcf,'tag', 'TBT%');

switch method

    case 7
        %options;
        EEG = detect_flatline(EEG);
        %update_trial_rejections(EEG);
        %return;
    case 1
        comrej  = ['EEG = pop_eegthresh(EEG, ' icacomp ',' chancomps ',' options ', 1, 0);'];
        chosen_func    = 'rejthreshE';
    case 2
        comrej  = ['[EEG, comrej] = pop_rejtrend(EEG, ' icacomp ', ' chancomps ',' options ', 1, 0,0);'];
        chosen_func    = 'rejconstE';
    case 3
        comrej  = ['[EEG, ~,~,~,comrej] = pop_jointprob(EEG, ' icacomp ', ' chancomps ',' options ', 1, 0, 0);'];
        chosen_func    = 'rejjpE';
    case 4
        comrej  = ['[EEG, ~,~,~,comrej] = pop_rejkurt(EEG, ' icacomp ', ' chancomps ',' options ', 1, 0, 0);'];
        chosen_func    = 'rejkurtE';
    case 5
        comrej  = ['[EEG, ~, comrej]    = pop_rejspec(EEG, ' icacomp ',' options , ',''elecrange'',' chancomps ');'];
        chosen_func    = 'rejfreqE';
    case 6
        comrej  = ['[EEG, comrej]    = pop_eegmaxmin(EEG,' options ');'];
        chosen_func    = 'rejmaxminE';
        ica = ''; %rejmaxminE doesn't have options for ICA
    case 8
        comrej = ['[EEG,comrej] = pop_eegchannelpop(EEG,' icacomp ',' chancomps ',' options ');'];
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

%% Find bad trials and channels

% Find channels that have been marked as bad in more than X% of trials:
channel_index = sum(winrej,2)/EEG.trials >= pctbadtrial/100;   % boolean list

%if ~isfield(EEG.chanlocs, 'badchan')
    for ii=1:length(EEG.chanlocs)
        EEG.chanlocs(ii).badchan = 0;
    end
%end

% Collects rejected trials BUG
if sum(channel_index)
    badchannels = find(channel_index);
    for ind = badchannels'
        EEG.badchans(ind) = 1; % marks channels as bad
        % removes these channels from trial rejections!
        winrej(ind,:) = 0;
    end
end

% Find trial with more than X bad channels:
trials_ind  = 1:EEG.trials;
bTrial_ind  = sum(winrej,1) >= nbadchans;     % boolean list
bTrial_num  = trials_ind(bTrial_ind);	% trial list
nbadtrial   = length(bTrial_num);       % count bad trials

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
    mark((sum(mark(:,5:end),2) < 1),:) = [];                    % cleaner code compared with the for loop

    EEG.winrej = [EEG.winrej;mark];
    %end

    % --- Updating and organizing winrej
    EEG.winrej = unique(EEG.winrej,'rows');
    EEG.winrej = sortrows(EEG.winrej,'ascend');
    EEG.winrej = merge_trials(EEG.winrej);
    % --- storing new winrej
    %EEG.winrejNEW = EEG.winrej;

end

function EEG = detect_flatline(EEG,max_flatline_duration,max_allowed_jitter)
   % modified from cleanline plugin
   % Copyright (C) Christian Kothe, SCCN, 2012, ckothe@ucsd.edu

   if nargin < 2
       max_flatline_duration = 5;
       max_allowed_jitter = 0.1;
   end

   for c = 1:EEG.nbchan
       zero_intervals = reshape(find(diff([false abs(diff(EEG.data(c,:)))<(max_allowed_jitter) false])),2,[])';
       if max(zero_intervals(:,2) - zero_intervals(:,1)) > max_flatline_duration*EEG.srate
           EEG.badchans = 1;
       end
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

draw_data([],[],gcf,0,[],g);
draw_matrix(g);

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