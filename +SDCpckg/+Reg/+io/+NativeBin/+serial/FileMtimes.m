function FileMtimes(A,B,dirnameOut,swp)
%MTIMES Allocates file space calculates the mtimes of the input files
%
%   FileMtimes(A,B,DIRNAMEOUT)
%
%   A,B        - Either string specifying the directory name of the input
%                files or a scalar
%   DIRNAMEOUT - A string specifying the output directory name
% 
if ~isdir(B)
    error('Bad second input: Directory does not exist')
end
% unswap
if nargin == 4 && strcmp(swp,'swap')
    tmp = B;
    B   = A;
    A   = tmp;
    clear('tmp');
end

% checking sizes
sizeA = size(A);
if(length(sizeA) > 2)
    error('Fail: Wrong size for first parameter');
end
% Reading input header
headerB   = SDCpckg.Reg.io.NativeBin.serial.HeaderRead(B);
sizeB     = headerB.size;

if(sizeA(2) == sizeB(1))
    sepDim = 2;
else
    sepDim = 0;
    for i=1:length(sizeB)
        if(prod(sizeB(1:i)) == sizeA(2))
            sepDim = i+1;
            break;
        end
    end
end

if(sepDim == 0)
    error('Bad multiplication: Dimensions are not matching');
end

% Creating the output file

headerY             = headerB;
headerY.size        = [sizeA(1) sizeB(sepDim:end)];
if(headerB.complex)
    headerY.complex = 1;
end
SDCpckg.Reg.io.NativeBin.serial.FileAlloc(dirnameOut,headerY);

for i=1:prod(sizeB(sepDim:end))
    slice = SDCpckg.Reg.io.NativeBin.serial.FileReadLeftSlice(B,i);
    slice = reshape(slice,sizeA(2),numel(slice)/sizeA(2));
    prodz = mtimes(double(A),slice);
    SDCpckg.Reg.io.NativeBin.serial.FileWriteLeftSlice...
        (dirnameOut,prodz,i);
end
end