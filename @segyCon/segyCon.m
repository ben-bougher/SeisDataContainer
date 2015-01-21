classdef segyCon
%
%   Seismic data container for handling large out of core SEGY
%   files. Current implementation only reads data and does not
%   overwrite the underlying SEG-Y data. 
%
%   x = segyCon(metadata_path) returns a segy seismic data
%   container that accesses the data referenced by a given metadata
%   file.
%

    
   properties( Access = protected )
       
       % Header for the underlying SEGY files
       header = {};
       % loaded data
       data = [];
       % headers for loaded data 
       trace_headers = {};
       % job metafile
       metafile = '';
   end
   
   methods
       
       function obj = segyCon(metadata_path);
           
           obj.header = load(metadata_path);
           obj.metafile = metadata_path;
           
           % Load the first block
           [trace_headers, data, ilxl, offset_read] = ...
               node_segy_read(obj.metafile, 1,1);
           
           obj.data = data;
           obj.trace_headers = trace_headers;
           
       end
   
    
end    
