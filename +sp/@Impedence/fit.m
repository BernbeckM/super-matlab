function fit(obj, varargin)
    data = obj.get_data();

    p = inputParser;
    validScalarPosInt = @(x) isnumeric(x) && isscalar(x) && (mod(x, 1) == 0) && (x >= 0);
    p.addParameter('CC', 1, validScalarPosInt);
    p.addParameter('HN', 0, validScalarPosInt);
    p.parse(varargin{:});

    obj.fits = table;
    obj.model_data = table;
    obj.model_error = table;

    ccx0 = [1/(2*pi*((max(data.Frequency) + min(data.Frequency))/2)), 0.3, 1];
    cclb = [1/(5*2*pi*max(data.Frequency)), 0, 0.1];
    %ccub = [200, 0.8, 20];
    ccub = [1/(0.01*2*pi*min(data.Frequency)), 0.8, 20];
    hnx0 = [1/(2*pi*((max(data.Frequency) + min(data.Frequency))/2)), 0.9, 1, 5];
    hnlb = [1/(2*pi*max(data.Frequency)*1.05), 0.01, 0.01, 1E-1];
    hnub = [1/(2*pi*min(data.Frequency)*0.95), 1, 1, 55];

    chiInfx0 = [0];
    chiInflb = [1E-8];
    chiInfub = [10];
    %chiInfub = [max(data.ChiOut)];

    x0 = [repmat(ccx0, 1, p.Results.CC), repmat(hnx0, 1, p.Results.HN), chiInfx0];
    lb = [repmat(cclb, 1, p.Results.CC), repmat(hnlb, 1, p.Results.HN), chiInflb];
    ub = [repmat(ccub, 1, p.Results.CC), repmat(hnub, 1, p.Results.HN), chiInfub];

    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', ...
                                  'FunctionTolerance', 1e-23, 'OptimalityTolerance', 1e-23, 'StepTolerance', 1e-23, ...
                                  'ObjectiveLimit', 1e-23, 'Display', 'off', 'ConstraintTolerance', 1E-23);
    opts2 = optimoptions('lsqcurvefit', 'Algorithm', 'Levenberg-Marquardt', ...
                                  'FunctionTolerance', 1e-10, 'OptimalityTolerance', 1e-10, 'StepTolerance', 1e-10, ...
                                  'Display', 'off');
    gs = GlobalSearch('MaxTime', 30, 'Display', 'off');

    temps = unique(data.TemperatureRounded);
    %xmodel = logspace(log10(min(data.Frequency)), log10(max(data.Frequency)), 100)';

    cc_vars = {'cc_tau_', 'cc_alpha_', 'cc_chi_t_'};
    cc_vars = cellfun(@(x, y) [x num2str(y)], repmat(cc_vars, 1, p.Results.CC), num2cell(ceil((1:3*p.Results.CC)/3)), 'UniformOutput', false);
    cc_error_vars = {'cc_tau_ci_neg_', 'cc_tau_ci_pos_', 'cc_alpha_ci_neg_', 'cc_alpha_ci_pos_', 'cc_chi_t_ci_neg_', 'cc_chi_t_ci_pos_'};
    cc_error_vars = cellfun(@(x, y) [x num2str(y)], repmat(cc_error_vars, 1, p.Results.CC), num2cell(ceil((1:6*p.Results.CC)/6)), 'UniformOutput', false);
    hn_vars = {'hn_tau_', 'hn_alpha_', 'hn_beta_', 'hn_chi_t_'};
    hn_vars = cellfun(@(x, y) [x num2str(y)], repmat(hn_vars, 1, p.Results.HN), num2cell(ceil((1:4*p.Results.HN)/4)), 'UniformOutput', false);
    hn_error_vars = {'hn_tau_ci_neg_', 'hn_tau_ci_pos_', 'hn_alpha_ci_neg_', 'hn_alpha_ci_pos_', 'hn_beta_ci_neg_', 'hn_beta_ci_pos_', 'hn_chi_t_ci_neg_', 'hn_chi_t_ci_pos_'};
    hn_error_vars = cellfun(@(x, y) [x num2str(y)], repmat(hn_error_vars, 1, p.Results.HN), num2cell(ceil((1:8*p.Results.HN)/8)), 'UniformOutput', false);
    fit_vars = {'TemperatureRounded', cc_vars, hn_vars, 'chi_s'};
    error_vars = {'TemperatureRounded', cc_error_vars, hn_error_vars, 'chi_s_ci_neg', 'chi_s_ci_pos'};
    model_vars = {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut'};

    for a = 1:length(temps)
        disp(['Fitting ' num2str(temps(a)) 'K data.']);
        rows = data.TemperatureRounded == temps(a);
        xmodel = logspace(log10(min(data.Frequency(rows))), log10(max(data.Frequency(rows))), 100)';

        problem = createOptimProblem('fmincon', 'x0', x0, ...
                                     'objective', @(b) sp.Impedence.objective(data.Frequency(rows), [data.ChiIn(rows), data.ChiOut(rows)], p.Results.CC, p.Results.HN, b), ...
                                     'lb', lb, 'ub', ub, 'options', opts); % , 'nonlcon', @(b) constraints(p.Results.CC, p.Results.HN, b)
        [x0, ~, ~, ~, ~] = gs.run(problem);
        [x02, ~, residual, ~, ~, ~, jacobian] = lsqcurvefit(@(b, xdata) sp.Impedence.model_wrapper(xdata, p.Results.CC, p.Results.HN, b), x0, data.Frequency(rows), [data.ChiIn(rows), data.ChiOut(rows)], [], [], opts2);
        ci = nlparci(x02, residual, 'Jacobian', jacobian);

        cc_entries = [];
        cc_errors = [];
        if p.Results.CC > 0
            cc_entries = x0(1:3*p.Results.CC);
            cc_errors = ci(1:3*p.Results.CC,:);
            if p.Results.CC == 1
                cc_errors = [cc_errors(:,1), cc_errors(:,2)].';
                cc_errors = cc_errors(:)';
            else
                [~, I] = sort(cc_entries(1:3:3*p.Results.CC));
                J = cell2mat(arrayfun(@(x) 3*(x-1)+(1:3), I, 'UniformOutput', false));
                cc_entries = cc_entries(J);
                cc_errors = [cc_errors(J',1), cc_errors(J',2)].';
                cc_errors = cc_errors(:)';
            end
        end
        hn_entries = [];
        hn_errors = [];
        if p.Results.HN > 0
            hn_entries = x0(p.Results.CC*3+(1:4*p.Results.HN));
            hn_errors = ci(p.Results.CC*3+(1:4*p.Results.HN),:);
            if p.Results.HN == 1
                hn_errors = [hn_errors(:,1), hn_errors(:,2)].';
                hn_errors = hn_errors(:)';
            else
                [~, I] = sort(hn_entries(1:4:4*p.Results.HN));
                J = cell2mat(arrayfun(@(x) 4*(x-1)+(1:4), I, 'UniformOutput', false));
                hn_entries = hn_entries(J);
                hn_errors = [hn_errors(J',1), hn_errors(J',2)].';
                hn_errors = hn_errors(:)';
            end
        end
        x0 = [cc_entries, hn_entries, x0(end)];
        new_errors = array2table([temps(a), cc_errors, hn_errors, ci(end,1), ci(end,2)], 'VariableNames', [error_vars{:}]);
        new_fits = array2table([temps(a), x0], 'VariableNames', [fit_vars{:}]);
        ymodel = sp.Impedence.model(xmodel, p.Results.CC, p.Results.HN, x0);
        new_model = array2table([temps(a).*ones(length(xmodel), 1), xmodel, real(ymodel), -imag(ymodel)], 'VariableNames', model_vars);

        obj.fits = [obj.fits; new_fits];
        obj.model_data = [obj.model_data; new_model];
        obj.model_error = [obj.model_error; new_errors];
    end
end