function draw_matrix(g)
% --- get EEG data
EEG = g.EEG;
First = 0;

% --- make axis for plot
ax_pic_topo = findobj('tag','topo');
ax_pic = findobj('tag','matrix');

if ~isempty(ax_pic_topo)
    delete(ax_pic_topo);
    %First = 1;
end

if isempty(ax_pic)
    First = 1;
    ax_pic = axes('Parent', gcf, 'position',g.matrixpos,'units','normalized','tag','matrix_axis','XTickLabel',{[]},'YTickLabel',{[]},'Color',[.93 .96 1]);
else
    set(ax_pic,"Visible",'on')
end
hold on; % not sure if necessary

% --- making empty matrix
%if EEG.plotchannels
if EEG.trials ~= 1
   plot_matrix = zeros(g.chans,EEG.trials);
   splits = EEG.pnts;
else
   plot_matrix = zeros(g.chans,100);
   splits = floor(EEG.pnts/100);
end

plot_matrix = plot_matrix - 10;

if ~isempty(g.winrej)
    winrej = g.winrej;

    %% paints red trials
    % --- check for red trials
    rej_winrej = winrej(winrej(:,3) == 1,:);

    if ~isempty(rej_winrej)
        rej_epoch_id = floor(1+rej_winrej(:,1)/splits); % gets all red epochs

        % --- paint rej epochs
        plot_matrix(:,rej_epoch_id) = 20; % populates them with a color red

        nb_rejs = size(rej_epoch_id,1);
        rej_parts = rej_winrej(:,6:end);

        if ~isempty(rej_epoch_id)
            for i=1:nb_rejs
                if nb_rejs > 1
                    rej_parts2 = find(rej_parts(i,:));
                else
                    rej_parts2 = find(rej_parts);
                end
                % --- paint specific trial-epoch regions
                rej_parts2 = abs((rej_parts2 -1) - g.chans); % flips the array
                %% Paints matrix
                plot_matrix(rej_parts2,rej_epoch_id(i)) = 1; % paints the matrix!
            end
        end

    end
    %% paints green trials
    % --- check for green trials
    int_winrej = winrej(winrej(:,4) == 1,:);

    if ~isempty(int_winrej)
        int_epoch_id = floor(1+int_winrej(:,1)/splits); % gets all green epochs

        % --- paint int epochs
        plot_matrix(:,int_epoch_id) = 10; % populates them with a color green

        nb_ints = size(int_epoch_id,1);
        int_parts = int_winrej(:,6:end);

        if ~isempty(int_epoch_id)
            for i=1:nb_ints
                if nb_ints > 1
                    int_parts2 = find(int_parts(i,:));
                else
                    int_parts2 = find(int_parts);
                end
                int_parts2 = abs((int_parts2 - 1) - g.chans); % flips the array
                % --- paint specific trial-epoch regions
                %% Paints matrix
                plot_matrix(int_parts2,int_epoch_id(i)) = 1;
            end
        end

    end
end
%% Paints bad channels
if ~isfield(g.eloc_file, 'badchan')
    for ii=1:length(g.eloc_file)
        g.eloc_file(ii).badchan = 0;
    end
end
bad_chans_flip = find([g.eloc_file.badchan]); % gets bad channels/components

if ~isempty(bad_chans_flip)
    bad_chans = [abs((bad_chans_flip - 1) - g.chans )]; % flips the array
    plot_matrix(bad_chans,:) = 3; % Paints matrix
end
    %% Adjust matrix if fewer epochs or channels than pixels
    [nRows, nCols] = size(plot_matrix);
    if nCols < EEG.trials
        plot_matrix = [plot_matrix, -10 * ones(nRows, EEG.trials - nCols)];
    end
    if nRows < g.chans
        plot_matrix = [plot_matrix; -10 * ones(g.chans - nRows, size(plot_matrix, 2))];
    end

    %% plots image
    if First
        matrix_pic = imagesc(ax_pic,plot_matrix);
        set(matrix_pic,'tag','matrix');
        hold on;
        axis(ax_pic,'tight');
        xticks(ax_pic,EEG.trials);
        yticks(ax_pic,size(g.eloc_file,2));
        %% defining colors and axis
        % 1st,     2nd,   3rd,   4th,   5th
        % darkblue, black, yellow, green, red
        % background, ticks, channels, greens, reds
        mymap = [.5 .5 .8; 0 0 0; 1 1 0; 0 1 0; 1 0 0]; % color map of matrix
        colormap(mymap) % applies new colors
        try clim('manual'); catch, caxis('manual'); end% makes color limits manual,
        try clim(ax_pic,[-10,20]); catch, caxis(ax_pic,[-10,20]); end% fixes color patterns so that alwasy plots the same colors

        % makes axis tight to bounderies, filling full space
        %lim = clim %for debugging

        %title = get(findobj(gcf,'tag','headmap'),'String');
        set(findobj(gcf,'tag','headmap'),'String','Current Data Marks');
    else
        set(findobj(gcf,'tag','headmap'),'String','Current Data Marks');
        matrix_pic = findobj('tag','matrix');
        set(matrix_pic,'CData',plot_matrix);
        mymap = [.5 .5 .8; 0 0 0; 1 1 0; 0 1 0; 1 0 0]; % color map of matrix
        colormap(mymap)

        % Add callback for clicking on the matrix
        set(matrix_pic, 'ButtonDownFcn', @(src, event) matrix_click_callback(src, event, g));

    end
