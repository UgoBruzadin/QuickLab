
%reject data, run_ICA, get OG data and inverse ICA


if size(EEG.data,3) > 1
    rejected_epochs = [];
    for i=1:size(regions_for_rej,1)
        rejected_epochs = [rejected_epochs, floor(regions_for_rej(i,1)/EEG.pnts)+1];
    end
    [EEGOUT,~] = pop_rejepoch( EEG, rejected_epochs,0);
    %EEGOUT.suffix = strcat(EEGOUT.suffix,strcat('TJ',num2str(size(regions_for_rej,1))));
else
    [EEGOUT,~] = eeg_eegrej( EEG, regions_for_rej(:,1:2) );
    %EEGOUT.suffix = strcat(EEG.suffix,strcat('TJ',num2str(size(regions_for_rej,1))));
end

[EEGOUT2,~] = quick_PCA(EEGOUT);

EEG.icaact = [];
EEG.icasphere = [];
EEG.icaweights = [];
EEG.icawinv = [];
EEG.icachansind = [];
EEG.icasplinefile = [];

EEG.icaweights = EEGOUT2.icaweights;
EEG.icasphere  = EEGOUT2.icasphere;
EEG.icawinv    = pinv(EEG.icaweights*EEG.icasphere);
EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);

