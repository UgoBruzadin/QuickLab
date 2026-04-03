function mouse_scroll_wheel(~,eventdata,fig,varargin)
try
modifiers = get(fig,'currentModifier');
wheel_up=eventdata.VerticalScrollCount < 0;
if wheel_up
    if ismember('shift',modifiers)
        draw_data([],[],fig,1);
    elseif ismember('control',modifiers)
        change_eeg_window_length([],[],fig,2);
    elseif ismember('alt',modifiers)
        change_scale([],[],fig,1);
    else
        draw_data([],[],fig,2);
    end
else
    if ismember('shift',modifiers)
        draw_data([],[],fig,4);
    elseif ismember('control',modifiers)
        change_eeg_window_length([],[],fig,1);
    elseif ismember('alt',modifiers)
        change_scale([],[],fig,2);
    else
        draw_data([],[],fig,3);
    end
end
if nargin > 3
    %mouse_motion([],[],fig,varargin{:});
end
catch return; end
