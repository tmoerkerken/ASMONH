function mu = attenuation(img)

I = double(img);
I(isnan(I)) = 0;
I(I<0) = 0;
t = flipdim(cumsum(flipdim(I,2),2),2)-I;

mu = 1/2*log(1+I./t);
