%ASMTRAIN applies ASM on training data
%
%   SYNOPSIS:
%       asmtrain(SUBJECT,CSECTION,VARMODE)
%           SUBJECT     format: integer
%           CSECTION    format: 1,2,3 or 4
%           VARMODE     format: integer
%                       default: 1
%                       info: only show a specific
%                       mode of variation
%
%   REQUIREMENTS:
%           ASM Functions written by
%           D.Kroon University of Twente (February 2010)
%           http://www.mathworks.com/matlabcentral/fileexchange/26706-active-shape-model--asm--and-active-appearance-model--aam-
function asmtrain(subject,csection,varmode)
%%% Set layout options
% Export plot to file
ExportMode = true;

% Change line style in plots
LineWidth = 2;

%%% Set asm options
% Number of contour points interpolated between the major landmarks.
options.ni=20;
% Length of landmark intensity profile
options.k = 8;
% Number of modes plotted
options.maxmodes=3;
% Search length (in pixels) for optimal contourpoint position,
% in both normal directions of the contourpoint.
options.ns=6;
% Number of image resolution scales
options.nscales=1;
% Set normal contour, limit to +- m*sqrt( eigenvalue )
options.m=3;
% Number of search itterations
options.nsearch=40;
% If verbose is true all debug images will be shown.
options.verbose=false;
% The original minimal Mahanobis distance using edge gradient (true)
% or new minimal PCA parameters using the intensities. (false)
options.originalsearch=false;



if (exist('varmode')==0)
    output_file = ['../Report/img/results/s' num2str(subject) 'cs' num2str(csection) 'modes.eps'];
else
    output_file = ['../Report/img/results/s' num2str(subject) 'cs' num2str(csection) 'mode' num2str(varmode) '.eps'];
end

if (exist('varmode')==1)
    vmode = varmode;
else
    vmode = 1;
end

% Add functions path to matlab search path

functiondir=strcat(pwd,'\toolbox\ActiveModels_version7\');
addpath([functiondir 'Functions']);
addpath([functiondir 'ASM Functions']);
addpath([functiondir 'InterpFast_version1'])

% Try to compile c-files
mexfolder = [functiondir 'InterpFast_version1'];
cd(mexfolder)
try
    mex('interp2fast_double.c','image_interpolation.c');
catch ME
    disp('compile c-files failed: example will be slow');
end
cd(functiondir);

cd ../../



%%% Load training data
% First Load the Hand Training DataSets (Contour and Image)
% The LoadDataSetNiceContour, not only reads the contour points, but
% also resamples them to get a nice uniform spacing, between the important
% landmark contour points.

angle = {'03', '06', '15', '45'};
train_path = ['subjects\Subject ' num2str(subject) '\segment\train\'];
train_files = struct2cell(dir(fullfile(train_path,'*train.mat')));
train_queue = train_files(1,:);



for i = csection
    tmp = strfind(train_queue,[char(angle(i)) ' train']);
    tmp_queue = find(~cellfun(@isempty,tmp));
    for j = 1:length(tmp_queue)
        train_queue(tmp_queue(j));
    end
    
    
    TrainingData=struct;
    counter = 0;
    for j=1:length(tmp_queue)
        counter = counter + 1;
        filename= [train_path '\' char(train_queue(tmp_queue(j)))];
        load(filename)
        I = p.I;
        I = real(p.I);
        [Vertices,Lines]=LoadDataSetNiceContour(filename,options.ni,options.verbose);
        if(options.verbose)
            t=mod(counter-1,4); if(t==0), figure; end
            subplot(2,2,t+1), imshow(I); hold on;
            P1=Vertices(Lines(:,1),:); P2=Vertices(Lines(:,2),:);
            plot([P1(:,2) P2(:,2)]',[P1(:,1) P2(:,1)]','b');
            drawnow;
        end
        TrainingData(counter).Vertices=Vertices;
        TrainingData(counter).Lines=Lines;
        TrainingData(counter).I=I;
    end
    
    
    
    %%% Shape Model %%
    % Make the Shape model, which finds the variations between contours
    % in the training data sets. And makes a PCA model describing normal
    % contours
    
    [ShapeData TrainingData]= ASM_MakeShapeModel2D(TrainingData);
    
    % Show modes of variation
    if (exist('varmode')==0)
        %%% Font settings for report
        % Change default axes fonts.
        set(0,'DefaultAxesFontName', 'Georgia')
        set(0,'DefaultAxesFontSize', 14)
        
        % Change default text fonts.
        set(0,'DefaultTextFontname', 'Georgia')
        set(0,'DefaultTextFontSize', 14)
        
        figure('position', [0, 0, 1100, 500]),
        for i=1:min(options.maxmodes,length(ShapeData.Evalues))
            
            xneg = ShapeData.x_mean + ShapeData.Evectors(:,i)*sqrt(ShapeData.Evalues(i))*-options.m;
            xpos = ShapeData.x_mean + ShapeData.Evectors(:,i)*sqrt(ShapeData.Evalues(i))*+options.m;
            subplot(1,min(options.maxmodes,length(ShapeData.Evalues)),i),  hold on;
            title(['Mode ' num2str(i)]),
            plot(xpos(end/2+1:end),xpos(1:end/2),'+r','LineWidth',LineWidth);
            plot(ShapeData.x_mean(end/2+1:end),ShapeData.x_mean(1:end/2),'b','LineWidth',LineWidth);
            plot(xneg(end/2+1:end),xneg(1:end/2),'--m','LineWidth',LineWidth);
            axis tight
            set(gca, 'YTick', []);
            set(gca, 'XTick', []);
            box on
        end
        legend1 = legend('Mean + 3\cdot\sigma\cdotEv', 'Mean',  'Mean - 3\cdot\sigma\cdotEv');
        switch i
            case 3
                set(legend1,...
                    'Position',[0.355556277056274 0.454460317460317 0.163636363636364 0.163333333333333]);
            case 2
                set(legend1,...
                    'Position',[0.487121212121212 0.433333333333333 0.163636363636364 0.163333333333333]);
        end
        drawnow;
    end
    
    % Show single mode of variation
    if (exist('varmode')==1)
        %%% Font settings for report
        % Change default axes fonts.
        set(0,'DefaultAxesFontName', 'Georgia')
        set(0,'DefaultAxesFontSize', 9)
        
        % Change default text fonts.
        set(0,'DefaultTextFontname', 'Georgia')
        set(0,'DefaultTextFontSize', 9)
        xtest_min = ShapeData.x_mean + ShapeData.Evectors(:,vmode)*sqrt(ShapeData.Evalues(vmode))*-options.m;
        xtest_max = ShapeData.x_mean + ShapeData.Evectors(:,vmode)*sqrt(ShapeData.Evalues(vmode))*options.m;
        figure,
        plot(   xtest_min(end/2+1:end),xtest_min(1:end/2),'+r',...
            ShapeData.x_mean(end/2+1:end),ShapeData.x_mean(1:end/2),'b',...
            xtest_max(end/2+1:end),xtest_max(1:end/2),'--m'...
            );
        axis square,
        set(gca, 'YTick', []);
        set(gca, 'XTick', []);
        legend1 = legend('Mean - 3\cdot\sigma\cdotEv', 'Mean',  'Mean + 3\cdot\sigma\cdotEv'); title(['ASM mode of variation ' num2str(vmode)]);
        set(legend1,...
            'Position',[0.240773809523806 0.143253968253968 0.264285714285714 0.151587301587302]);
        
        
    end
    
    if (ExportMode==true)
        export_fig(output_file,'-transparent')
    end
end
end

