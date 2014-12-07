function R = roll_off(z,w)
    
    R = ((sin(z)./z).^2.*exp(-w.^2/(2*log(2)).*z.^2));
    if find(isnan(R))
        R(isnan(R)) = 1;
    end
end