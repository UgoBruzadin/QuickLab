% eeg_eegrej_adv() - reject porition of continuous data in an EEGLAB
%                dataset
%
% Usage:
%   >> EEGOUT = eeg_eegrej_adv( EEGIN, regions, chanorcomp, tmprej);
%
% Inputs:
%   INEEG      - input dataset
%   regions    - array of regions to suppress. number x [beg end]  of
%                regions. 'beg' and 'end' are expressed in term of points
%                in the input dataset. Size of the array is
%                number x 2 of regions.
%
% Outputs:
%   INEEG      - output dataset with updated data, events latencies and
%                additional boundary events.
%
% Author: Arnaud Delorme, CNL / Salk Institute, 8 August 2002
% Modified by Ugo Bruzadin Nunes
% See also: eeglab(), eegplot(), pop_rejepoch()

% Copyright (C) 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
% Copyright (C) 2021 Ugo Bruzadin Nunes
%
% This file is part of EEGLAB, see http://www.eeglab.org
% for the documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.

function [EEGOUT, com] = eeg_eegrej_adv( EEG, regions, chanorcomp, tmprej)

if nargin < 2
    help eeg_eegrej;
    return;
end
if nargin < 3
    chanorcomp = 1;
end
if nargin < 4
    tmprej = 0;
end

QuickLabDefs;

setname = EEG.setname;
com = '';

%% ---- this code has been depricated, but kept in for compatibility sake
if ~isfield(EEG,'myVariables')
    EEG.myVariables = {0 0 '' 0};
end
if size(EEG.myVariables,2) > 1
    plotdiff = EEG.myVariables{2};
else
    plotdiff = 0;
end
if tmprej
    chansorcomps4removal = tmprej;
elseif size(EEG.myVariables,2) > 2
    chansorcomps4removal = EEG.myVariables{3};
else
    chansorcomps4removal = '';
end
if size(EEG.myVariables,2) > 3
    useText = EEG.myVariables{4};
else
    useText = 0;
end

if ~useText
    list_of_chans_or_comps = '';
else
    list_of_chans_or_comps = EEG.myVariables{1};
end

% --- end of compatibility region

%% --- store variables in backup
if chanorcomp == 1
    EEG.chanrej = regions;
    EEG.reject.rejmanual = regions;
    EEG.mybadchan = tmprej;
else
    EEG.comprej = regions;
    EEG.reject.icarejmanual = regions;
    EEG.mybadcomp = tmprej;
    EEG.gcompreject = tmprej;
end

%% --- STORE CURRENT MARKS TO FILE
if SAVEBACKUP
    [~, fname, ~] = fileparts(EEG.filename);
    [EEG] = pop_saveset(EEG, 'filename', [fname 's.set'], 'filepath', EEG.filepath);
end
EEG.myVariables = {};

%% --- start organizing variables
if ~isempty(regions)
if size(regions,2) > 2
    regions = sortrows(regions,3);
else
    regions = sortrows(regions,1);
end
end

if ~isfield(EEG,'suffix')
    EEG.suffix = '';
end

% make sure regions are unique!
regions = unique(regions,'rows');

regions_for_interp = regions;
regions_for_rej = [];

%% DISTRIBUTES REGIONS into reds (for removal) and greens (for interpolation)
if ~isempty(regions) && size(regions,2) >= 4
    % Red regions: col 3 > col 4 and col 4 ~= 1 (rejection)
    is_red   = regions(:,3) > regions(:,4) & regions(:,4) ~= 1;
    % White regions: col 3 == 1 and col 4 == 1 (no action)
    is_white = regions(:,3) == 1 & regions(:,4) == 1;
    % Green regions: everything else (interpolation)
    is_green = ~is_red & ~is_white;

    regions_for_rej    = regions(is_red, :);
    regions_for_interp = regions(is_green, :);
end

