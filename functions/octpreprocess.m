% OCTPREPROCESS loads OCT volumes and applies roll-off correction 
% and attenuation coefficient conversion
%
%   SYNOPSIS:  
%       OCTPREPROCESS(SUBJECT,MEASUREMENT)
%           SUBJECT     format: integer
%           MEASUREMENT format: integer
%                       extra: 0 to segment all

function octpreprocess(subject, measurement)

path = [pwd '\subjects\Subject ' num2str(subject) '\'];

if measurement ~= 0
  filename = ['Subject ' num2str(subject) '_' num2str(measurement) '.vol'];
  volumes{1,1} = filename;
  vol_amount = 1;
  vol_loop = [str2num(filename(end-4))];
else
  volumes = struct2cell(dir(fullfile(path, '*.vol')));
  vol_amount = size(volumes,2);
  tmp = volumes(1,:);
  
  for k = 1:vol_amount;
      vol_loop(k) = str2num(tmp{k}(end-4));
  end
end

fprintf(strcat(mat2str(vol_amount), ' volume(s) found and ready to be pre-processed\n'))

if isequal(exist(strcat(path,'\presegment\'),'dir'),7)
    fprintf('Continu to work in existing folder: %s\n','presegment');
else
    mkdir(strcat(path,'\presegment\'));
    fprintf('New folder created with the name: %s \n','presegment');
end

w = 0;
for i =vol_loop;
    if measurement == 0
        waitbar(w / (vol_amount-1));
    end
    
    filename = ['Subject ' num2str(subject) '_' num2str(i) '.vol'];
    [V SLO_image]= read_volume(filename,path);
    fprintf(['Preprocessing ' filename '...']); 
    %addpath(strcat(pwd,'\code\extra_functions'));
    addpath([pwd '\codes\roll_off'])
    [V2 miss] = attenuation_roll_off(V);
    rmpath([pwd '\codes\roll_off'])
    fprintf('done \n');
    save(strcat(path,'\presegment\',filename(1:end-4),'_presegment.mat'),'V2','miss','filename')
end

