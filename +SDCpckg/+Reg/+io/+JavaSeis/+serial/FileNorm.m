function x = FileNorm(dirname,norm,file_precision)
%FILENORM Calculates the norm of a given data
%
%   FileNorm(DIRNAME,FILENAME,DIMENSIONS,NORM,FILE_PRECISION)
%
%   DIRNAME        - A string specifying the input directory
%   NORM           - Specifyies the norm type. Supported norms: inf, -inf,
%                    'fro', p-norm where p is scalar.

SDCpckg.Reg.io.isFileClean(dirname);
%error(nargchk(2, 2, nargin, 'struct'));
%assert(ischar(dirname), 'input directory name must be a string')
%assert(isdir(dirname),'Fatal error: input directory %s does not exist'...
%   ,dirname)

global SDCbufferSize;
%assert(~isempty(SDCbufferSize),'you first need to execute SeisDataContainer_init')
% Must be equal to range*slice
SDCbufferSize = 840 ; % works for current test case

% Set up the Seisio object
import beta.javaseis.io.Seisio.*;    
seisio = beta.javaseis.io.Seisio( dirname );
seisio.open('r');


% Reading the header
% header    = SDCpckg.Reg.io.JavaSeis.serial.HeaderRead(dirname);

% Get number of dimensions and set position accordingly
header.dims = seisio.getGridDefinition.getNumDimensions() ;

% Define number of Hypercubes, Volumes, Frames & Traces
header.size = seisio.getGridDefinition.getAxisLengths() ;

seisio.close(); 

%file_precision = 'double';
dimensions = header.size
newdim = dimensions(1)*dimensions(2)*dimensions(3)*dimensions(4)

% Set byte size
bytesize  = SDCpckg.Reg.utils.getByteSize(file_precision);

% Set the sizes
dims      = [1 newdim]
reminder  = newdim ;
maxbuffer = SDCbufferSize/bytesize

class(reminder)
class(maxbuffer)

reminder = typecast(maxbuffer,'int64') ;

class(maxbuffer) 

if(norm == 'fro')
    norm = 2;
end

% Infinite norm
if(norm == inf)
    rstart = 1
    x = -inf;
    buffer = min(reminder,maxbuffer);
    rend = rstart + buffer - 1
    while (reminder > 0 && rend < SDCbufferSize)
        buffer = min(reminder,maxbuffer);
        rend = rstart + buffer - 1 ;
      
        % We expect the Chunk to be already a vector
        % Current test case: x = [14,12,5] - dims = [1 5]
        r =  SDCpckg.Reg.io.JavaSeis.serial.DataReadLeftChunk(dirname,[1 5],[],[rstart rend],file_precision) ;
       
        total     = max(abs(r));
        x         = max(total,x);          
        reminder  = reminder - buffer;
        rstart    = rend + 1 ;
        clear r;
    end
    
% Negative infinite norm    
elseif(norm == -inf)
    rstart = 1;
    x = inf;
    buffer = min(reminder,maxbuffer);
    rend = rstart + buffer - 1;
    while (reminder > 0 && rend < SDCbufferSize)
        buffer = min(reminder,maxbuffer);
        rend = rstart + buffer - 1;
        
        % We expect the Chunk to be already a vector
        r =  SDCpckg.Reg.io.JavaSeis.serial.DataReadLeftChunk(dirname,[1 5],[],[rstart rend],file_precision) ;
         
         
        total     = min(abs(r));
        x         = min(total,x);        
        reminder  = reminder - buffer;
        rstart    = rend + 1;
        clear r;
    end
    
% P-norm
elseif (isscalar(norm))
    total = 0;
    rstart = 1;
    buffer = min(reminder,maxbuffer);
    rend = rstart + buffer - 1;
    while (reminder > 0 && rend < SDCbufferSize)
        buffer = min(reminder,maxbuffer);
        rend = rstart + buffer - 1;
        
        % We expect the Chunk to be already a vector
        r =  SDCpckg.Reg.io.JavaSeis.serial.DataReadLeftChunk(dirname,[1 5],[],[rstart rend],file_precision) ;
        
        total    = total + sum(abs(r).^norm);
        reminder = reminder - buffer;
        rstart   = rend + 1;
        clear r;
    end
    x = total^(1/norm);
else
    error('Unsupported norm');
end
end
