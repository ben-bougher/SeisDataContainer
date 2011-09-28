function FileComplex(A,B,dirnameOut)
%FILECOMPLEX Allocates file space and makes the complex of two input files
%   FileComplex(A,B,DIRNAMEOUT)
%
%   A,B        - Either string specifying the directory name of the input
%                files or a scalar
%   DIRNAMEOUT - A string specifying the output directory name
%   
    global SDCbufferSize;
    
    % Taking care of the complex part
    if(isscalar(B))
        headerA = DataContainer.io.memmap.serial.HeaderRead(A);
        if(headerA.complex)
            error('Epic fail: the firt input is complex')
        end        
        % Set byte size
        bytesize       = DataContainer.utils.getByteSize(headerA.precision);
        
        headerOut      = headerA;
        xsize          = headerOut.size;
        headerOut.complex = 1;
        DataContainer.io.memmap.serial.FileAlloc(dirnameOut,headerOut);
        headerOut.size    = [1 prod(xsize)];
        DataContainer.io.memmap.serial.HeaderWrite(dirnameOut,headerOut);
        
        % Set the sizes
        reminder  = prod(xsize);
        maxbuffer = SDCbufferSize/bytesize;
        rstart = 1;

        while (reminder > 0)
            buffer = min(reminder,maxbuffer);
            rend   = rstart + buffer - 1;
            r1     = ones(1,buffer);
            r1     = r1*B;
            DataContainer.io.memmap.serial.FileWriteLeftChunk...
                (dirnameOut,r1,[rstart rend],[]);
            reminder = reminder - buffer;
            rstart   = rend + 1;
        end
        movefile([dirnameOut filesep 'real'],[dirnameOut filesep 'imag']);
    elseif(isdir(B))
        if(~isreal(A))
            error('Epic fail: the firt input is complex')
        end
        headerB = DataContainer.io.memmap.serial.HeaderRead(B);
        if(headerB.complex)
            error('Epic fail: the second input is complex')
        end
        DataContainer.io.memmap.serial.FileCopy(B,dirnameOut)
        movefile([dirnameOut filesep 'real'],[dirnameOut filesep 'imag'])        
    else
        error('Wrong type of input for B')
    end
    
    % Taking care of the real part
    if(isscalar(A))
        headerB = DataContainer.io.memmap.serial.HeaderRead(B);
        % Set byte size
        bytesize       = DataContainer.utils.getByteSize(headerB.precision);
        
        headerOut      = headerB;
        xsize          = headerOut.size;
        DataContainer.io.memmap.serial.FileCopy(B,dirnameOut)
        headerOut.size    = [1 prod(xsize)];
        DataContainer.io.memmap.serial.HeaderWrite(dirnameOut,headerOut);
        
        % Set the sizes
        reminder  = prod(xsize);
        maxbuffer = SDCbufferSize/bytesize;
        rstart = 1;

        while (reminder > 0)
            buffer = min(reminder,maxbuffer);
            rend   = rstart + buffer - 1;
            r1     = ones(1,buffer);
            r1     = r1*A;
            DataContainer.io.memmap.serial.FileWriteLeftChunk...
                (dirnameOut,r1,[rstart rend],[]);
            reminder = reminder - buffer;
            rstart   = rend + 1;
        end
        headerOut.size    = xsize;
        headerOut.complex = 1;
        DataContainer.io.memmap.serial.HeaderWrite(dirnameOut,headerOut);
    elseif(isdir(A))
        headerA = DataContainer.io.memmap.serial.HeaderRead(A);
        if(headerA.complex)
            error('Epic fail: the firt input is complex')
        end
        DataContainer.io.memmap.serial.FileCopy(A,dirnameOut)
        headerOut = headerA;
        headerOut.complex = 1;
        DataContainer.io.memmap.serial.HeaderWrite(dirnameOut,headerOut);
    else
        error('Wrong type of input for A')
    end
end

