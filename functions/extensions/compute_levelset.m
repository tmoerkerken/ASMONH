function D = compute_levelset(name, n1, n2, options)


[Y,X] = meshgrid(1:n2,1:n1);

switch lower(name)
    
    case 'circle'
        if isfield(options, 'center')
            center = options.center;
        else
            center = [n1 n2]/2;
        end
        if isfield(options, 'radius')
            radius = options.radius;
        else
            radius = min(n1/4,n2/4);
        end

        D = sqrt( (X-center(1)).^2+(Y-center(2)).^2 ) - radius;
   
  
        case 'horizontal'
        if isfield(options, 'zero')
            center = options.zero;
        else
            center = n1/2;
        end

        D = (X-center);
        case 'horizontal2'
        if isfield(options, 'line')
            center = options.line;
        else
            center = n1/2;
        end

         D = zeros(size(X));
        for j = 1:n2
            for i=1:n1
                D(i,j) = X(i,j) - round(center(j,1));
            end

        end


        
        case 'horizontal3'
            D = Inf*ones(n1,n2);
        if isfield(options, 'lines')
            pom = options.lines;
        else
            pom = n1/2;
        end
        
        for k = 1:size(pom,2)/2
                options.line = pom(:,((k-1)*2+1):((k-1)*2+2));
                b = compute_levelset('horizontal2',n1,n2,options);
                if k == 1
                    D = min(D,b);
                elseif mod(k+1,2) %paran
                    D = min(D,-b);
                else %neparan
                   D=  max(D,b);
                end
      
        end
        
        
    otherwise 
        error('Unknown shape.');
end
