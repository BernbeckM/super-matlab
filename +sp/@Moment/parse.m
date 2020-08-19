function parse(obj)
    to_add = array2table([obj.raw{:, sp.DataFile.MomentFieldsRaw}], 'VariableNames', sp.DataFile.MomentFieldsRaw);
    
    to_add.Moment = to_add.Moment - (sp.DataFile.EicosaneXdm .* obj.header.EicosaneMoles .* to_add.Field) - (obj.header.Xdm .* obj.header.Moles .* to_add.Field);
    to_add.MomentErr = to_add.MomentErr - (sp.DataFile.EicosaneXdm .* obj.header.EicosaneMoles .* to_add.Field) - (obj.header.Xdm .* obj.header.Moles .* to_add.Field);
    
    to_add.MomentMass = to_add.Moment ./ (obj.header.Mass / 1000);
    to_add.MomentMassErr = to_add.MomentErr ./ (obj.header.Mass / 1000);
    
    to_add.MomentMoles = to_add.Moment ./ obj.header.Moles;
    to_add.MomentMolesErr = to_add.MomentErr ./ obj.header.Moles;
    
    to_add.MomentEff = to_add.MomentMoles ./ 5585;
    to_add.MomentEffErr = to_add.MomentMolesErr ./ 5585;
    
    to_add.Chi = to_add.MomentMoles ./ to_add.Field;
    to_add.ChiErr = to_add.MomentMolesErr ./ to_add.Field;
    
    to_add.ChiT = to_add.Chi .* to_add.Temperature;
    to_add.ChiTErr = to_add.ChiErr .* to_add.Temperature;
    
    to_add.TemperatureRounded = round(to_add.Temperature ./ 0.1) .* 0.1;
    
    obj.data = [obj.data; to_add];
end