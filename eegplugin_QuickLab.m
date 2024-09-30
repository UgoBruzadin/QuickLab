% eegplugin_QuickLab() - QuickLab plugin version 0.91 for EEGLAB menu.
%                        QuickLab is a compilation of modified EEGLAB functions
%                        for experienced users that wish to speed up manual
%                        process, made by Ugo Bruzadin Nunes in
%                        colaboration with the INL lab in Carbondale, IL.
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
function vers = eegplugin_QuickLab(fig, try_strings, catch_strings)

vers = 0.91;
% --- QuickLab sumermenu placeholder
supermenu = uimenu(fig, 'label', 'QuickLab');

% --- Call QuickLab DEFS

QuickLabDefs;

uimenu( supermenu, 'label', 'Data Scroll Pro (channel)', 'callback', ...
    [try_strings.no_check '[EEG,LASTCOM] = pop_eegplot_adv(EEG, 1, 2, 1, 1);' ...
    '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' ...
    'ALLCOM{end+1} = LASTCOM;' catch_strings.store_and_hist]);

uimenu( supermenu, 'label', 'Data Scroll Pro (component)', 'callback', ...
    [try_strings.no_check '[EEG,LASTCOM] = pop_eegplot_adv(EEG, 2, 2, 1, 1);' ...
    '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);' ...
    'ALLCOM{end+1} = LASTCOM;' catch_strings.store_and_hist]);

uimenu( supermenu, 'label', 'Edit QuickLab Defaults', 'callback', ...
    ['open QuickLabDefs;']);


% --- first submenu: Quick plots
plotmenu = uimenu (supermenu, 'label', 'Quick Plots');

ogplotmenu = findobj(fig.Children,'Text','Plot');

