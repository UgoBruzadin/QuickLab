function [EEG,com] = quick_PCA(EEG,IC,type,disp)
% [EEG,com] = quick_PCA(EEG,IC,type) 
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

com = '';
if isempty(EEG.data)
    [EEG,com] = pop_loadset();
    EEG = eegh(com, EEG);
    eeglab redraw
end

if nargin < 3 || isempty(type)
    type = ICATYPE;
end

if nargin < 4 || isempty(disp)
    disp = 0;
end
mybadcomps = [];
try mybadcomps = find(EEG.reject.gcompreject); catch; end   %stores the Id of the components to be rejected

if nargin < 2 || isempty(IC)
    if ~isempty(mybadcomps)
        IC = size(EEG.icawinv,2);
        IC = IC - size(mybadcomps,2);            %stores the number to be the next components analysis
        %fprintf('Rejecting selected components... \r');
        %[EEG,com] = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
        EEG = eegh(com, EEG);
    end
    [EEG,com] = pop_par_runica(EEG,'extended', EXTENDED,'icatype',type, 'verbose',VERBOSE);
    EEG = eegh(com, EEG);
else

    if ~isempty(mybadcomps)
        fprintf('Rejecting selected components... \r');
        [EEG,com] = pop_subcomp(EEG, mybadcomps, 0);       % actually removes the flagged components
        EEG = eegh(com, EEG);
    end
    if ischar(IC)
        IC = size(EEG.icaact,1)-1;
    end
    [EEG,com] = pop_par_runica(EEG,'extended', EXTENDED,'icatype',type,'pca',IC, 'verbose',VERBOSE);
    EEG = eegh(com, EEG);
end

[EEG,com] = pop_par_iclabel(EEG,ICLABELDEFS(1));

if disp
    [EEG,com] = quick_IClabel(EEG);
    %com = pop_eegplot_w2(EEG, 2, 2, 1, 1);
    EEG = eegh(com, EEG);
end

%com = sprintf('quick_PCA( %s, %s,%s,%s )', EEG,IC,type,disp);
end