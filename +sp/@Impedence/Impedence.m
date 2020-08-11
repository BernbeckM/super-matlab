classdef Impedence < sp.DataFile
   methods
       plot(obj, plot_type, varargin);
       
       function obj = Impedence(filename)
          obj = obj@sp.DataFile(filename); 
       end
   end
end