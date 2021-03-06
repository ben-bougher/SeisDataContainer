function y = reshape(x,varargin)
%RESHAPE    Reshape data container object to desired shape
%
%   reshape(X,N1,N2,...,N) reshapes data container X into the
%   dimensions defined as [N1,N2,...,N]. Note that the number of elements
%   must be conserved.
%
%   Note: The new reshape dimensions must always be a collapsed or
%   uncollapsed form of the original implicit dimension. Cross-dimensional
%   reshapes are not allowed. If you insist on doing cross-dimensional
%   reshapes, consider using setimsize to change the implicit dimensions
%   before reshaping.
%
%   See also: invvec, dataContainer.vec, iCon.double, setimsize

% Setting up the variables
imsize  = x.header.size;
redims  = [varargin{:}];

% Reshape data 
y = iCon(reshape(x.data,redims));

% Strip singleton dimensions
while (imsize(end) == 1) 
   imsize(end) = [];
end

while (redims(end) == 1) 
   redims(end) = [];
end

if length(redims) > length(imsize) % Expanding implicit size
    warning('iCon:reshape:imsize',...
        ['Too... many.... reshape... dimensions... cant handle... more ',...
        'than... number of implicit dimensions... Old metadata destroyed...']);
else % Collapsing implicit size

    % Calculate collapsed dimensiosn
    j               = 1;
    collapsed_chunk = [];
    collapsed_dims  = 1;

    for i = 1:length(imsize)
        collapsed_chunk = [collapsed_chunk imsize(i)];
        if  prod(collapsed_chunk) == redims(j)
            collapsed_dims(end+1) = i;
            if i < length(imsize)
                collapsed_dims(end+1) = i+1;
            end
            j = j + 1;
            collapsed_chunk = [];
        elseif prod(collapsed_chunk) > redims(j)
            warning('iCon:reshape:imsize',...
            ['ERROR: reshape dimensions not collapsible from implicit dimensions. ',...
            'DOES NOT COMPUTE... WILL PROCEED TO MURDER YOUR OLD METADATA... DONE']);
            return;
        end
    end

    % Reshape collapsed dims
    collapsed_dims = reshape(collapsed_dims,2,[]);
    y.perm         = 1:length(collapsed_dims);
    y.exsize       = collapsed_dims;

    % Metadata transfer
    y_header               = y.header;
    y_header.dims          = x.header.dims;
    y_header.varName       = x.header.varName;
    y_header.varUnits      = x.header.varUnits;
    y_header.origin        = x.header.origin;
    y_header.delta         = x.header.delta;
    y_header.precision     = x.header.precision;
    y_header.complex       = x.header.complex;
    y_header.unit          = x.header.unit;
    y_header.label         = x.header.label;
    y_header.distributedIO = x.header.distributedIO;
    y_header.size          = x.header.size;
    y.header               = y_header;
end % collapsing implicit size