% function rnflSegmentation
% finds vitreous-rnfl boundary using Dijsktra minimal path on the dark to bright
% gradient in y direction

function [phi] = rnflSegmentation (image, counter, int)

%     square = strel('square', 4);
%     imB = imerode(image, square);
    keyboard
    im = im2mat(gaussf(image,[1.5 1.5]));
    se = strel('line',100,90);
    im = imdilate(im,[se],'full');
    im = im2mat(gaussf(im,[1.5 1.5]));
    se = strel('line',3,0);
    im = imdilate(im,[se],'full');
    im = im2mat(gaussf(im,[1.5 1.5]));
    se = strel('line',5,90);
    im = imdilate(im,[se],'full');
    im = im2mat(gaussf(im,[2 2]));
    im(im==-Inf) = 0;

    Rg = RegionGrowing(im,int,[15 35]);
    Rg = imfill(Rg,'holes');
   
    Rg = ~imfill(~Rg,'holes');
    Rg = imfill(Rg,'holes');
    phi = Rg;
   

end