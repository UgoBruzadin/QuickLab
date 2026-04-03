function [EEG,com] = quick_dotloc(EEG)

%mybadcomps = find(EEG.reject.gcompreject);   %stores the Id of the components to be rejected

[EEG,com] = quick_HM94(EEG);

[EEG,com] = quick_epoch(EEG,0.600,2.648);

%[EEG,com] = quick_bss2(EEG);

[EEG,com] = quick_PCA(EEG,[],[],0);

[EEG] = pop_saveset(EEG, 'filename', [strcat( EEG.filename(1:end-4),'Hm92Ep6ICA','.set')],'filepath',EEG.filepath);

%eeglab redraw
end