function EEG = pop_inverse_rejection(EEG)

EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);

EEG.reject.rejglobal = ~EEG.reject.rejglobal;

EEG = pop_rejepoch( EEG, [],0);



