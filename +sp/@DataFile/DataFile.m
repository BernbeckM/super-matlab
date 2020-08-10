classdef DataFile < handle & matlab.mixin.Heterogeneous
    properties
        filename         = '';
        measurement_type = ''; 
        instrument_type  = ''; 
        header           = table; 
        raw              = table; 
        datenum          = '';
        data             = table;
    end
    
    % TODO: normalize naming convetion
    properties (Hidden = true, Constant)
        ACFieldsRaw = {'Time', 'Temperature', 'Field', 'Frequency', 'ChiIn', 'ChiInErr', 'ChiOut', 'ChiOutErr'};
        MomentFieldsRaw = {'Time', 'Temperature', 'Field', 'Moment', 'MomentErr'};

        EicosaneMW = 282.55;
        EicosaneXdm = -0.00024306;
    end

    % TODO: normalize naming convetion, use enums?
    properties (Access = protected, Constant)
        MEASUREMENT_TYPES = {'AC', 'DC', 'RSO', 'VSM'};
        INSTRUMENT_TYPES = {'MPMS3', 'MPMSXL'};
        
        HeaderDefaultValues = {'no name given', 'no description given', '10', '0', '500', '0'};
        HeaderFieldsMPMS3 = {'SAMPLE_MATERIAL', 'SAMPLE_COMMENT', 'SAMPLE_MASS', 'SAMPLE_VOLUME', 'SAMPLE_MOLECULAR_WEIGHT', 'SAMPLE_SIZE'};
        HeaderFieldsMPMSXL = {'NAME', 'COMMENT', 'WEIGHT', 'AREA', 'LENGTH', 'SHAPE'};
        HeaderFieldsRaw = {'Name', 'Description', 'Mass', 'EicosaneMass', 'MolecularWeight', 'Xdm'};
        HeaderFields = {sp.DataFile.HeaderFieldsMPMS3, sp.DataFile.HeaderFieldsMPMSXL, sp.DataFile.HeaderFieldsRaw};
        
        ACFieldsMPMS3 = {'TimeStamp_sec_', 'Temperature_K_', 'MagneticField_Oe_', 'ACFrequency_Hz_', 'ACX__emu_Oe_', 'ACX_StdErr__emu_Oe_', 'ACX___emu_Oe_', 'ACX__StdErr__emu_Oe_'};
        ACFieldsMPMSXL = {'Time', 'Temperature_K_', 'Field_Oe_', 'WaveFrequency_Hz_', 'm__emu_', 'm_ScanStdDev', 'm__emu__1', 'm_ScanStdDev_1'};
        ACFields = {sp.DataFile.ACFieldsMPMS3, sp.DataFile.ACFieldsMPMSXL, sp.DataFile.ACFieldsRaw};

        DCFieldsMPMS3 = {'TimeStamp_sec_', 'Temperature_K_', 'MagneticField_Oe_', 'DCMomentFreeCtr_emu_', 'DCMomentErrFreeCtr_emu_'};
        DCFieldsMPMSXL = {'Time', 'Temperature_K_', 'Field_Oe_', 'LongMoment_emu_', 'LongScanStdDev'};
        DCFields = {sp.DataFile.DCFieldsMPMS3, sp.DataFile.DCFieldsMPMSXL, sp.DataFile.MomentFieldsRaw};
        
        RSOFieldsMPMS3 = {};
        RSOFieldsMPMSXL = {'Time', 'Temperature_K_', 'Field_Oe_', 'LongMoment_emu_', 'LongScanStdDev'};
        RSOFields = {sp.DataFile.RSOFieldsMPMS3, sp.DataFile.RSOFieldsMPMSXL, sp.DataFile.MomentFieldsRaw};
        
        VSMFieldsMPMS3 = {'TimeStamp_sec_', 'Temperature_K_', 'MagneticField_Oe_', 'Moment_emu_', 'M_Std_Err__emu_'};
        VSMFieldsMPMSXL = {};
        VSMFields = {sp.DataFile.VSMFieldsMPMS3, sp.DataFile.VSMFieldsMPMSXL, sp.DataFile.MomentFieldsRaw};
        
        LookupTable = {sp.DataFile.ACFields, sp.DataFile.DCFields, sp.DataFile.RSOFields, sp.DataFile.VSMFields};
    end
    
    methods
        function obj = DataFile(filename)
            obj.parse(filename);
        end

        % currently unused
        function [obj, updated] = update(obj, filename)
            database_name = 'super_datafiles.mat';
            database_mat = matfile(database_name, 'Writable', true);
            
            if isprop(database_mat, 'datafiles')
                date_changed = dir(filename);
                database_datafiles = database_mat.datafiles;
                for a = 1:length(database_datafiles)
                    current_entry = database_datafiles(a);
                    if strcmp(current_entry.filename, filename)
                        if current_entry.datenum >= date_changed.datenum
                            disp(['super: found identical or newer ' filename ' in database']);
                            updated = false;
                            obj = current_entry;
                            return
                        elseif current_entry.datenum < date_changed.datenum
                            disp(['super: found outdated ' filename ' in database']);
                            database_datafiles(a) = [];
                            break
                        end
                    end
                end
            end

            obj.parse(filename);

            if ~isprop(database_mat, 'datafiles')
                database_mat.datafiles = [obj];
            else
                database_mat.datafiles = [database_mat.datafiles, obj];
            end
            updated = true;
            return
        end
    end

    methods (Access = private)
        idx = get_measurement_type(obj, file_head);
        parse(obj, filename);
    end

    methods (Static)
        idx = get_instrument_type(file_head);
        [idx] = get_blocks(data, spacer);
    end
end