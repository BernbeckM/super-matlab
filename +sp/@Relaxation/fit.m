function fit(obj, varargin)
    p = inputParser;
    validLogical = @(x) islogical(x);
    
    p.addParameter('orbach', 1, validLogical);
    p.addParameter('raman', 0, validLogical);
    p.addParameter('qtm', 0, validLogical);
    p.addParameter('dipole', 0, validLogical);
    p.parse(varargin{:})

    obj.fits = [];
    obj.model_data = [];

    if ~(p.Results.orbach) && ~(p.Results.raman) && ~(p.Results.raman) && ~(p.Results.dipole)
        disp('compound unable to RELAX')
        return;
    end

    orbachx0 = [150, 1E-10]; ramanx0 = [5E-8, 8]; qtmx0 = [1E-4]; dipolex0 = [0.5, 1E5];
    orbachlb = [80, 1E-12]; ramanlb = [1E-9, 5]; qtmlb = [1E-6]; dipolelb = [0.001, 1E1];
    orbachub = [250, 1E-7]; ramanub = [1E-5, 9]; qtmub = [1E4]; dipoleub = [4, 1E6];

    x0 = [repmat(orbachx0, 1, p.Results.orbach), repmat(ramanx0, 1, p.Results.raman), repmat(qtmx0, 1, p.Results.qtm), repmat(dipolex0, 1, p.Results.dipole)];
    lb = [repmat(orbachlb, 1, p.Results.orbach), repmat(ramanlb, 1, p.Results.raman), repmat(qtmlb, 1, p.Results.qtm), repmat(dipolelb, 1, p.Results.dipole)];
    ub = [repmat(orbachub, 1, p.Results.orbach), repmat(ramanub, 1, p.Results.raman), repmat(qtmub, 1, p.Results.qtm), repmat(dipoleub, 1, p.Results.dipole)];

    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', ...
                          'FunctionTolerance', 1e-40, 'OptimalityTolerance', 1e-40, 'StepTolerance', 1e-40, ...
                          'ObjectiveLimit', 1e-40, 'Display', 'off', 'ConstraintTolerance', 1E-40);
    gs = GlobalSearch('MaxTime', 45, 'Display', 'off', 'NumTrialPoints', 50000, 'NumStageOnePoints', 4000);
    ms = MultiStart('UseParallel', true, 'FunctionTolerance', 1e-40, 'XTolerance', 1e-40);
    
    problem = createOptimProblem('fmincon', 'x0', x0, 'objective', @(b) sp.Relaxation.objective(obj.data.Temperature, log(1./obj.data.tau), p.Results.orbach, p.Results.raman, p.Results.qtm, p.Results.dipole, b), ...
                             'lb', lb, 'ub', ub, 'options', opts);
    %[obj.fits, ~, ~, ~, ~] = gs.run(problem);
    [obj.fits, residual0] = ms.run(problem, 2000);
    xmodel = logspace(log10(min(obj.data.Temperature)), log10(max(obj.data.Temperature)), 100)';
    ymodel = sp.Relaxation.model(xmodel, p.Results.orbach, p.Results.raman, p.Results.qtm, p.Results.dipole, obj.fits);
    varnames = {repmat({'Ueff', 'tau_0'}, 1, p.Results.orbach), repmat({'C', 'n'}, 1, p.Results.raman), repmat({'qtm'}, 1, p.Results.qtm), repmat({'Deff', 'D_0'}, 1, p.Results.dipole)};
    obj.fits = array2table(obj.fits, 'VariableNames', [varnames{:}]);
    model_data = [xmodel, 1./ymodel];
    obj.model_data = array2table(model_data, 'VariableNames', {'Temperature', 'tau'});
end