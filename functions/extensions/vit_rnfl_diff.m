function [divmean vitreous_mean vitreous_var] = vit_rnfl_diff(Rg, im2)
    Rgtop(1:size(Rg,1)-3,1:size(Rg,2)) = Rg(4:size(Rg,1),1:size(Rg,2));
    Rgtop(end:end+3,:) = 0 ;
    Rgbottom(10:size(Rg,1),1:size(Rg,2)) = Rg(1:size(Rg,1)-9,1:size(Rg,2));
    Rgslice = ~Rg.*Rgbottom;
    vitreous_mean = mean(im2(Rgtop==1));
    vitreous_var = var(im2(Rgtop==1));
    retina_mean = mean(im2(Rgslice==1));
    divmean = retina_mean - vitreous_mean;
end