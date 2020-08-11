classdef Moment < sp.DataFile
    methods
        function obj = Moment(filename)
           obj = obj@sp.DataFile(filename);
           obj.parse();
        end
    end
    
    methods (Access = private)
       parse(obj); 
    end
end