%function [varargout] = quick_colormode(mode)
%QuickLabDefs;
try
    mode = COLOR_MODE;
catch
    mode = 'Default';
end

%         %Defining color pallete
%         MAINBLUE = [.66 .76 1]; %GUI background, buttons
%         MAINLIGHTBLUE = [.93 .96 1]; %secondary backgrounds
%         MAINWHITE = [1 1 1]; %all figure backgrounds are white
%         
%         MAINFONT = [0 0 0]; %All fonts are black
%         MAINFONT2 = [0 0 0.4]; %Some fonts are dark blue
%         
%         GOODSELECTION = [0.5 1 0.5]; %
%         BADSELECTION = [1 .5 .5]; % 
%         SPECIALSELECTION = [1 1 0]; % yellow
%         
%         MAINLINES = [0 0 0.2]; % darkblue plot lines
%         SELECTEDLINES = [1 0 0];

switch mode
    case 'Default'
        
        % icadefs changed
        BACKCOLOR           = [.93 .96 1];    % EEGLAB Background figure color
        BACKEEGLABCOLOR     = [.66 .76 1];    % EEGLAB main window background
        GUIBUTTONCOLOR      = BACKEEGLABCOLOR;% Buttons colors in figures
        GUIPOPBUTTONCOLOR   = BACKCOLOR;      % Buttons colors in GUI windows
        GUIBACKCOLOR        = BACKEEGLABCOLOR;% EEGLAB GUI background color <---------
        GUITEXTCOLOR        = [0 0 0.4];      % GUI foreground color for text
        PLUGINMENUCOLOR     = [.5 0 .5];      % plugin menu color
        
        % backgrounds
        DEFAULT_FIG_COLOR = [0.93 .96 1]; % blue interpolation backgroun
        DEFAULT_FIG_COLOR2 = [1 .5 .5]; % red rejecting background
        DEFAULT_PLOT_BACKGROUND = [1 1 1]; % white background for plots

        % buttons
        BUTTON_COLOR = BACKEEGLABCOLOR;
        DEFAULT_ON_COLOR = [0.5 1 0.5]; % green color
        DEFAULT_ON_COLOR = BUTTON_COLOR;
        DEFAULT_OFF_COLOR = [1 .5 .5]; % red color
        DEFAULT_SPECIAL_COLOR = [1 1 0];
        DEFAULT_SPECIAL_TEXT = [0 0 0];

        %text and axes
        DEFAULT_AXIS_COLOR = 'k';         % X-axis, Y-axis Color, text Color
        DEFAULT_TRIAL_DIVISION = 'b--';
        DEFAULT_PLOT_LINES = [0 0 .4]; %darkblue
        DEFAULT_PLOT_SELECTED = [1 0 0]; %red
        DEFAULT_X_AXIS = [];
        DEFAULT_Y_AXIS = [];
        DEFAULT_FONT_COLOR = [0 0 0];

        DEFAULT_PLOT_TEXT = [0 0 0];
        DEFAULT_PLOT_INTERP = [.7 1 .9];
        DEFAULT_PLOT_REJ = [1 .8 .8];

    case 'DarkMode'
        
        % icadefs changed
        BACKCOLOR           = [0.1 0.1 0.2];    % EEGLAB Background figure color
        BACKEEGLABCOLOR     = [0.2 0.2 0.6];    % EEGLAB main window background
        GUIBUTTONCOLOR      = BACKEEGLABCOLOR;% Buttons colors in figures
        GUIPOPBUTTONCOLOR   = BACKCOLOR;      % Buttons colors in GUI windows
        GUIBACKCOLOR        = BACKEEGLABCOLOR;% EEGLAB GUI background color <---------
        GUITEXTCOLOR        = [1 1 1];      % GUI foreground color for text
        PLUGINMENUCOLOR     = [.5 0 .5];      % plugin menu color

        % backgrounds
        DEFAULT_FIG_COLOR = [0.1 0.1 0.2]; % blue interpolation background
        DEFAULT_FIG_COLOR2 = [0.4 0.1 0.2]; % red rejecting background
        DEFAULT_PLOT_BACKGROUND = [0.2 0.2 0.6];
        
        % Buttons
        BUTTON_COLOR = [0.2 0.2 0.6];
        DEFAULT_ON_COLOR = [0.2 .6 0.2]; % green color
        DEFAULT_OFF_COLOR = [.6 0.2 0.2]; % red color
        DEFAULT_SPECIAL_COLOR = [1 1 0];
        DEFAULT_SPECIAL_TEXT = [0 0 0];

        %text and axes
        DEFAULT_AXIS_COLOR = [.92 .90 .71];         % X-axis, Y-axis Color, text Color
        DEFAULT_PLOT_COLOR = { [1 1 1], [1 1 1]};
        DEFAULT_TRIAL_DIVISION = 'y--';
        DEFAULT_X_AXIS = [];
        DEFAULT_Y_AXIS = [];
        DEFAULT_FONT_COLOR = [1 1 1];

        DEFAULT_PLOT_BACKGROUND = [0.1 0.1 0.2];
        DEFAULT_PLOT_INTERP = [17 58 27]/256;
        DEFAULT_PLOT_REJ = [69 12 15]/256;
        
        DEFAULT_PLOT_TEXT = [1 1 1];
        DEFAULT_PLOT_LINES = [.92 .90 .71]; %great yellow! % [.9 .9 .7]; %dark yellow [.82 .79 .95]; %nice blue
        DEFAULT_PLOT_LINES = [.66 .76 1];
        %DEFAULT_PLOT_LINES = [.6 .2 1];
        %DEFAULT_PLOT_LINES = [0 .7 0];
        DEFAULT_EVENT_LINES = [.92 .75 .77]; %great yellow!
        DEFAULT_PLOT_SELECTED = [1 .2 .3]; %red

        BACKGROUNDCOLOR = [0.1 0.1 0.2];

end
