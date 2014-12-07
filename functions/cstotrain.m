%CSTOTRAIN converts ONH cross-sections to ASM training data
%
%   SYNOPSIS:  
%       CSTOTRAIN(SUBJECT,MEASUREMENT,INTENSITY)
%           SUBJECT     format: integer
%           MEASUREMENT format: integer
%           INTENSITY   format: double
%                       default: 0.1

function cstotrain(subject, measurement, intensity)

if (exist('intensity')==1)
    int = intensity;
else
    int = 0.1;
end

path = ['subjects\Subject ' num2str(subject) '\segment\'];
filename = [num2str(int,'%10.3f\n') '_Subject ' num2str(subject) '_' num2str(measurement) '_cs.mat'];
load([path filename]);
cstring = 'rkbmc';

% make output folder
output_folder = 'train';
if isequal(exist(strcat(path,output_folder,'\'),'dir'),7)
    fprintf('Continu to work in existing folder: %s\n',output_folder);
else
    mkdir(strcat(path,output_folder));
    mkdir(strcat(path,output_folder,'\train'));
    fprintf('New folder created with the name: %s \n',output_folder);  
end

y3 = s3';
y6 = s6';
y15 = zn15';
y45 = zn45';

% saving
ort = [3 6 15 45];


for i = 1:length(ort)
    if (str2num(strtrim(filename(end-20:end-20+1))) >= 10)
        namestring = [path 'train/' num2str(str2num(strtrim(filename(end-20:end-20+1))),'%02.0f\n') '_' filename(18) '_' num2str(ort(i),'%02.0f\n') ' train'];
    else
        namestring = [path 'train/' num2str(str2num(strtrim(filename(end-20:end-20+1))),'%02.0f\n') '_' filename(17) '_' num2str(ort(i),'%02.0f\n') ' train'];
    end
    p.x = eval(['x' num2str(ort(i))]);
    p.y = eval(['y' num2str(ort(i))]);
    p.t = eval(['t' num2str(ort(i))]);
    p.I = eval(['bg' num2str(ort(i))]).^.25;
    save(namestring,'p');
    
end
