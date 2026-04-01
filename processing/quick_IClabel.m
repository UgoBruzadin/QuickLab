function [EEG,com] = quick_IClabel(EEG,minfreq,maxfreq,type,df,newcommand,fig_opts,display)
% [EEG,com] = quick_IClabel(EEG,minfreq,maxfreq,type) 
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

QuickLabDefs;

if nargin < 8
    display = 1;
end

if nargin < 7
    fig_opts = {};
end
if nargin < 6  || isempty(newcommand)
    newcommand = [];
end
if nargin < 5 || isempty(df)
    df = 0;
end

if nargin < 4 || isempty(type)
    type = 'default';
end
if nargin < 3 || isempty(maxfreq)
    maxfreq = 55;
end
if nargin < 2 || isempty(minfreq)
    minfreq = 2;
end

if isempty(EEG.data)
    [EEG,com] = pop_loadset;
    EEG = eegh(com, EEG);
end
if isempty(EEG.icawinv)
    fprintf('Error: must first run an ICA or PCA \r');
    return;
end
if isempty(EEG.icaact)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
end

[EEG,com] = pop_par_iclabel(EEG,type);
EEG = eegh(com, EEG);
if df
    [EEG,com] = quick_dipfit(EEG);
    EEG = eegh(com, EEG);
end

% newcommand = [ 'tmpstatus = get( findobj(''parent'', gcf, ''Style'', ''checkbox''), ''value'');'...
%     'A = fliplr([tmpstatus{:}]);'...
%     'EEG.reject.gcompreject( num2str(chanorcomp(1)):num2str(chanorcomp(end))) = A;']

if display == 1
    [EEG,com] = pop_viewprops_adv(EEG, 0, newcommand, 1:size(EEG.icawinv,2), {'freqrange',[minfreq maxfreq]},{},fig_opts);
end

EEG = eegh(com, EEG);


end