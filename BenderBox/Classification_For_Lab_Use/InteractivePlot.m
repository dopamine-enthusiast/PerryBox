function InteractivePlot(Cell)






nextbutton = uicontrol('Style', 'pushbutton', 'String', 'Next',...
    'Units','normalized',...
    'Position', [.85 .75 .1 .1],...
    'Callback', @next_button);

prevbutton = uicontrol('Style', 'pushbutton', 'String', 'Prev',...
    'Units','normalized',...
    'Position', [.85 .65 .1 .1],...
    'Callback', @prev_button);


gotosweep = uicontrol('Style', 'edit', ...
    'Units','normalized',...
    'Position', [.85 .25 .1 .1],...
    'Callback', @go_to_sweep);


figure; hold on
subplot(2, 7, 1:6)
plot(Cell.time(:, 1), Cell.data(:, 1));
ylim([-150, 50])
xlabel('sec'); ylabel('mV')
title('Sweep 0')
subplot(2, 7, 8:13)
plot(Cell.time(:, 1), Cell.comm(:, 1));
xlabel('sec'); ylabel('pA')

i = 1;

    function next_button(source, callbackdata)
        
        button_state = get(source, 'Value');
        if button_state == get(source, 'Max')
            i = i + 1;
        end
        
        subplot(2, 7, 1:6)
        plot(Cell.time(:, i), Cell.data(:, i));
        
        str = sprintf('Sweep %d; %d min %d sec', i-1, round(Cell.swp_time(i)/60), mod(Cell.swp_time(i), 60));
        
        
        title(str)
        ylim([-150, 50])
        xlabel('sec'); ylabel('mV')
        subplot(2, 7, 8:13)
        plot(Cell.time(:, i), Cell.comm(:, i));
        xlabel('sec'); ylabel('pA')
    end

    function prev_button(source, callbackdata)
        button_state = get(source, 'Value');
        if button_state == get(source, 'Max') && i > 1
            i = i - 1;
        end
        
        subplot(2, 7, 1:6)
        plot(Cell.time(:, i), Cell.data(:, i));
        ylim([-150, 50])
        xlabel('sec'); ylabel('mV')
     
        str = sprintf('Sweep %d; %d min %d sec', i-1, round(Cell.swp_time(i)/60), mod(Cell.swp_time(i), 60));

        str = sprintf('Sweep %d; %d min %d sec', i-1, round(Cell.swp_time(i)/60), mod(Cell.swp_time(i), 60));

        title(str)
        
        subplot(2, 7, 8:13)
        plot(Cell.time(:, i), Cell.comm(:, i));
        xlabel('sec'); ylabel('pA')
        
        
    end

    function go_to_sweep(source, callbackdata)
        input = str2double(get(source,'string'));
        i = input+1;
        subplot(2, 7, 1:6)
        plot(Cell.time(:, i), Cell.data(:, i));
        ylim([-150, 50])
        xlabel('sec'); ylabel('mV')
        str = sprintf('Sweep %d; %d min %d sec', i-1, round(Cell.swp_time(i)/60), mod(Cell.swp_time(i), 60));
        title(str)
        
        subplot(2, 7, 8:13)
        plot(Cell.time(:, i), Cell.comm(:, i));
        xlabel('sec'); ylabel('pA')
    end


end


