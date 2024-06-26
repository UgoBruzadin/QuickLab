% eegplugin_QuickLab() - QuickLab plugin version 0.9 for EEGLAB menu.
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

vers = 0.9;
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

% uimenu( plotmenu, 'label', 'Adv. Data Editor', 'callback', ...
%     ['com = pop_eegplot_adv(EEG, 1, 2, 1, 1);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

ogplotmenu = findobj(fig.Children,'Text','Plot');

uimenu( ogplotmenu, 'label', 'Data Scroll Pro', 'callback', ...
    ['[EEG,LASTCOM] = pop_eegplot_adv(EEG, 1, 2, 1, 1);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

% uimenu( plotmenu, 'label', 'OLD Channel Scroll++ for Interpolation', 'callback', ...
%     ['com = pop_eegplot_w2old(EEG, 1, 2, 1, 1);;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);
% 
% uimenu( plotmenu, 'label', 'OLD Component Scroll++ for Interpolation', 'callback', ...
%     ['com = pop_eegplot_w2old(EEG, 2, 2, 1, 1);;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

% 
% uimenu( plotmenu, 'label', 'Frequency Scroll++ for Interpolation', 'callback', ...
%     ['com = pop_eegplot_w2(EEG, 1, 2, 1, 3);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick IClabel & Viewprops+ plot', 'callback', ...
    ['[EEG,LASTCOM] = quick_IClabel(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( plotmenu, 'label', 'Quick Plot Channel Spectra - AVG ref', 'callback', ...
    ['[~, LASTCOM] = quick_spectra(EEG,40,2,''AVG'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

othermenu = uimenu (plotmenu, 'label', 'Other');

% uimenu( othermenu, 'label', 'Select Channels Scroll++ for Interpolation', 'callback', ...
%     ['com = pop_eegplot_w2_list(EEG, 1, 2, 1, 1);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

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

% uimenu( printmenu, 'label', 'Print Marked Components', 'callback', ...
%     ['print_RejComponents(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( printmenu, 'label', 'Print FFT', 'callback', ...
    ['print_FFT(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

% plot fft difference!

% uimenu(supermenu, 'label','Quick DotLoc','callback',...
%     ['[EEG,com] = quick_dotloc(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

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
% try
%     if gpuDeviceCount
%         cudamenu = uimenu (supermenu, 'label', 'Quick CUDAICA');
%         
%         uimenu( cudamenu, 'label', 'ICA', 'callback', ...
%             ['[EEG,com] = quick_PCA(EEG,[],''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
%         
%         uimenu( cudamenu, 'label', 'N-1 PCA', 'callback', ...
%             ['[EEG,com] = quick_PCA(EEG,strcat(size(EEG.icaact,1)-1)),''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
%         
%         for i=4:35
%             uimenu( cudamenu, 'label', strcat('PCA ',num2str(i)), 'callback', ...
%                 ['[EEG,com] = quick_PCA(EEG,' num2str(i) ',''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
%         end
%         for i=36:2:50
%             uimenu( cudamenu, 'label', strcat('PCA ',num2str(i)), 'callback', ...
%                 ['[EEG,com] = quick_PCA(EEG,' num2str(i) ',''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
%         end
%         
%         secondcudamenu = uimenu (cudamenu, 'label', 'MORE PCAs');
%         for g=51:75
%             uimenu( secondcudamenu, 'label', strcat('PCA ',num2str(g)), 'callback', ...
%                 ['[EEG,com] = quick_PCA(EEG,' num2str(g) ',''cudaica'');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
%         end
%     end
% catch
% end
% --- third submenu: Quick BSS

bssmenu = uimenu (supermenu, 'label', 'BSS Menu');

uimenu (bssmenu, 'label', 'Quick BSS 2 epochs', 'callback', ...
    ['[EEG,LASTCOM] = quick_bss(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu (bssmenu, 'label', 'Quick BSS full file', 'callback', ...
    ['[EEG,LASTCOM] = quick_bss2(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu (bssmenu, 'label', 'Exp PAR BSS full file', 'callback', ...
    ['[EEG,LASTCOM] = quick_par_bss2(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 
% uimenu (bssmenu, 'label', 'BSS+', 'callback', ...
%     ['[EEG com]  = pop_autobssemgQL(EEG);EEG = eegh(com, EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

% --- third submenu: Quick channel edits
channelmenu = uimenu (supermenu, 'label', 'Quick Channel Edit');

uimenu( channelmenu, 'label', 'Quick Re-reference AVG', 'callback', ...
    ['[EEG,LASTCOM] = quick_reref(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

% uimenu( channelmenu, 'label', 'Quick Re-reference Linked Mastoids', 'callback', ...
%     ['[EEG,com] = quick_reref(EEG,' LE_REFS  ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 
% uimenu( channelmenu, 'label', 'Quick Re-reference Cz', 'callback', ...
%     ['[EEG,com] = quick_reref(EEG,' CZ_REF  ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

% - not working yet
% uimenu( channelmenu, 'label', 'Quick Re-reference Linked-Mastoids (129)', 'callback', ...
%     ['[EEG,com] = pop_fastrerefavg(EEG,[55,100]);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Reduce to 98/99 Channels (NIDA 5)', 'callback', ...
    ['[EEG,LASTCOM] = quick_HM99(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

uimenu( channelmenu, 'label', 'Quick Reduce to 93/94 Channels (NIDA 5)', 'callback', ...
    ['[EEG,LASTCOM] = quick_HM94(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 
% interpmenu = uimenu( channelmenu, 'label', 'Quick channel interpolation');
% 
% for j=2:7
% uimenu( interpmenu, 'label', strcat('By ',num2str(j),' SDV'), 'callback', ...
%     ['EEG = pop_fastchannelinterp(EEG,' num2str(j) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% end
% 
% uimenu( channelmenu, 'label', 'Quick Interpolate Channels by Components', 'callback', ...
%     ['[EEG] = channelIntByComps(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

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
% 
% uimenu( epochsmenu, 'label', 'Quick Epoch 0.400 2.448 (DotLoc)', 'callback', ...
%     ['[EEG,com] = quick_epoch(EEG,0.400,2.448);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 
% uimenu( epochsmenu, 'label', 'Quick Epoch 0.600 2.648 (DotLoc)', 'callback', ...
%     ['[EEG,com] = quick_epoch(EEG,0.600,2.648);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 
% uimenu( epochsmenu, 'label', 'Quick Epoch 0.700 2.748 (DotLoc)', 'callback', ...
%     ['[EEG,com] = quick_epoch(EEG,0.700,2.748);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 
% uimenu( epochsmenu, 'label', 'Quick Epoch -1 3.096 (DotLoc)', 'callback', ...
%     ['[EEG,com] = quick_epoch(EEG,-1,3.096);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

% Deprecated!
% rejmenu = uimenu( epochsmenu, 'label', 'Epoch Rejection by probability');
% 
% for k=2:7
% uimenu( rejmenu, 'label', strcat('By ',num2str(k),' SDV'), 'callback', ...
%     ['EEG = quick_trialrejprob(EEG,' num2str(k) ');[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% end

% Deprecated with the addition of TBT
% % --- 4th submenu: Quick PCA edits
% pcasmenu = uimenu (supermenu, 'label', 'Quick PCA cleaning');
% 
% uimenu( pcasmenu, 'label', 'Interpolate Marked Components for Epochs > 3 sdvs', 'callback', ...
%     ['EEG =  pop_epochintbycompsbyvar(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);
% 
% uimenu( pcasmenu, 'label', 'Interpolate Channels by Marked Components if 1 Channel only is above 2 sdv', 'callback', ...
%     ['[EEG] = pop_epochandchannelintbycompsbyvar(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw;']);

% --- 5th submenu: QuickCorrmap
corrmenu = uimenu (supermenu, 'label', 'Quick CorrMap');

uimenu( corrmenu, 'label', 'Create/Change QuickCorrMaps folder', 'callback', ...
    ['save_corrmappath;[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( corrmenu, 'label', 'Quick Save Selected CorrMaps', 'callback', ...
    ['save_corrmaps(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);']);

uimenu( corrmenu, 'label', 'Quick Run CorrMap', 'callback', ...
    ['EEG = quick_corrmap(EEG);[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);eeglab redraw']);

% 
% % --- 6th submenu: Run a pipeline
% 
% uimenu( supermenu, 'label', 'Quick Pipeline', 'callback', ...
%     ['[UGO, EEG] = pop_runapipeline();eeglab redraw;']);

% --- 7th submenu: Run a pipeline

parmenu = uimenu( supermenu, 'label', 'Quick Parallel Processes');

uimenu( parmenu, 'label', 'Parallel DipFit 1 Dipole', 'callback', ...
    ['[EEG] = quick_dipfit(EEG);[ALLEEG EEG CURRENTSET] =  eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;']);

uimenu( parmenu, 'label', 'Parallel DipFit 2 Dipoles', 'callback', ...
    ['[EEG] = quick_dipfit(EEG,[],2); [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); eeglab redraw;']);
% try
%     if isstruct(EEG)
%          h = findobj(gcf, 'tag', 'win1');
%          set(h, 'String', 'Test');
%     end
% catch
% end
%%%% START MENU ADD-ONS

%quick_eeghack();

%%% Create Commands for buttons

%%% Modify ICA numbers, Filename, and add a folder line, and
%%% dataset names!

% changename = ['h = findobj(gcf, ''tag'', ''win1''); set(h, ''string'', strcat(''FILENAME:'',EEG.filename));'];
% 
% changeICA = ['h = findobj(gcf, ''tag'', ''val11''); if ~isempty(EEG.icaact), set(h, ''string'', num2str(size(EEG.icaact,1))), end;'];
% 
% %%changeICA = ['h = findobj(gcf, ''tag'', ''val11''); if ~isempty(EEG.icaact), set(h, ''string'', ''TEST''), end;'];
% 
% loaddircommand = [changename, changeICA, 'try, findex = [1];cd(EEG.filepath);filecount = [1];files = dir(''.set'');findex = find(strcmp({files.name}, EEG.filename));files = dir(''*.set'');set(findobj(''tag'',''LoadFileList2''),''string'',{files(1:end).name},''value'',find(strcmp({files.name}, EEG.filename))); catch; end;'];
% 
% savecommand = ['[EEG] = pop_saveset(EEG, ''filename'', [strcat( EEG.filename(1:end-4),get(findobj(''Tag'',''SAVETEXT2''),''String''),''.set'')],''filepath'',EEG.filepath);'...
%      '[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);' loaddircommand 'eeglab redraw;']; %save set ADDED BY UGO
% %%% move up
% loadprecommand = ['findex = find(strcmp({files.name}, EEG.filename));if findex > 1, findex = findex - 1, EEG = pop_loadset( files(findex).name, pwd); eeglab redraw, end;'];
% %%% move down
% loadpostcommand = ['findex = find(strcmp({files.name}, EEG.filename));if findex < length(files), findex = findex + 1, EEG = pop_loadset( files(findex).name, pwd); eeglab redraw, end;'];
% %%% loadfile
% loadfilecommand = ['EEG = pop_loadset( files(cell2mat(get(findobj(''Tag'',''LoadFileList2''),''Value''))).name, pwd);eeglab redraw;'];
% 
% %%% Create Buttons and Menu addons
% savetitle = uicontrol(gcf,'Style', 'text', 'Units','Normalized','Tag', 'SAVETITLE2', 'String', 'Add to filename',...
%     'Position', [0.05 0.05 0.08 0.05]);
% 
% savetext = uicontrol(gcf, 'Style', 'edit', 'Units','Normalized','Tag', 'SAVETEXT2', 'String', 'New',...
%     'Position', [0.13 0.05 0.07 0.05]);
% 
% savebutton = uicontrol(gcf, 'Style', 'pushbutton','Units','Normalized','Tag', 'SAVEASBUTTON2', 'String', 'Save(+)', 'callback', savecommand ,...
%     'Position', [0.23 0.05 0.07 0.05]);
% 
% loaddir = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized','Tag', 'LoadDir2', 'String', 'Load Folder', 'callback', loaddircommand ,...
%     'Position', [0.31 0.05 0.08 0.05]);
% 
% loadup = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized','Tag', 'LoadUp', 'String', 'Up', 'callback', loadprecommand ,...
%     'Position', [0.40 0.05 0.03 0.05]);
% 
% loaddown = uicontrol(gcf, 'Style', 'pushbutton','Units','Normalized','Tag', 'LoadDown', 'String', 'Down', 'callback', loadpostcommand ,...
%     'Position', [0.43 0.05 0.045 0.05]);
% 
% loadfile = uicontrol(gcf, 'Style', 'popupmenu','Units','Normalized','Tag', 'LoadFileList2', 'String', '', 'callback', loadfilecommand,...
%     'Position', [0.48 0.05 0.45 0.05]);
% 
% %%% Change buttons and text color backgrounds
% 
% h = findobj(gcf, 'style', 'pushbutton');
% set(h, 'backgroundcolor', [0.9 0.9 0.9]);
% 
% h = findobj(gcf, 'tag', 'SAVETITLE2');
% set(h, 'backgroundcolor', [.66 .76 1]);
% 

