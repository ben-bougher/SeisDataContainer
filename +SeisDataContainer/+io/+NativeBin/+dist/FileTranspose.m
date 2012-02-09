function FileTranspose(dirnameIn,dirnameOut,distdirnameOut,sepDim)
%DATATRANSPOSE Transposes input data and writes it to output file
%
%   FileTranspose(DIRNAMEIN,DIRNAMEOUT,SEPDIM)
%   allocates binary file for serial data writing.
%
%   DIRNAMEIN      - A string specifying the input directory
%   DIRNAMEOUT     - A string specifying the output directory
%   DISTDIRNAMEOUT - A cell specifying the distributed output directories
%   SEPDIM         - A scalar specifying the separation dimension
%
%   Warning: For now this function only works for distributed data that 
%   has matlab default distribution
%

error(nargchk(4, 4, nargin, 'struct'));
assert(ischar(dirnameIn), 'input directory name must be a string')
assert(isdir(dirnameIn),'Fatal error: input directory %s does not exist',dirnameIn);
assert(ischar(dirnameOut), 'output directory name must be a string')
assert(isscalar(sepDim), 'dimensions must be given as a vector')

% Read header
headerIn  = SeisDataContainer.io.NativeBin.serial.HeaderRead(dirnameIn);
headerOut = headerIn;

% Making the transpose vector
spmd
    dim2D = [prod(headerOut.distribution.size{labindex}(1:sepDim)) prod(headerOut.distribution.size{labindex}(sepDim+1:end))];
end
% Setting up the output header
distdim            = headerOut.size(headerOut.distribution.dim+1:end);
headerOut.size     = [headerOut.size(sepDim+1:end) headerOut.size(1:sepDim)];
headerOut          = SeisDataContainer.io.addDistFileHeaderStruct(headerOut,distdirnameOut);
headerOut.origin   = [headerOut.origin(sepDim+1:end) headerOut.origin(1:sepDim)];
headerOut.delta    = [headerOut.delta(sepDim+1:end) headerOut.delta(1:sepDim)];
headerOut.unit     = [headerOut.unit(sepDim+1:end) headerOut.unit(1:sepDim)];
headerOut.label    = [headerOut.label(sepDim+1:end) headerOut.label(1:sepDim)];
partition          = SeisDataContainer.utils.defaultDistribution(headerOut.size(distdim));
headerOut          = SeisDataContainer.addDistHeaderStruct(headerOut,headerOut.dims,partition);
SeisDataContainer.io.NativeBin.serial.HeaderWrite(dirnameOut,headerOut);

% Allocate file
SeisDataContainer.io.NativeBin.dist.DataAlloc(headerOut.directories,'real',...
    headerOut.distribution.size,headerOut.precision);
if headerOut.complex
    SeisDataContainer.io.NativeBin.dist.DataAlloc(headerOut.directories,'imag',...
        headerOut.distribution.size,headerOut.precision);
end

% Transpose file
SeisDataContainer.io.NativeBin.dist.DataTranspose(dirnameIn,dirnameOut,'real',...
    dim2D,sepDim,headerOut.precision);
if headerOut.complex
    SeisDataContainer.io.NativeBin.dist.DataTranspose(dirnameIn,dirnameOut,...
        'imag',dim2D,sepDim,headerOut.precision);
end
end