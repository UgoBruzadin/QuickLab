% quick_epoch() Calling this function will run specified epoching defaults
%               QuickLab is a compilation of modified EEGLAB functions
%               for experienced users that wish to speed up manual
%               process, made by Ugo Bruzadin Nunes in
%               colaboration with the INL lab in Carbondale, IL.
%
% Author: Ugo Bruzadin Nunes
%
% Copyright (C) 2021 Ugo Bruzadin Nunes
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software

function [EEG,com] = quick_epoch(EEG,time1,time2,eventname)

QuickLabDefs;

if isempty(EEG.data)
    [EEG,com] = pop_loadset();
    EEG = eegh(com, EEG);
    eeglab redraw
end

if nargin < 2
    time1 = EPOCHLENGTH;
end

if nargin < 3
    [EEG] = eeg_regepochs(EEG,'recurrence',time1);
    %EEG = eegh(com, EEG);
else
    if nargin < 4
        eventname = EEG.event(2).type;
    end
    if isstring(eventname)
        [EEG,com] = pop_epoch( EEG, { eventname }, [time1 time2], 'epochinfo', 'yes');
    else
        [EEG,com] = pop_epoch( EEG,  cellstr(eventname) , [time1 time2], 'epochinfo', 'yes');
    end
        EEG.icaact = []; EEG.icawinv = []; EEG.icasphere = []; EEG.icaweights = []; EEG.icachansind = [];
    
end
    
%EEG = pop_par_epoch( EEG, { UniqueEventNames }, [time1 time2], 'newname', 'Neuroscan EEG data epochs', 'epochinfo', 'yes');

end