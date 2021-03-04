classdef Run < handle
   properties
      data
   end
   
   methods (Static)
       function parsed = parse(raw_data)
            parsed = raw_data(:, {'Time Stamp (sec)', 'Temperature (K)', 'Magnetic Field (Oe)'});
       end
   end
end