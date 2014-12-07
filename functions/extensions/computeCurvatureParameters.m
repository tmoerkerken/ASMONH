function [L1, L2, H, EV_1, EV_2] = computeCurvatureParameters(Image,scale)
% COMPUTECURVATUREPARAMETERS compute the second-order derivative of an
% image using Gaussian smoothing function
%   
%
%
%
%   Parameters:
%
%       Image       :Input image.
%       scale       :the std. dev of Gaussian function.
% 
%
%
%
% 
% 
%   See also 

%   Copyright 2013 ROI & TU Delft
%   $Revision: x.x     $Date: 2013/03/1 $




if size(Image,3)>1
    Image = double(Image(:,:,2));
else
    Image = double(Image);
end

% 
% %First and second order derivative kernels
% HWindow = round(3*scale);
% s2 = scale^2;
% [x, y] = meshgrid(-HWindow:HWindow);
% 
% %Gaussian smoothing filter (zero-order derivative)
% h = (exp(-(x.^2 + y.^2)/(2*s2)))/ (2*pi*s2);
% h(h<eps*max(h(:))) = 0;
% if sum(h(:)) ~= 0
%     h  = h/sum(h(:));
% end;


% First and second order derivative kernels
HWindowx = round(3*scale(1));
HWindowy = round(3*scale(2));
s2(1) = scale(1)^2;
s2(2) = scale(2)^2;
[x, y] = meshgrid(-HWindowx:HWindowx,-HWindowy:HWindowy);

% Gaussian smoothing filter (zero-order derivative)
h = (exp(-((x.^2 )/(2*s2(1))+ (y.^2)/(2*s2(2)))))/ (2*pi*sqrt(s2(1))*sqrt(s2(1)));
h(h<eps*max(h(:))) = 0;
if sum(h(:)) ~= 0
    h  = h/sum(h(:));
end;


% First-Order Gaussian derivative kernel along x and y
hx = (-x.*h)/s2(1);
hx = hx - mean(hx(:));

hy = (-y.*h)/s2(2);
hy = hy - mean(hy(:));

% Second-Order Gaussian derivative kernel along x and y
hxx = (s2(1)^-2) * (x.^2 - s2(1)).*h;
hxx = hxx - mean(hxx(:));

hyy = (s2(2)^-2) * (y.^2 - s2(2)).*h;
hyy = hyy - mean(hyy(:));


% Derivative along x and then y
hxy =  (s2(2)^-1)*(s2(1)^-1) * x.*y.*h;
hxy = hxy - mean(hxy(:));


% Compute the Hessian of an image, H = [Ixx, Ixy; Iyx Iyy]
H(:,:,1) = imfilter(Image, hxx, 'replicate');
H(:,:,2) = imfilter(Image, hxy, 'replicate');
H(:,:,3) = H(:,:,2);
H(:,:,4) = imfilter(Image, hyy, 'replicate');


% Compute the two eigenvalues of H
T1 = (H(:,:,1) + H(:,:,4))/2;
T2 = H(:,:,1).*H(:,:,4) - H(:,:,2).^2;
L1 = T1 + sqrt(abs(T1.^2 - T2));
L2 = T1 - sqrt(abs(T1.^2 - T2));


% Sorting eigenvalues by their absolute magnitude
t=abs(L1)>=abs(L2);
L1new = L1;
L1new(~t) = L2(~t);
L2new = L2;
L2new(~t) = L1(~t);
L1 = L1new;
L2 = L2new;
%L1 = (abs(L1./L2)>=1).*L1 + (abs(L1./L2)<1).*L2;
%L2 = (abs(L1./L2)>=1).*L2 + (abs(L1./L2)<1).*L1;


% Computing the largest eigenvectors(EV_1) of H...note that EV_1 points
% perpendicular to the vasculature orientation
v(:,:,1) = ones(size(L1));
v(:,:,2) = (L1-H(:,:,1))./H(:,:,2);
magV = sqrt(v(:,:,1).^2 + v(:,:,2).^2);
EV_1(:,:,1) = v(:,:,1)./magV;
EV_1(:,:,2) = v(:,:,2)./magV;


% Computing the smallest eigenvectors(EV_2)...note that EV_2 points
% along the vasculature orientation
v(:,:,1) = ones(size(L1));
v(:,:,1) = ones(size(L2));
v(:,:,2) = (L2-H(:,:,1))./H(:,:,2);
magV = sqrt(v(:,:,1).^2 + v(:,:,2).^2);
EV_2(:,:,1) = v(:,:,1)./magV;
EV_2(:,:,2) = v(:,:,2)./magV;



end