uimenu( ogplotmenu, 'label', 'Data Scroll Pro', 'callback', ...
    ['[EEG,LASTCOM] = pop_eegplot_adv(EEG, 1, 2, 1, 1);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick IClabel & Viewprops+ plot', 'callback', ...
    ['[EEG,LASTCOM] = quick_IClabel(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick Plot Channel Spectra - AVG ref', 'callback', ...
    ['[~, LASTCOM] = quick_spectra(EEG,40,2,''AVG'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

othermenu = uimenu (plotmenu, 'label', 'Other');

uimenu( othermenu, 'label', 'Quick Plot Channel Spectra default', 'callback', ...
    ['[~, LASTCOM] = quick_spectra(EEG,40,2);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( othermenu, 'label', 'Quick Plot Channel Spectra - LE ref', 'callback', ...
    ['[~, LASTCOM] = quick_spectra(EEG,40,2,''LE'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( othermenu, 'label', 'Quick ERP Viewprops+ plot', 'callback', ...
    ['LASTCOM = pop_viewprops_erp(EEG,0,1:size(EEG.icawinv,2),{''freqrange'',[2 55]});[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( othermenu, 'label', 'Quick IClabel, DIPFIT & Viewprops+ plot', 'callback', ...
    ['[EEG,com] = quick_IClabel(EEG,2,55,''default'',1)',...
    '[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( othermenu, 'label', 'Quick Plot Channel Spectra 2 to 22hz', 'callback', ...
    ['[EEG, LASTCOM] = quick_spectra(EEG,22,2);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( othermenu, 'label', 'Quick Plot Channel Spectra 18 to 55hz', 'callback', ...
    ['[EEG, LASTCOM] = quick_spectra(EEG,55,18);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( othermenu, 'label', 'Plot Last Files Data Differences', 'callback', ...
    ['plotDifference(ALLEEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);
    
printmenu = uimenu (plotmenu, 'label', 'Quick Print'); 

uimenu( printmenu, 'label', 'Print Components', 'callback', ...
    ['print_ICA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( printmenu, 'label', 'Print FFT', 'callback', ...
    ['print_FFT(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

% plot fft difference!

% --- second submenu: Quick ICA/PCAs
pcamenu = uimenu (supermenu, 'label', 'Quick PCA');

dipfitmenu = uimenu (pcamenu, 'label', 'Quick PCA and DipFit');

uimenu( dipfitmenu, 'label', 'Quick ICA & DipFit', 'callback', ...
    ['[EEG,LASTCOM] = quick_PCA(EEG);EEG = quick_dipfit(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( dipfitmenu, 'label', 'Quick N-1 PCA & DipFit', 'callback', ...
    ['[EEG,LASTCOM] = quick_PCA(EEG, strcat(size(EEG.icaact,1)-1));EEG = quick_dipfit(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

for d=6:2:50
uimenu( dipfitmenu, 'label', strcat('PCA ',num2str(d),' & DipFit'), 'callback', ...
    ['[EEG,LASTCOM] = quick_PCA(EEG,' num2str(d) ');EEG = quick_dipfit(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

uimenu( pcamenu, 'label', 'ICA no plot', 'callback', ...
    ['[EEG,LASTCOM] = quick_PCA(EEG,[],[],0);EEG = quick_eegsave(EEG,''ICA'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( pcamenu, 'label', 'ICA', 'callback', ...
    ['[EEG,LASTCOM] = quick_PCA(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( pcamenu, 'label', 'N-1 PCA', 'callback', ...
    ['[EEG,LASTCOM] = quick_PCA(EEG,strcat(size(EEG.icaact,1)-1));[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

for i=4:35
uimenu( pcamenu, 'label', strcat('PCA ',num2str(i)), 'callback', ...
    ['[EEG,LASTCOM] = quick_PCA(EEG,' num2str(i) ',[],0);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end
for i=36:2:50
uimenu( pcamenu, 'label', strcat('PCA ',num2str(i)), 'callback', ...
    ['[EEG,LASTCOM] = quick_PCA(EEG,' num2str(i) ',[],0);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

secondpcamenu = uimenu (pcamenu, 'label', 'MORE PCAs');
for g=51:75
    uimenu( secondpcamenu, 'label', strcat('PCA ',num2str(g)), 'callback', ...
        ['[EEG,LASTCOM] = quick_PCA(EEG,' num2str(g) ',[],0);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end
% 

% --- third submenu: Quick BSS

bssmenu = uimenu (supermenu, 'label', 'BSS Menu');

uimenu (bssmenu, 'label', 'Quick BSS 2 epochs', 'callback', ...
    ['[EEG,LASTCOM] = quick_bss(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu (bssmenu, 'label', 'Quick BSS full file', 'callback', ...
    ['[EEG,LASTCOM] = quick_bss2(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu (bssmenu, 'label', 'Exp PAR BSS full file', 'callback', ...
    ['[EEG,LASTCOM] = quick_par_bss2(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

% --- third submenu: Quick channel edits
channelmenu = uimenu (supermenu, 'label', 'Quick Channel Edit');

uimenu( channelmenu, 'label', 'Quick Re-reference AVG', 'callback', ...
    ['[EEG,LASTCOM] = quick_reref(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

% uimenu( channelmenu, 'label', 'Quick Reduce to 98/99 Channels (NIDA 5)', 'callback', ...
%     ['[EEG,LASTCOM] = quick_HM99(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 
% uimenu( channelmenu, 'label', 'Quick Reduce to 93/94 Channels (NIDA 5)', 'callback', ...
%     ['[EEG,LASTCOM] = quick_HM94(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

filtermenu = uimenu (channelmenu, 'label', 'Quick Filter');

 for a=0.5:0.5:22
 uimenu( filtermenu, 'label', strcat('Quick High Pass ',num2str(a)), 'callback', ...
     ['EEG = quick_lowpass(EEG,' num2str(a) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
 end

for b=14:40
uimenu( filtermenu, 'label', strcat('Quick Low Pass ',num2str(b)), 'callback', ...
    ['EEG = quick_lowpass(EEG,' num2str(b) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

% --- 4th submenu: Quick epoch edits
epochsmenu = uimenu (supermenu, 'label', 'Quick Epoch edits');

for s = 1:5
uimenu( epochsmenu, 'label', strcat('Epoch every_', num2str(s), '_seconds'), 'callback', ...
    ['EEG =  quick_epoch(EEG,',num2str(s), ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
end

uimenu( epochsmenu, 'label', 'UN-Epoch (Back to Continuous)', 'callback', ...
    ['[EEG,com] = quick_unepoch(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

% --- 5th submenu: QuickCorrmap
corrmenu = uimenu (supermenu, 'label', 'Quick CorrMap');

uimenu( corrmenu, 'label', 'Create/Change QuickCorrMaps folder', 'callback', ...
    ['save_corrmappath;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( corrmenu, 'label', 'Quick Save Selected CorrMaps', 'callback', ...
    ['save_corrmaps(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( corrmenu, 'label', 'Quick Run CorrMap', 'callback', ...
    ['EEG = quick_corrmap(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw']);

% --- 7th submenu: Run a pipeline

parmenu = uimenu( supermenu, 'label', 'Quick Parallel Processes');

uimenu( parmenu, 'label', 'Parallel DipFit 1 Dipole', 'callback', ...
    ['[EEG] = quick_dipfit(EEG);[ALLEEG EEG CURRENTSET] =  eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;']);

uimenu( parmenu, 'label', 'Parallel DipFit 2 Dipoles', 'callback', ...
    ['[EEG] = quick_dipfit(EEG,[],2); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;']);

%%%% START MENU ADD-ONS

%quick_eeghack();
