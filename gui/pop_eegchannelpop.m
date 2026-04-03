function [EEG,comrej] = pop_eegchannelpop(EEG,icacomp,chancomps,varargin)

comrej = '';

%chancomps = [87 : 128];

%options(1) = window
%options(2) = stds
%options(3) = 

if nargin < 4
    options = {2 8 30 2 chancomps 'sum'};
else
    %magical function makes array out of strings of commas and numbers
    options = [varargin{:}];
    %options = sscanf(options_string, '%g,', [3, inf]).';
    if size(options,2) > 3

        % --- get given channels or components
        chancomps2 = options(5);
        chancomps2 = chancomps2{:};
        % --- if is empty, get all components/channels
        if ~isempty(chancomps2)
            chancomps = chancomps2;
        end
    end
end

% --- collect data from ica or eeg
if icacomp == 0
    data = EEG.icaact;
else
    data = EEG.data;
end

% --- assuming data is epoched
winrej = zeros(size(data,1),size(data,3));

absurd_periods = [];

finalData = [];

type = [options(6)];
type = type{:};

options = options(1:5);
options = [options{:}];

for i = chancomps
    %for j=1:size(data,3)
        %tempdata = reshape(data(i,:,j),1,[]);
        tempData = data(i,:);
        
        %movmean, movstd, movesum, 
        switch type
            case 'sum'
                sumData = movsum(tempData,options(1)); %make window variable depending on the epoch? Something between 2 and 10
            case 'mean'
                sumData = movmean(tempData,options(1)); %make window variable depending on the epoch? Something between 2 and 10
            case 'avg'
                sumData = movmean(tempData,options(1)); %make window variable depending on the epoch? Something between 2 and 10
            case 'med'
                sumData = movmedian(tempData,options(1)); %make window variable depending on the epoch? Something between 2 and 10
            case 'std'
                sumData = movstd(tempData,options(1)); %make window variable depending on the epoch? Something between 2 and 10
            case 'var'
                sumData = movvar(tempData,options(1)); %make window variable depending on the epoch? Something between 2 and 10
            case 'mad'
                sumData = movmad(tempData,options(1)); %make window variable depending on the epoch? Something between 2 and 10
        end

        % -- doubledip: finding accelaration of data?
        sumData2 = movsum(sumData,options(1));

        stdData = std(sumData,0,"all");
        %stdData = var(sumData,0,"all");
        %stdData = mad(sumData,0,"all");
        % --- plots for debugging
        %figure; pl = plot(sumData); 

        % --- get the id of the epochs 
        absurd_times = sumData > options(2)*stdData;
        
        absurd_periods = find(absurd_times); %maybe square .^2 sum data, make std 
        %[ipt,res] = findchangepts(tempdata,"Statistic",'std',"MaxNumChanges",2); %,"MinThreshold",options(2),"MinDistance",options(3));
        
        %--- bug fix: adding 1 complete integer crashed the code if the
        %last point of the data was also a problem. 0.9999 is a temp fix.
        absurd_epochs = floor(0.999999999+absurd_periods/EEG.pnts); % all epochs ids with abnormal values
        
        unique_abs_epoch = unique(absurd_epochs); % all unique epochs with abnormal values
        
        %seq_values = diff(absurd_periods)==1
        
        %absurd_periods(~seq_values)

        % if there are any absurd epochs
        if ~isempty(absurd_periods) %&& size(ipt,1) < 2            

            spiked = []; % empty array for spiked epochs

            for e = unique_abs_epoch % for all identified spiked epochs
                
                intervalA = (e*EEG.pnts);

                intervalB = intervalA-EEG.pnts+1;
                A = sum(absurd_times(intervalB:intervalA));
                if A > 0
                    new_times = find(absurd_times(intervalB:intervalA));
                end
                seq_values = diff(new_times)==1;
                
                seq_values_sum = sum(seq_values);

                intervals = sum(find(diff(seq_values) == -1));
                
%                 for loop = 1:size(intervals,2)+1
%                     if loop > 2
% 
%                     end
%                     spike_length = sum( seq_values( loop:intervals(loop)));
% 
%                 end

%                 if size(seq_values,2) < options(3)
%                     winrej(i,e) = 1;
%                 end
                spikes = find(absurd_epochs == e); % get ids of location of identified abnormalities
                
                max_var_window = options(3); % number df allowed identified abnormalities
                
                size_spikes = size(spikes,2); % 
                
                %if size(spikes,2) < max_var_window && intervals < 2
                if seq_values_sum < max_var_window && intervals < options(4)
                    spiked = [spiked,e];
                
                end
            end
            if ~isempty(spiked)
                winrej(i,spiked) = 1;
            end
        end
    %end
end

if icacomp == 0
    EEG.reject.icarejchanpops = winrej;
else
    EEG.reject.rejchanpops = winrej;
end

end