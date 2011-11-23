function save(obj,dirname)
%PICON.SAVE Saves piCon to file
    header      = obj.header;
    header.size = cell2mat(header.size);
    assert(~isdir(dirname),'Fatal error: directory %s already exists',dirname);
    status = mkdir(dirname);
    assert(status,'Fatal error while creating directory %s',tmpdir);
    DataContainer.io.memmap.serial.FileWrite(dirname,gather(double(obj)));
    DataContainer.io.memmap.serial.HeaderWrite(dirname,header);
end

