function fit(obj, varargin)
    FitOpts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'Display', 'off');

    p = inputParser;
    validLogical = @(x) islogical(x);
    validScalarPosInt = @(x) isnumeric(x) && isscalar(x) && (mod(x, 1) == 0) && (x >= 0);
    
    p.addParameter('orbach', 1, validLogical);
    p.addParameter('raman', 0, validLogical);
    p.addParameter('qtm', 0, validLogical);
    p.addParameter('dipole', 0, validLogical);
    
    p.parse(varargin{:})

    obj.fits = [];
    obj.model_data = [];

    if ~(p.Results.orbach) && ~(p.Results.raman) && ~(p.Results.raman)
        disp('compound unable to RELAX')
        return;
    end

    orbachx0 = [150, 1E-10]; ramanx0 = [5E-6, 8]; qtmx0 = [1E-4]; dipolex0 = [0.5, 100];
    orbachlb = [80, 1E-12]; ramanlb = [1E-10, 5]; qtmlb = [1E-6]; dipolelb = [0.1, 1];
    orbachub = [250, 1E-8]; ramanub = [1E-5, 9]; qtmub = [1E4]; dipoleub = [3, 5E4];

    x0 = [repmat(orbachx0, 1, p.Results.orbach), repmat(ramanx0, 1, p.Results.raman), repmat(qtmx0, 1, p.Results.qtm), repmat(dipolex0, 1, p.Results.dipole)];
    lb = [repmat(orbachlb, 1, p.Results.orbach), repmat(ramanlb, 1, p.Results.raman), repmat(qtmlb, 1, p.Results.qtm), repmat(dipolelb, 1, p.Results.dipole)];
    ub = [repmat(orbachub, 1, p.Results.orbach), repmat(ramanub, 1, p.Results.raman), repmat(qtmub, 1, p.Results.qtm), repmat(dipoleub, 1, p.Results.dipole)];

    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', ...
                          'FunctionTolerance', 1e-38, 'OptimalityTolerance', 1e-38, 'StepTolerance', 1e-38, ...
                          'ObjectiveLimit', 1e-38, 'Display', 'off', 'ConstraintTolerance', 1E-38);
    gs = GlobalSearch('MaxTime', 45, 'Display', 'off', 'NumTrialPoints', 10000, 'NumStageOnePoints', 2000);
    problem = createOptimProblem('fmincon', 'x0', x0, 'objective', @(b) sp.Relaxation.objective(obj.data.Temperature, log(1./obj.data.tau), p.Results.orbach, p.Results.raman, p.Results.qtm, p.Results.dipole, b), ...
                             'lb', lb, 'ub', ub, 'options', opts);
    [obj.fits, ~, ~, ~, ~] = gs.run(problem);
    obj.fits
    xmodel = logspace(log10(min(obj.data.Temperature)), log10(max(obj.data.Temperature)), 100)';
    ymodel = sp.Relaxation.model(xmodel, p.Results.orbach, p.Results.raman, p.Results.qtm, p.Results.dipole, obj.fits);
    varnames = {repmat({'Ueff', 'tau_0'}, 1, p.Results.orbach), repmat({'C', 'n'}, 1, p.Results.raman), repmat({'qtm'}, 1, p.Results.qtm), repmat({'Deff', 'D_0'}, 1, p.Results.dipole)};
    obj.fits = array2table(obj.fits, 'VariableNames', [varnames{:}]);
    model_data = [xmodel, 1./ymodel];
    obj.model_data = array2table(model_data, 'VariableNames', {'Temperature', 'tau'});
end