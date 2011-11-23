function save(obj,dirname,overwrite)
%SAVE Saves iCon to file
%
% Optional argument:
% OVERWRITE: 1 for overwrite case and 0 otherwise

if(nargin == 2)
    overwrite = 0;
end
if(overwrite == 1)
    rmdir(dirname, 's');
else
    assert(~isdir(dirname),'Fatal error: directory %s already exists',dirname);
end
header      = obj.header;
header.size = cell2mat(header.size);    
status = mkdir(dirname);
assert(status,'Fatal error while creating directory %s',dirname);
DataContainer.io.memmap.serial.FileWrite(dirname,double(obj));
DataContainer.io.memmap.serial.HeaderWrite(dirname,header);
end