%% --- Distributes channels or components for removal and channels for interpolation
chancounter = 0;
if ~isempty(regions_for_interp) && size(regions_for_interp,2) >= 6
    for i=1:size(regions_for_interp,1)                           % for the size of regions selected
        % --- finds the number of all channels rejected in this region
        channels = find(regions_for_interp(i-chancounter,6:end));
        % --- checks if the chans/comps are being remoed entirely
        rejboll = ismember(channels,chansorcomps4removal);
        % --- if they are, removes them from the channels[] array
        if any(rejboll)
            channels = channels(~rejboll);          %new bug fixed: removes channels/comps selected for full interpolation #was doubledipping!!!
        end
        if ~isempty(channels)
            if ~isempty(list_of_chans_or_comps)
                list_of_chans_or_comps = strcat(list_of_chans_or_comps,';');
            end
            list_of_chans_or_comps = strcat(list_of_chans_or_comps,num2str(channels));
        else
            regions_for_interp(i-chancounter,:) = [];
            chancounter = chancounter + 1;
        end
    end
    
    if size(regions_for_interp,2) > 2, regions_for_interp = regions_for_interp(:, 1:2); end

end

%Get the split divisions. This was originally made so that one could type
%the channels on a textbox, which was deprecated, but still installed in case
%needs to be used later.
divisors = strfind(list_of_chans_or_comps,';');
if isempty(divisors)
    divisors = strfind(list_of_chans_or_comps,',');
end

%% Partial Channel or Component Interpolations

% --- fully interpolate channels or remove components selected (Ugo)
EEGmod = EEG;
EEGcumulative = EEG;

if ~isempty(list_of_chans_or_comps)
    % --- if only one channel or component was gifven %MODIFIED BY UGO NUNES JUL/2021
    if isempty(divisors)
        % get channel or component
        compOrChan = str2num(list_of_chans_or_comps);
        suf = '';
        % interpolate component or channel for the selected intervals
        if chanorcomp == 1
            EEGinterp = pop_interp(EEGcumulative, [compOrChan], 'spherical');
            for i=1:size(regions_for_interp,1)

                fprintf(strcat('Interpolating channels(s) ', num2str(compOrChan),' for the period...',num2str(regions_for_interp(i,1)),' to...',num2str(regions_for_interp(i,2))), '\r' );
                EEGmod.data(compOrChan,regions_for_interp(i,1):regions_for_interp(i,2)) = EEGinterp.data(compOrChan,regions_for_interp(i,1):regions_for_interp(i,2));
                
            end
            EEGmod.suffix = strcat(EEGmod.suffix,strcat('pCI',suf));
            EEGcumulative = EEGmod;
        else
            EEGinterp = pop_subcomp(EEGcumulative, [compOrChan]);
            for i=1:size(regions_for_interp,1)
                fprintf(strcat('Interpolating components(s) ', num2str(compOrChan),' for the period...',num2str(regions_for_interp(i,1)),' to...',num2str(regions_for_interp(i,2))), '\r' );
                EEGmod.data(:,regions_for_interp(i,1):regions_for_interp(i,2)) = EEGinterp.data(:,regions_for_interp(i,1):regions_for_interp(i,2));
                EEGmod.icaact = EEGinterp.icaact;
            end
            EEGmod.suffix = strcat(EEGmod.suffix,strcat('pPI',suf));
            EEGcumulative = EEGmod;
        end
        
    else % --- else, runs through every region for every component given, assuming the same length
        % adds a 0 to the beggining of the divisions array to facilitate script
        divisors = cat(2,[0],divisors);
        % this is total number of channels selected
        numOfInts = length(divisors);
        suf = '';
        % loops the number of channels/comps given and interpolates them
        for j = 1:numOfInts
            % if it's not the final number, collects the channels/components t
            % be interpolated for each selected period of time
            % if it is the final number, does the same for the last numbers
            if j ~= numOfInts
                compOrChan = str2num(list_of_chans_or_comps(divisors(j)+1:divisors(j+1)-1));
            else
                compOrChan = str2num(list_of_chans_or_comps(divisors(j)+1:end));
            end
            
            if chanorcomp == 1
                fprintf(strcat('Interpolating channels(s)...', num2str(compOrChan),' for the period...',num2str(regions_for_interp(j,1)),' to...',num2str(regions_for_interp(j,2))), '\r' );
                EEGinterp = pop_interp(EEGcumulative, [compOrChan], 'spherical');
                EEGmod.data(compOrChan,regions_for_interp(j,1):regions_for_interp(j,2)) = EEGinterp.data(compOrChan,regions_for_interp(j,1):regions_for_interp(j,2));
            else
                fprintf(strcat('Interpolating components(s)...', num2str(compOrChan),' for the period...',num2str(regions_for_interp(j,1)),' to...',num2str(regions_for_interp(j,2))), '\r' );
                EEGinterp = pop_subcomp(EEGcumulative,[compOrChan]);
                EEGmod.data(:,regions_for_interp(j,1):regions_for_interp(j,2)) = EEGinterp.data(:,regions_for_interp(j,1):regions_for_interp(j,2));
                EEGmod.icaact = EEGinterp.icaact;
            end

            EEGcumulative = EEGmod;
        end
            if chanorcomp == 1
                EEGmod.suffix = strcat(EEGmod.suffix,strcat('pCI',suf));
            else
                EEGmod.suffix = strcat(EEGmod.suffix,strcat('pPI',suf));
            end
    end
