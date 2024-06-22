
[EEGOUT2,~] = quick_PCA(EEGOUT);

EEG.icaact = [];
EEG.icasphere = [];
EEG.icaweights = [];
EEG.icawinv = [];
%EEG.icachansind = [];
%EEG.icasplinefile = [];

EEG.icaweights = EEGOUT2.icaweights;
EEG.icasphere  = EEGOUT2.icasphere;
EEG.icawinv    = pinv(EEG.icaweights*EEG.icasphere);

%EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
chanind = [];
if isempty(chanind)
    chanind = 1:EEG.nbchan;
end
if iscell(chanind)
    datatype = {EEG.chanlocs.type};
    tmpChanInd = [];
    for iChan = 1:length(datatype)
        if ~isempty(datatype{iChan}) && ~isempty(strmatch(datatype{iChan}, chanind))
            tmpChanInd = [ tmpChanInd iChan ];
        end
    end
    chanind = tmpChanInd;
end
EEG.icachansind = chanind;

EEG = g.EEG
meanvar = sum(EEG.icawinv.^2).*sum(transpose((EEG.icaweights *  EEG.icasphere)*EEG.data(EEG.icachansind,:)).^2)/((length(EEG.icachansind)*EEG.pnts)-1);
[~, windex] = sort(meanvar);
windex = windex(end:-1:1); % order large to small
meanvar = meanvar(windex);
EEG.icaweights = EEG.icaweights(windex,:);
EEG.icawinv    = pinv( EEG.icaweights *  EEG.icasphere );
if ~isempty(EEG.icaact)
    EEG.icaact = EEG.icaact(windex,:,:);
end


g.EEG = EEG;