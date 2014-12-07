% Function COMPUTE LEVEL SET
% creates a  signed distance function from the coordinates of the zero
% level set.
function D = compute_levelset(name, n1, n2, options)


[Y,X] = meshgrid(1:n2,1:n1);

switch lower(name)
    % if zero level set is specified with a circle of a certain radius
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

    % if zero level set is given as coordinates
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



    otherwise 
    error('Unknown shape.');
end
