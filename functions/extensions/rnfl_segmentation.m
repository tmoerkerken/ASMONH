% function RNFLSEGMENTATION
% finds vitreous-rnfl boundary using a Region Growing alogrithm

function [phi] = rnflSegmentation(image, counter, int)


    % blur image to reduce noise and sharp edges
    im = im2mat(gaussf(image,[1.5 1.5]));
    
    % smearing vertical gaps (within 130px) caused by imaging error
    se = strel('line',130,90);
    im = imdilate(im,[se],'full');
    
    % blur image to reduce newly created noise
    im = im2mat(gaussf(im,[1.5 1.5]));
    
    % smearing sharp edges caused by imaging error
    se = strel('line',1,0);
    im = imdilate(im,[se],'full');
    
    % blur image to reduce newly created noise
    im = im2mat(gaussf(im,[1.5 1.5]));
    
    % smearing small vertical gaps (within 5px) caused by imaging error
    se = strel('line',5,90);
    im = imdilate(im,[se],'full');
    
    % blur image to reduce newly created noise
    im = im2mat(gaussf(im,[2 2]));
    
    % remove Inf values out of image
    im(im==-Inf) = 0;

    % fill vitreous to detect the vitreouos-rnfl boundary
    Rg = RegionGrowing(im,int,[15 50]);
    
    % get rid of unwanted holes in segmentation
    Rg = imfill(Rg,'holes');
    Rg = ~imfill(~Rg,'holes');
    Rg = imfill(Rg,'holes');
    
    % the edge is named 'phi'
    phi = Rg;
   

end