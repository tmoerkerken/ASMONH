%CSCREATE makes OCT data isotropic and creates cross-sections
%
%   SYNOPSIS:
%       CSCREATE(SUBJECT,MEASUREMENT,INTENSITY)
%           SUBJECT     format: integer
%           MEASUREMENT format: integer
%           INTENSITY   format: double
%                       default: 0.1



function cscreate(subject, measurement, intensity)
%%% Set options
% Isotropic scaling 
yinterp = 7.750;
xinterp = 2.895;

% Moving average length
mav = 40;

%%% Script
if (exist('intensity')==1)
    
    int = intensity;
else
    int = 0.1;
end

path = ['subjects\Subject ' num2str(subject) '\segment\'];
filename = [num2str(int,'%10.3f\n') '_Subject ' num2str(subject) '_' num2str(measurement) '_segment_RNFL.mat'];
load([path filename],'image_after','phi','pos','xcenter','ycenter','Rfit');

% Convert segmentation data to non-monotonic data
phi2 = zeros(1,size(phi,2),size(phi,3));
tmp = phi;
tmp(:,:,size(phi,3)+1) = tmp(:,:,size(phi,3));

for i = 1:(size(tmp,3)-1)
    
    phi2(1,:,i) = get_edge(phi(:,:,i),'first');
    
end

% Create an enface image
clear n phi_shift phi_mask tmp
tmp = phi(1:477,:,:);
phi = tmp;
N = 20;
phi_shift = circshift(phi(:,:,:),[N,0]);
phi_shift(1:N,:,:) = 1;
phi_mask = (phi_shift + phi) == 1;
layer = image_after .* phi_mask;
phi_enface = squeeze(mean(layer))';
phi_enface = imresize(phi_enface,'scale',[yinterp xinterp]);


% Manually select points of cup
clear height width
height = size(phi_enface,1);
width = size(phi_enface,2);
center = [round(height/2) round(width/2)];
hOffset = round(center(1)/2);
vOffset = round(center(2)/2);
figure; hold on; imshow(log(phi_enface),[-12 -7]);


% Hint to show if center is already determined
if (exist('xcenter')==1)
    
    h(1) = impoint(gca,[xcenter ycenter]);
else
    h(1) = impoint(gca,[center(2)-vOffset center(1)-hOffset]);
end
h(2) = impoint(gca,[center(2) center(1)-hOffset]);
h(3) = impoint(gca,[center(2)+vOffset center(1)-hOffset]);
h(4) = impoint(gca,[center(2)+vOffset center(1)]);
h(5) = impoint(gca,[center(2)+vOffset center(1)+hOffset]);
h(6) = impoint(gca,[center(2) center(1)+hOffset]);
h(7) = impoint(gca,[center(2)-vOffset center(1)+hOffset]);
h(8) = impoint(gca,[center(2)-vOffset center(1)]);
h(9) = h(1);

choice = menu('All points in place?','Save points','Continu without saving','Abort script');

switch choice
    case 1
        clear pos
        for i = 1:9;
            pos(i,:) = round(getPosition(h(i)));
        end
        save([path filename],'pos','phi_enface','-append');
    case 2
        
    case 3
        msgbox('Script aborted by user ','Exit','Error')
        return
end

% Interpolate segmentation to isometric space
xn = 1:(1/(round(10*xinterp)/10)):size(phi2,2);
xnd = 1:size(xn,2);
zn = interp1(1:size(phi2,2),squeeze(phi2),xn);

yn = 1:(1/(round(10*yinterp)/10)):size(zn,2);
zny = interp1(1:size(phi2,3),zn',yn);



% Cup center and diameter estimation
if (exist('Rfit')==0)
    [xfit,yfit,Rfit] = circfit(pos(:,1),pos(:,2));
    
    xcenter = round(xfit);
    ycenter = round(yfit);
end



keyboard
save([path filename],'xcenter','ycenter','Rfit','-append');

% Get segmentation of 1.5 o'clock slice
clear s15 r15 s15 tmp_lim

if xcenter>=size(zny,1)-ycenter
    tmp_lim = size(zny,1)-ycenter;
else
    tmp_lim = xcenter - 1;
end
for i = 1:tmp_lim
    s15(1,i) = xcenter - i;
    s15(2,i) = zny(ycenter+i,xcenter-i);
    r15(1,i) = ycenter + i;
end

s15 = fliplr(s15);
r15 = fliplr(r15);
tempSize = length(s15);
center_15 = tmp_lim;
clear tmp_lim

if (size(zny,2)-xcenter) >=ycenter
    tmp_lim = ycenter - 1;
else
    tmp_lim = size(zny,2)-xcenter - 1;
end

for i = 1:tmp_lim
    s15(1,tempSize + i) = xcenter+i;
    r15(1,tempSize + i) = ycenter - i;
    s15(2,tempSize + i) = zny(ycenter-i,xcenter+i);
end



% Interpolate, because diagonal pixels represent a larger distance

yn15 = min(s15(1,:)):(1/sqrt(2)):max(s15(1,:));
zn15 = interp1(s15(1,:),s15(2,:),yn15);
zn15 = moving(zn15,mav);

% Get segmentation of 4.5 o'clock slice

clear s45 r45 s45 tmp_lim

if xcenter>=ycenter
    tmp_lim = ycenter-1;
else
    tmp_lim = xcenter-1;
end
%
% for i = 1:ycenter-1
for i = 1:tmp_lim
    s45(1,i) = xcenter - i;
    s45(2,i) = zny(ycenter-i,xcenter-i);
    r45(1,i) = ycenter - i;
end
s45 = fliplr(s45);
r45 = fliplr(r45);
tempSize = length(s45);
center_45 = tmp_lim;

clear tmp_lim;

if size(zny,2)-xcenter<=size(zny,1)-ycenter
    tmp_lim = size(zny,2)-xcenter;
else
    tmp_lim = size(zny,1)-ycenter;
end

for i = 1:tmp_lim
    s45(1,tempSize + i) = xcenter+i;
    r45(1,tempSize + i) = ycenter + i;
    s45(2,tempSize + i) = zny(ycenter+i,xcenter+i);
end

% Interpolate, because diagonal pixels represent a larger distance

yn45 = min(s45(1,:)):(1/sqrt(2)):max(s45(1,:));
zn45 = interp1(s45(1,:),s45(2,:),yn45);
zn45 = moving(zn45,mav);

% Get segmentation of 3 o'clock slice
s3 = zny(ycenter,:);
s3 = moving(s3,mav);

% Get segmentation of 6 o'clock slice
clear s6
for i = 1:size(zny,1)
    s6(1,i) = zny(i,xcenter);
end

s6 = moving(s6,mav);

% Obtain background images from b-scans
image_after(image_after == 1) = 0;

% Get background image of 3 o'clock slice
clear bg3
center_point_y = round(ycenter*size(image_after,3)/size(zny,1));
bg3 = imresize(image_after(:,:,center_point_y),'scale',[1 size(zny,2)/size(image_after,2)]);

% Get background image of 6 o'clock slice
clear bg6 tmp
center_point_x = round(xcenter*size(image_after,2)/size(zny,2));
tmp = squeeze(image_after(:,center_point_x,:));
bg6 = imresize(tmp,'scale',[1 size(zny,1)/size(image_after,3)]);


% Get background image of 1.5 o'clock slice
clear bg15
r15n = round(r15.*size(image_after,3)./size(zny,1));
s15n = round(s15(1,:).*size(image_after,2)./size(zny,2));
r15n(r15n == 0) = 1;
s15n(s15n == 0) = 1;
bg15 = zeros(size(phi,1),length(s15n));
for i = 1:length(s15n)
    bg15(:,i) = image_after(:,s15n(i),r15n(i));
end

% Resize, because diagonal cells represent a larger distance
bg15 = imresize(bg15, 'scale', [1 sqrt(2)]);

% Get background image of 4.5 o'clock slice
clear bg45
r45n = round(r45.*size(image_after,3)./size(zny,1));
s45n = round(s45(1,:).*size(image_after,2)./size(zny,2));
r45n(r45n == 0) = 1;
s45n(s45n == 0) = 1;
bg45 = zeros(size(phi,1),length(s45n));
for i = 1:length(s45n)
    bg45(:,i) = image_after(:,s45n(i),r45n(i));
end

% Resize, because diagonal cells represent a larger distance
bg45 = imresize(bg45, 'scale', [1 sqrt(2)]);

% Get landmark points
t3 = 2*ones(1,size(s3,1));
t3(xcenter) = 0;
t3(xcenter+round(Rfit)) = 0;
t3(xcenter-round(Rfit)) = 0;
x3 = 1:size(s3,1);

t6 = 2*ones(1,size(s6,1));
t6(ycenter) = 0;
t6(ycenter+round(Rfit)) = 0;
t6(ycenter-round(Rfit)) = 0;
x6 = 1:size(s6,1);

t15 = 2*ones(1,size(zn15,1));
x15 = yn15-round(min(yn15));
[~,tmp] = min(abs(x15-(xcenter-min(s15(1,:)))));
t15(tmp) = 0;
[~,tmp] = min(abs(x15-(xcenter-min(s15(1,:))) + Rfit));
t15(tmp) = 0;
[~,tmp] = min(abs(x15-(xcenter-min(s15(1,:))) - Rfit));
t15(tmp) = 0;

x15 = 1:length(yn15);

t45 = 2*ones(1,size(zn45,1));
x45 = yn45-round(min(yn45));
[~,tmp] = min(abs(x45-(xcenter-min(s45(1,:)))));
t45(tmp) = 0;
[~,tmp] = min(abs(x45-(xcenter-min(s45(1,:))) + Rfit));
t45(tmp) = 0;
[~,tmp] = min(abs(x45-(xcenter-min(s45(1,:))) - Rfit));
t45(tmp) = 0;
x45 = 1:length(yn45);
% t15(ycenter+round(Rfit)) = 0;
% t15(ycenter-round(Rfit)) = 0;

%%%%% Save
save([path filename(1:(end-16)) 'cs.mat'],'phi_enface','pos','filename','xcenter', 'ycenter', 'Rfit','zny','s15','r15',...
    's45','r45','x3','s3','x6','s6','x15','zn15','x45','zn45','bg3','bg6','bg15','bg45',...
    't3' ,'t6' ,'t15','t45');
end

