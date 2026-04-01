function [EEG,com] = quick_HM94(EEG)
com = [];
if isempty(EEG.data)
    [EEG,com] = pop_loadset();
    eeglab redraw
end

EEG.icaact = []; EEG.icaweights = []; EEG.icasphere= []; EEG.icachansind = [];

% 
% if isempty(EEG.icaact)
%     EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
% end
chans = [1 8 14 17 21 25 32 38 43 44 48 49 56 63 64 68 69 73 74 81 82 88 89 94 95 99 107 113 114 119 120 121 125 126 127 128];
try [EEG,com] = pop_select( EEG,'nochannel',[1 8 14 17 21 25 32 38 43 44 48 49 56 63 64 68 69 73 74 81 82 88 89 94 95 99 107 113 114 119 120 121 125 126 127 128]);
catch
for i = chans
    try pop_select( EEG,'nochannel',[i]);
    catch; end
end
end
for a=1:EEG.nbchan
    if isempty(strfind(EEG.chanlocs(1,a).labels,'Cz'))
        try EEG.chanlocs(1,a).labels = strcat(EEG.chanlocs(1,a).labels,'_','N',num2str(a)); catch; end
    end
end

end