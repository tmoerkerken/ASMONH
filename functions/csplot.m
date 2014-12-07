%CSPLOT plots cross-sectional slices of the ONH
%
%   SYNOPSIS:
%       CSPLOT(SUBJECT,MEASUREMENT,EDITMODE,INTENSITY,CSECTION)
%           SUBJECT     format: integer
%           MEASUREMENT format: integer
%           EDITMODE    format: 0 or 1
%                       default: 0
%           INTENSITY   format: double
%                       default: 0.1
%           CSECTION    format: integer
%                       info: one cross-section will be
%                       shown on all measurements
%                       special: when set to 0
%                       all sections will be compared

function csplot(subject, measurement, editmode, intensity, csection)
%%% Set options
% En-face plot
EnFaceMode = false;

% Change line style in plots
LineWidth = 1;
cstring = 'rkbmc';

% Export plot to file
ExportMode = true;
keyboard

if (exist('csection')==0) 
    output_file = ['../Report/img/results/s' num2str(subject) 'meas' num2str(measurement) '.eps'];
else
    output_file = ['../Report/img/results/s' num2str(subject) 'cs' num2str(csection) '.eps'];
end

% Change default axes fonts.
set(0,'DefaultAxesFontName', 'Georgia')
set(0,'DefaultAxesFontSize', 7)

% Change default text fonts.
set(0,'DefaultTextFontname', 'Georgia')
set(0,'DefaultTextFontSize', 7)


%%% Plotting
if (exist('intensity')==1)
    int = intensity;
else
    int = 0.1;
end

