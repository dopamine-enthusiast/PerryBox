function viewLineScanImages(scans)

f = figure;
%%UI Controls

lineScanTitle = uicontrol('Style','text',...
    'units','normalized',...
    'FontSize',14,...
    'position', [.2 .9 .5 .05]);


loadbutton = uicontrol('Style', 'pushbutton',...
    'String', 'Load',...
    'Units','normalized',...
    'Position', [.85 .75 .1 .1],...
    'Callback', @load_button);

nextbutton = uicontrol('Style', 'pushbutton',...
    'String', 'Next',...
    'Units','normalized',...
    'Position', [.85 .55 .1 .1],...
    'Callback', @next_button);

prevbutton = uicontrol('Style', 'pushbutton',...
    'String', 'Prev',...
    'Units','normalized',...
    'Position', [.85 .35 .1 .1],...
    'Callback', @prev_button);

gotosweep = uicontrol('Style', 'edit', ...
    'Units','normalized',...
    'Position', [.875 .45 .05 .1],...
    'Callback', @go_to_sweep);

averageButton = uicontrol('Style', 'pushbutton',...
    'String', 'Average',...
    'Units','normalized',...
    'Position', [.85 .2 .1 .1],...
    'Callback', @average_button);

sweepsButton = uicontrol('Style', 'pushbutton',...
    'String', 'Sweeps',...
    'Units','normalized',...
    'visible','off',...
    'Position', [.85 .2 .1 .1],...
    'Callback', @single_button);

nextLSbutton = uicontrol('Style', 'pushbutton',...
    'String', 'Next',...
    'Units','normalized',...
    'Position', [.5 .01 .1 .1],...
    'Callback', @next_scan_button);

prevLSbutton = uicontrol('Style', 'pushbutton',...
    'String', 'Prev',...
    'Units','normalized',...
    'Position', [.3 .01 .1 .1],...
    'Callback', @prev__scan_button);

gotoscan = uicontrol('Style', 'edit', ...
    'Units','normalized',...
    'Position', [.4 .01 .1 .1],...
    'Callback', @go_to_scan);

viewTraces = uicontrol('Style', 'pushbutton',...
    'String', 'View Traces',...
    'Units','normalized',...
    'Position', [.05 .01 .15 .1],...
    'Callback', @View_Traces);

editGreenThresh = uicontrol('Style', 'edit',...
    'String', 'View Traces',...
    'Units','normalized',...
    'Position', [.02 .7 .05 .05],...
    'string','300',...
    'Callback', @edit_Green_Thresh);

editRedThresh = uicontrol('Style', 'edit',...
    'String', 'View Traces',...
    'Units','normalized',...
    'Position', [.02 .3 .05 .05],...
    'string','300',...
    'Callback', @edit_Red_Thresh);

img = 1;
scan = 1;
average = 1;

if nargin == 1
    numSweeps = length(scans(1).green(:,1,1));
    updateImage;
end



%%UI functions
    function edit_Red_Thresh(source, callbackdata)       
       updateImage;
    end

    function edit_Green_Thresh(source, callbackdata)       
       updateImage;
    end

    function load_button(source, callbackdata)
        
        scans = loadLineScans;
        
        img = 1;
        numSweeps = length(scans(1).green(:,1,1));
        updateImage;
    end

    function next_button(source, callbackdata)
        button_state = get(source, 'Value');
        if button_state == get(source, 'Max') && img < numSweeps
            img = img + 1;
        else
            img = 1;
        end
        updateImage;
    end

    function prev_button(source, callbackdata)
        button_state = get(source, 'Value');
        if button_state == get(source, 'Max') && img > 1
            img = img - 1;
        else
            img = numSweeps;
        end
        updateImage;
    end

    function go_to_sweep(source, callbackdata)
        
        
        input = str2double(get(source,'string'));
        
        if input > numSweeps
            img = numSweeps;
        elseif input < 1
            img = 1;
        else
            img = input;
        end
        
        updateImage;
        
    end

    function average_button(source,callbackdata)
        average = 1;
        updateImage;
    end

    function single_button(source,callbackdata)
        average = 0;
        updateImage;
    end

    function go_to_scan(source,callbackdata)
       input = str2double(get(source,'string'));
        if input > length(scans)
            scan = numSwlength(scans);
        elseif input < 1
            scan = 1;
        else
            scan = input;
        end
        img = 1;
        numSweeps = length(scans(scan).green(:,1,1));
        updateImage;
    end

    function prev__scan_button(source,callbackdata)
        button_state = get(source, 'Value');
        if button_state == get(source, 'Max') && scan > 1
            scan = scan - 1;
        else
            scan = length(scans);
        end
        img = 1;
        numSweeps = length(scans(scan).green(:,1,1));
        updateImage;    
    end

    function next_scan_button(source,callbackdata)
        button_state = get(source, 'Value');
        if button_state == get(source, 'Max') && scan < length(scans)
            scan = scan + 1;
        else
            scan = 1;
        end
        img = 1;
        numSweeps = length(scans(scan).green(:,1,1));
        updateImage;
    end

    function View_Traces(source,callbackdata)
        plotLineScansGUI(scans);
    end


%% Application Functions

    function updateImage        
        switch average
            case 1
                plotAverage                
                set(gotosweep,'visible','off');
                set(nextbutton,'visible','off');
                set(prevbutton,'visible','off');    
                set(sweepsButton,'visible','on'); 
                set(averageButton,'visible','off'); 
            case 0
                plotSingle
                set(gotosweep,'visible','on');
                set(nextbutton,'visible','on');
                set(prevbutton,'visible','on'); 
                set(sweepsButton,'visible','off'); 
                set(averageButton,'visible','on'); 
        end
        set(lineScanTitle,'string',scans(scan).name);
        set(gotosweep,'string',num2str(img));
        set(gotoscan,'string',num2str(scan));
    end   
        
    function plotAverage
        ax = axes('Units','normalized',...
            'Position',[0 .5 1 .5]);
        
        greenThresh = str2num(get(editGreenThresh,'string'));        
        redThresh = str2num(get(editRedThresh,'string'));
        
        if ~isempty(scans(scan).red)
            ax1 = subplot('Position',[0.1, 0.1, 0.7, 0.4]);
            imshow(uint16(squeeze(mean(scans(scan).raw.red))'),[0 redThresh]);
            title(['Red Channel'],'fontsize',16);
            
        end
        
        if ~isempty(scans(scan).green)
            ax2 = subplot('Position',[0.1, 0.5, 0.7, 0.4]);
            imshow(uint16(squeeze(mean(scans(scan).raw.green))'),[0 greenThresh]);
            title(['Green Channel'],'fontsize',16);
        end
    end

    function plotSingle  
        greenThresh = str2num(get(editGreenThresh,'string'));        
        redThresh = str2num(get(editRedThresh,'string'));
        
        if ~isempty(scans(scan).red)
            ax1 = subplot('Position',[0.1, 0.1, 0.7, 0.4]);
            imshow(uint16(squeeze(scans(scan).raw.red(img,:,:))'),[0 redThresh]);
            title(['Red Channel ' num2str(img) '/' num2str(numSweeps)],'fontsize',16);
            
        end
        
        if ~isempty(scans(scan).green)
            ax2 = subplot('Position',[0.1, 0.5, 0.7, 0.4]);
            imshow(uint16(squeeze(scans(scan).raw.green(img,:,:))'),[0 greenThresh]);
            title(['Green Channel ' num2str(img) '/' num2str(numSweeps)],'fontsize',16);
        end                        
    end





end