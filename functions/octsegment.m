% OCTSEGMENT segments pre-processed OCT data 
%
%   SYNOPSIS:  
%       OCTSEGMENT(SUBJECT,MEASUREMENT, INTENSITY)
%           SUBJECT     format: integer
%           MEASUREMENT format: integer
%                       extra: 0 to segment all
%           INTENSITY   format: double
%                       default: 0.1

function octsegment(subject, measurement, intensity)
output_folder = 'segment';
if (exist('intensity')==1)
    int = intensity;
else
    int = 0.1;
end
path = [pwd '\subjects\Subject ' num2str(subject) '\'];
folder_name = strcat(path,output_folder);

if measurement ~= 0
  filename = ['Subject ' num2str(subject) '_' num2str(measurement) '.mat'];
  vol_amount = 1;
  sample_loop = [str2num(filename(end-4))];
  samples = struct2cell(dir(strcat(path,'\presegment\*presegment.mat')));
else
  samples = struct2cell(dir(strcat(path,'\presegment\*presegment.mat')));
  tmp = samples(1,:);
  for k = 1:length(samples)
      sample_loop(k) = str2num(tmp{k}(end-15));
  end
  vol_amount = length(sample_loop);
end

fprintf(strcat(mat2str(vol_amount), ' volume(s) found and ready to be segmented \n'))

w = 0;
for i = sample_loop;
    if measurement == 0
        waitbar(w / (vol_amount-1));
    end
    sample_file = ['Subject ' num2str(str2num(path(end-2:end-1))) '_' num2str(i) '_presegment.mat'];
    fprintf(['Segmenting ' sample_file '...']);
    load(strcat(path,'presegment\',sample_file));

    % Crop search canvas for segmentation
    x1 = 30;
    x2 = 480;
    z1 = 20;
    z2 = 496;

    V2 = V2(z1:z2,x1:x2,:);
    miss = miss(z1:z2,x1:x2,:);
    % Segment the OCT data
    phi=initial_retina(V2,miss,filename,path,output_folder,folder_name,int);
    fprintf('done \n');
    w = w + 1;
end
