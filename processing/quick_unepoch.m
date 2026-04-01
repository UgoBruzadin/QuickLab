function EEG = quick_unepoch(EEG)

EEG = pop_selectevent( EEG, 'omittype',{'X'},'deleteevents','on','deleteepochs','off','invertepochs','off');

if EEG.trials > 1

EEG.data = EEG.data(:,:);
EEG.xmax = EEG.trials*EEG.pnts;
if ~isempty(EEG.icaact)
    EEG.icaact = EEG.icaact(:,:);
    %EEG.icaact = reshape(EEG.icaact , EEG.nbchan, EEG.trials*EEG.pnts);
end

EEG.pnts = size(EEG.data,2);
EEG.epoch = [];
EEG.urevent = EEG.event;
EEG.times = 1:EEG.trials*EEG.pnts;
EEG.trials = 1;

else
    fprintf('Nothing done. File is already in continuous shape \r');
end

end