% CONSTRUCT_GRAPH
% constructs the combinations of pixels as nodes for the minimal path computation
% nodes are connected using 8 connected neighborhood
function [E, N, index] = construct_graph(height,width)

N = height*width;
I = []; J = [];

% connect pixels up - down

is = [1:N]'; is([height:height:N])=[];
js = is+1;
I = [I;is;js];
J = [J;js;is];
index(1) = size(is,1)+1;

% connect pixels left right
index(2)=size(I,1)+1;

is = [1:N-height]';
js = is+height;
I = [I;is;js];
J = [J;js;is];


% connect diagonal
    is([height:height:(width-1)*height])=[];
    js([height:height:(width-1)*height])=[];

    I = [I;is;js];
    J = [J;js+1;is+1];

    is = [1:N-height]';
    js = is+height;

    is([1:height:(width-1)*height])=[];
    js([1:height:(width-1)*height])=[];


    I = [I;is;js];
    J = [J;js-1;is-1];

    E = [I,J];
    
end