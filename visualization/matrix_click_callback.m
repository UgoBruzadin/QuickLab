function matrix_click_callback(src, event, g)
    % Get the click coordinates
    clickPoint = get(gca, 'CurrentPoint');
    clickX = round(clickPoint(1, 1));
    clickY = round(clickPoint(1, 2));

    % Ensure the coordinates are within the matrix bounds
    clickX = max(1, min(clickX, size(src.CData, 2)));
    clickY = max(1, min(clickY, size(src.CData, 1)));

    % Check if there's a highlighted epoch near the clicked time
    plot_matrix = src.CData;
    highlighted_epochs = find(plot_matrix(1, :) ~= -10); % Find all highlighted epochs

    % Find the closest highlighted epoch to the clicked time
    [~, closest_epoch_idx] = min(abs(highlighted_epochs - clickX));
    closest_epoch = highlighted_epochs(closest_epoch_idx);

    % Calculate the time to move to
    %if ~isempty(closest_epoch)
    %    time = (closest_epoch - 1) * g.EEG.pnts / size(src.CData, 2); % Calculate the time based on the closest highlighted epoch
    %else
    time = (clickX - 1) * g.EEG.trials / size(src.CData, 2); % Calculate the time based on the click
    %end

    % Call draw_data with the clicked time
    %time = (clickX - 1) * g.EEG.pnts / size(src.CData, 2); % Calculate the time based on the click
    draw_data([], [], [], 10, time, []);