plotshift = 0;
path = ['subjects\Subject ' num2str(subject) '\segment\'];
if (exist('csection')==0)
    filename = [num2str(int,'%10.3f\n') '_Subject ' num2str(subject) '_' num2str(measurement) '_cs.mat'];
    load([path filename]);
    
    figure,
    if (EnFaceMode == true)
        plotshift = 2;
        subplot(3,2,[1, 2]),imshow(log(phi_enface),[-12 -7]),
        if (str2num(strtrim(filename(end-20:end-20+1))) >= 10)
            title(['En-face image sub. ' num2str(str2num(strtrim(filename(end-20:end-20+1))),'%02.0f\n') ' meas. ' filename(18)]),
        else
            title(['En-face image ' num2str(str2num(strtrim(filename(end-20:end-20+1))),'%02.0f\n') ' meas ' filename(17)]),
        end
        
        hold on,...
            
    %    plot(pos(:,1),pos(:,2),'cx','LineWidth',2),
    rectangle('position',[xcenter-Rfit,ycenter-Rfit,Rfit*2,Rfit*2],...
        'curvature',[1,1],'linestyle','--','edgecolor','y');plot(xcenter,ycenter,'kx');
    plot(1:size(zny,2),ycenter*ones(1,length(zny)),cstring(1),'LineWidth',LineWidth);
    plot(xcenter*ones(1,size(zny,1)),1:size(zny,1),cstring(2),'LineWidth',LineWidth);
    plot(s15(1,:),r15,cstring(3),'LineWidth',LineWidth);
    plot(s45(1,:),r45,cstring(4),'LineWidth',LineWidth);
    hold off
    end
    
    
    name = {'3' '6' '1.5' '4.5'};
    X = {x3 x6 x15 x45};
    Y = {s3 s6 zn15 zn45};
    T = {t3 t6 t15 t45};
    BG = {bg3 bg6 bg15 bg45};
    plotorder = [1 2 3 4];
    
    
    
    for j = 1:length(plotorder)
        i = plotorder(j);
        subplot(3,2,plotshift+j),
        imshow(imcomplement(BG{i}.^.25)), hold on
        plot(X{i},Y{i},cstring(i),'LineWidth',LineWidth),...
            plot(find(T{i}==0),Y{i}(T{i}==0),'kx','LineWidth',LineWidth),title([name{i} ' o''clock']);
        hx = graph2d.constantline(find(T{i}==0), 'LineStyle',':', 'Color',[0.0 0.0 0.0]);
        changedependvar(hx,'x');
        axis normal
    end
    
    hold off
end
if csection~=0
    measurements = struct2cell(dir(fullfile(path, '*cs.mat')));
    figure,
    for i = 1:size(measurements,2)
        load([path measurements{1,i}]);
        name = {'3' '6' '1.5' '4.5'};
        X = {x3 x6 x15 x45};
        Y = {s3 s6 zn15 zn45};
        T = {t3 t6 t15 t45};
        BG = {bg3 bg6 bg15 bg45};
        subplot(3,2,plotshift+i),
        imshow(imcomplement(BG{csection}.^.25)), hold on
        plot(X{csection},Y{csection},cstring(csection),'LineWidth',LineWidth),...
        h1 = plot(find(T{csection}==0),Y{csection}(T{csection}==0),'kx','LineWidth',LineWidth);...
        title(['Time point ' num2str(i)]);
        hx = graph2d.constantline(find(T{csection}==0), 'LineStyle',':', 'Color',[0.0 0.0 0.0]);
        
        changedependvar(hx,'x');
        axis normal
    end
    % Create legend
    if size(measurements,2) <=4
        legend1 = legend([h1], {'Landmark points'});
        set(legend1,...
            'Position',[0.385416666666662 0.647619047619048 0.239285714285714 0.046031746031746]);
    else
        
        legend1 = legend('Segmentation ONH','Landmark points');
        set(legend1,...
            'Position',[0.568452380952374 0.225396825396826 0.258928571428571 0.080952380952381]);
    end
end

if (csection == 0)
    measurements = struct2cell(dir(fullfile(path, '*cs.mat')));
    measurement_queue = {measurements{1} measurements{1,size(measurements,2)}};
    figure('position', [0, 0, 900, 300]),
    titlestring = {'First','Last'};
            % Change default axes fonts.
            set(0,'DefaultAxesFontName', 'Georgia')
            set(0,'DefaultAxesFontSize', 9)

            % Change default text fonts.
            set(0,'DefaultTextFontname', 'Georgia')
            set(0,'DefaultTextFontSize', 9)

    for j = 1:4
        for i = 1:2;
            load([path measurement_queue{1,i}]);
            name = {'3' '6' '1.5' '4.5'};
            X = {x3 x6 x15 x45};
            Y = {s3 s6 zn15 zn45};
            T = {t3 t6 t15 t45};
            BG = {bg3 bg6 bg15 bg45};
            subplot(2,4,j+(4*(i-1))),
            imshow(imcomplement(BG{j}.^.25)), hold on
            plot(X{j},Y{j},cstring(j),'LineWidth',LineWidth),...
                h1 = plot(find(T{j}==0),Y{j}(T{j}==0),'kx','LineWidth',LineWidth);...
                if i == 1
                title([name{j} ' o''clock']);
                end
            
            hx = graph2d.constantline(find(T{j}==0), 'LineStyle',':', 'Color',[0.0 0.0 0.0]);
            
            changedependvar(hx,'x');
            axis normal
        end
    end
    
    % Create legend
        legend1 = legend([h1], {'Landmark points'});
        set(legend1,...
            'Position',[0.661130952380948 0.495079365079366 0.239285714285714 0.0644444444444444]);

end


%%%%% Save
if (exist('editmode')==1)
    if editmode == 1
        keyboard
        save([path filename(1:(end-16)) 'cs.mat'],'phi_enface','pos','filename','xcenter', 'ycenter', 'Rfit','zny','s15','r15',...
            's45','r45','x3','s3','x6','s6','x15','zn15','x45','zn45','bg3','bg6','bg15','bg45',...
            't3' ,'t6' ,'t15','t45');
    end
    
    if (ExportMode==true)
        export_fig(output_file,'-transparent')
    end
    
end


