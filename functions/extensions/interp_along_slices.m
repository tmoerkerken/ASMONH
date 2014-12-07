    function res = interp_along_slices( vol, scale )
    % Interpolation along the image slices

    % Get the size of the volume
      [r c p] = size(vol);

    % Pre-allocate the array:
    % the third dimension is scale times the p
      vol_interp = zeros(r,c,scale*p);

    % interpolate along the image slices 
      for inr = 1:r;
          for jnr = 1:c;
              xi = vol(inr,jnr,:);
              vol_interp(inr,jnr,:) = interp(xi, scale); 
          end;
      end;

      res = vol_interp;

    end