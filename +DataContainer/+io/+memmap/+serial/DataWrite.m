function DataWrite(dirname,filename,x,varargin)
%DATAWRITE  Write serial data to binary file
%
%   DataWrite(DIRNAME,FILENAME,DATA,FILE_PRECISION) writes
%   the real serial array X into file DIRNAME/FILENAME.
%   Addtional parameter:
%   FILE_PRECISION - An optional string specifying the precision of one unit of data,
%               defaults to 'double' (8 bits)
%               Supported precisions: 'double', 'single'
%
%   Warning: If the specified file already exist,
%            it will be overwritten.
assert(ischar(dirname), 'directory name must be a string')
assert(ischar(filename), 'file name must be a string')
assert(isreal(x), 'data must be real')
assert(~isdistributed(x), 'data must not be distributed')

% Setup variables
precision = 'double';

% Preprocess input arguments
error(nargchk(3, 4, nargin, 'struct'));
filename=fullfile(dirname,filename);
if nargin>3
    assert(ischar(varargin{1}),'Fatal error: precision is not a string?');
    precision = varargin{1};
end;

% Set bytesize
bytesize = DataContainer.utils.getByteSize(precision);
switch precision
    case 'single'
        if ~isa(x,'single'); x=single(x); end;
    case 'double'
	if ~isa(x,'double'); x=double(x); end;
    otherwise
        error('Unsupported precision');
end

% Preallocate File
DataContainer.io.allocFile(filename,prod(size(x)),bytesize);

% Setup memmapfile
M = memmapfile(filename,...
            'format',{precision,size(x),'x'},...
	    'writable', true);
        
% Write local data
M.data(1).x = x;
        
end
