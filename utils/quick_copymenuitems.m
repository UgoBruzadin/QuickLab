
eeglab = findobj('tag','EEGLAB');

for i = length(eeglab.Children):-1:1
    if sum(strcmp(eeglab.Children(i).Type,'uimenu'))
        copyobj(eeglab.Children(i),findobj('tag','eegplot_w3'),'legacy');
    end
end