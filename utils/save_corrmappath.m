%--- this function was written by Ugo Bruzadin Nunes
%--- in June 23th 2021
%--- 

function corrmappath = save_corrmappath()

%--- save current path
currentfolder = pwd;
%--- changes to plugin folder
folder = geteeglabpath();
if isempty(folder)
    return;
end
cd(strcat(folder,'/plugins'));
quicklab = dir('QuickLab*');
cd(quicklab.name)
%cd('C:/GitHub/eeglab/plugins/QuickLab'); %NEEDS FIXING
pluginfolder = pwd;
%--- creates empty string variable corrmappath
corrmappath = '';
%--- checks to see if corrmap exists
if isfile('corrmappath.txt')
    corrmappath = readtext('corrmappath.txt');
    if iscell(corrmappath)
        corrmappath = corrmappath{:};
    end
else
    corrmappath = uigetdir(corrmappath);
    writematrix(corrmappath,'corrmappath.txt');
end

cd(pluginfolder);

end