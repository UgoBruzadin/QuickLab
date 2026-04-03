% [EEG,com] = quick_reref(EEG, chans) - Quickly reference the files to
%                                       given channels
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

% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function [EEG,com] = quick_reref(EEG,channels,keepref)

if isempty(EEG.data)
    EEG = pop_loadset();
    eeglab redraw
end

% collecting defaults and variables from  QuickLabDefs or given variables
QuickLabDefs; % USING OG_REF, CZ_REF, LE_REFS, KEEPREF, REFLOC for original reference location

if nargin < 3
    keepref = KEEPREF; 
end



options = struct('labels',{'Cz'},'Y',{0},'X',{0},'Z',{8.7919},'sph_theta',{0},'sph_phi',{0},'sph_radius',{0},'theta',{0},'radius',{0},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0});
%options = REFLOC; % taken from QuickLabDefs

if nargin < 2 || isempty(channels)
% EEG = pop_reref( EEG, [],'keepref','on');
    [EEG,com] = pop_reref( EEG, [], 'keepref', keepref);
else
if strcmp(channels,'AVG')
   [EEG,com] = pop_reref( EEG, [], 'keepref', keepref);
elseif strcmp(channels,'LE')
   [EEG,com] = pop_reref( EEG, LE_REFS, 'keepref', keepref);
elseif strcmp(channels,'OG')
   [EEG,com] = pop_reref( EEG, OG_REF, 'keepref', keepref);
elseif strcmp(channels,'CZ')
    options = REFLOC;
   [EEG,com] = pop_reref( EEG, OG_REF, 'keepref', keepref, 'refloc',options);
else
    %try finding channel names
    %don't reference otherwise?
    [EEG,com] = pop_reref( EEG, channels, 'keepref', keepref);
end

end