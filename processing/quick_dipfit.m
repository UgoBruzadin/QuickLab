function [EEG,com] = quick_dipfit(EEG,comps,dipoles)
% [EEG,com] = quick_PCA(EEG,comps,dipoles) 
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

if nargin < 3 || isempty(dipoles)
    dipoles = 1; 
end

if nargin < 2 || isempty(comps)
    comps = []; 
end

%EEG = pop_par_dipfit_settings(EEG);
% EEG = pop_par_dipfit_settings( EEG, 'hdmfile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\standard_mri.mat','chanfile','C:\\MATLAB\\GitHub\\eeglab-eeglab2019\\plugins\\dipfit3.3\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213] ,'chansel',[1:size(EEG.icawinv,1)] );
% EEG = pop_par_multifit(EEG, [1:size(EEG.icawinv,2)] ,'threshold',100,'plotopt',{'normlen' 'on'});
% acronym  = 'DF'; 
[EEG,com] = pop_dipfit_settings( EEG, 'hdmfile','C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\standard_vol.mat','coordformat','MNI','mrifile','C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\standard_mri.mat','chanfile','C:\\GitHub\\eeglab\\plugins\\dipfit3.7\\standard_BEM\\elec\\standard_1005.elc','coord_transform',[0.05476 -17.3653 -8.1318 0.075502 0.0031836 -1.5696 11.7138 12.7933 12.213] ,'chansel',[1:EEG.nbchan] );
EEG = eegh(com, EEG);
[EEG,com] = pop_par_multifit2(EEG, comps ,'threshold',100,'plotopt',{'normlen','on'},'dipoles',dipoles);
EEG = eegh(com, EEG);
end