end % end partial interpolations

%% Full channel interpolations or component removal
EEGmod2 = EEGcumulative;

if ~isempty(chansorcomps4removal)
    % editing suffix 
    chansorcomps4removalstr = chansorcomps4removal;
    try chansorcomps4removalstr = replace(chansorcomps4removalstr,divisors,'-'); catch; end
    suf = replace(num2str(chansorcomps4removalstr),' ','-');
        
    if isstring(chansorcomps4removal)
        chansorcomps4removal = str2num(chansorcomps4removal);
    end
    if chanorcomp == 1
        fprintf(strcat('Interpolating channels(s) _', num2str(chansorcomps4removal),'\r' ));
        EEGmod2 = pop_interp(EEGcumulative, [chansorcomps4removal], 'spherical');
        EEGmod2.suffix = strcat(EEGmod2.suffix,strcat('CI',suf));
    else
        fprintf(strcat('Removing components(s) _', num2str(chansorcomps4removal),'\r' ));
        EEGmod2 = pop_subcomp(EEGcumulative, [chansorcomps4removal]);
        EEGmod2.suffix = strcat( EEGmod2.suffix,strcat( 'PJ',num2str( length(chansorcomps4removal))));
    end
end


%% --- For plotting the data difference, mostly a debugging tool

if plotdiff == 1
    EEGdiff = EEG.data - EEGmod2.data;
    eegplot_w2( EEGdiff, 'srate', EEG.srate, 'title', [ 'DIFFERENCE PRE AND POST CHANNEL/COMPONENT INTERPOLATION -- eegplot_w(): ' EEG.setname], ...
        'limits', [EEG.xmin EEG.xmax]*1000 );
end

%final EEG!
EEGOUT = EEGmod2;

%% --- Clears rejection variables from EEG variable
if chanorcomp == 1
    if isfield(EEGOUT,'chanrej')
        EEGOUT.chanrej = [];
    end
    if isfield(EEGOUT,'mybadchan')
        EEGOUT.mybadchan = [];
    end
else
    if isfield(EEGOUT,'comprej')
        EEGOUT.comprej = [];
    end
    if isfield(EEGOUT,'mybadcomp')
        EEGOUT.mybadcomp = [];
    end
end


%% --- Runs data rejection in case of rejection selected.
if ~isempty(regions_for_rej)
    if size(EEG.data,3) > 1
        rejected_epochs = floor(regions_for_rej(:,1)/EEG.pnts)' + 1;
        [EEGOUT,~] = pop_rejepoch( EEGOUT, rejected_epochs,0);
    else
        [EEGOUT,~] = eeg_eegrej( EEGOUT, regions_for_rej(:,1:2) );
    end
    EEGOUT.suffix = strcat(EEGOUT.suffix, 'TJ', num2str(size(regions_for_rej,1)));
end

try EEGOUT.suffix = regexprep(EEGOUT.suffix, '[;\s-]+', ''); catch; end

%% --- Save file
if isfield(EEGOUT,'save')
    EEGOUT.setname = setname;

    if EEGOUT.save == 1
        EEGOUT.save = 0;

        ss = EEGOUT.suffix;
        EEGOUT.suffix = [];
        [~, fname, ~] = fileparts(EEGOUT.filename);
        EEGOUT = pop_saveset(EEGOUT, 'filename', [fname ss '.set'], 'filepath', EEGOUT.filepath);
        if isfield(EEGOUT,'ICA')
            if EEGOUT.ICA == 1
            [EEGOUT,~] = quick_PCA(EEGOUT,[],[],0);
            EEGOUT.ICA = 0;
            EEGOUT.suffix = [];
            end
        end
    end
end
com = sprintf('EEGOUT = eeg_eegrej_adv( EEG, %s );', vararg2str({ regions, chanorcomp, tmprej }));
global ALLCOM
ALLCOM{end+1} = com;



