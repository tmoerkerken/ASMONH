% READ_VOLUME reads the .vol file specified with the file name and location
% 

function [V2 SLO_image]= read_volume(file,loc)
    filename = strcat(loc, file);
    fid=fopen(filename,'rb');
    if(fid<0)
        fprintf('could not open file %s\n',filename);
        return
    end
    
    fseek(fid,0,'eof');
    fsize = ftell(fid); 
    fseek(fid,0,'bof');
    info.FileHeaderSize = 2048;
    info.FileHeaderOffset = 0;
    info.Version=fread(fid, 12, 'uint8=>char')';
    info.SizeX = fread(fid, 1, 'uint32');
    info.NumBScans = fread(fid, 1, 'uint32'); %size y
    info.SizeZ = fread(fid, 1, 'uint32');
    info.ScaleX = fread(fid, 1, 'double');
    info.Distance = fread(fid, 1, 'double');
    info.ScaleZ = fread(fid, 1, 'double');
    info.SizeXSlo = fread(fid, 1, 'uint32');
    info.SizeYSlo = fread(fid, 1, 'uint32');
    info.ScaleXSlo = fread(fid, 1, 'double');
    info.ScaleYSlo = fread(fid, 1, 'double');
    info.FieldSizeSlo = fread(fid, 1, 'uint32');
    info.ScanFocus = fread(fid, 1, 'double');
    info.ScanPosition = fread(fid, 4, 'uint8=>char');
    info.ExamTime = fread(fid, 2, 'uint32');
    info.ScanPattern = fread(fid, 1, 'uint32');
    info.BScanHdrSize = fread(fid, 1, 'uint32');
    fseek(fid,208,'bof');
    % info.ID = fread(fid, 16, 'uint8=>char');
    % info.ReferenceID = fread(fid, 16, 'uint8=>char');
    % info.PID = fread(fid, 1, 'uint32');
    % info.PatientID = fread(fid, 21, 'uint8=>char');
    % info.Padding = fread(fid, 3, 'uint8=>char');
    % info.DOB = fread(fid, 1, 'float64')
    info.Spare = fread(fid,1840,'uint8');

    % image information, first the SLO image then the volume
    SLO_image = uint8(fread(fid,info.SizeXSlo*info.SizeYSlo,'uint8'));
    SLO_image = reshape(SLO_image,info.SizeXSlo,info.SizeYSlo);
    %figure,imshow(SLO_image)
    V = single(zeros(info.SizeX, info.SizeZ, info.NumBScans));
    %V2 = single(zeros(info.SizeZ, info.SizeX, info.NumBScans));

    % reading the volume
    for i = 1:info.NumBScans
        tmp = fread (fid, info.BScanHdrSize, 'uint8'); 
        tmp2 = fread(fid,info.SizeX*info.SizeZ,'single');
        %tmp2  = 255.*nthroot(tmp2,4);
        V(:,:,i) = reshape(tmp2, info.SizeX, info.SizeZ);
    end

    clear ans filename fsize i info tmp tmp2
    fclose(fid);
    V2 = V;
    
end

