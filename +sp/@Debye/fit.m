function fit(obj, varargin)
    data = obj.get_data();

    p = inputParser();
    validScalarPosInt = @(x) isnumeric(x) && isscalar(x) && (mod(x, 1) == 0) && (x >= 0);
    p.addRequired('fit_type', @ischar);
    p.addOptional('fit_num', 0, validScalarPosInt);
    p.parse(varargin{:});
    
    cc = contains(p.Results.fit_type, 'cc');
    hn = contains(p.Results.fit_type, 'hn');
    if ~cc && ~hn, error('unsupported fit type, use either cc or hn'); end
    
    obj.fits = [];
    obj.model_error = [];
    obj.model_data = [];
    
    model_data_vars = {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut'};
    
    max_fit_num = 1;
    temps = unique(data.TemperatureRounded);
    warning('off','all');
    for a = 1:length(temps)
        disp(['fitting ' num2str(temps(a)) ' K data']);
        rows = data.TemperatureRounded == temps(a);
        
        residual_old = 1E5;
        if ~(p.Results.fit_num == 0)
            fit_num = p.Results.fit_num;
        else
            fit_num = 1;
        end
        
        while 1
            disp(['    trying ' num2str(fit_num) ' process(es)']);
            [x0, lb, ub] = make_bounds(data.Frequency(rows), p.Results.fit_type, fit_num);
            disp(x0);
            problem = createOptimProblem('fmincon', 'x0', x0, ...
                'objective', @(b) sp.Debye.objective(data.Frequency(rows), ...
                [data.ChiIn(rows), data.ChiOut(rows)], ...
                fit_num * cc, ...
                fit_num * hn, b), ...
                'lb', lb, 'ub', ub, 'options', obj.fmincon_opts);

            [x0, ~, ~, ~, ~] = obj.gs.run(problem);
            [x02, ~, residual, ~, ~, ~, jacobian] = ...
                lsqcurvefit(@(b, xdata) sp.Debye.model_wrapper(xdata, fit_num * cc, fit_num * hn, b), ...
                x0, data.Frequency(rows), [data.ChiIn(rows), data.ChiOut(rows)], [], [], obj.lsqcurvefit_opts);
            ci = nlparci(x02, residual, 'Jacobian', jacobian);
            residual = sum(power(residual(:, 2), 2));
            disp(['        residual improvement factor: ' num2str(residual_old / residual)]);

            if p.Results.fit_num ~= 0
                max_fit_num = p.Results.fit_num;
                break; 
            elseif ((residual_old / residual) < 7)
                x0 = x0_old;
                ci = ci_old;
                fit_num = fit_num - 1;
                if fit_num > max_fit_num, max_fit_num = fit_num; end
                break;
            elseif (fit_num == 3) 
                max_fit_num = 3;
                break;
            else
                residual_old = residual;
                x0_old = x0;
                ci_old = ci;
                fit_num = fit_num + 1;
            end
        end
        warning('on','all')
        
        xmodel = logspace(log10(min(data.Frequency(rows))), log10(max(data.Frequency(rows))), 100)';
        ymodel = sp.Debye.model(xmodel, fit_num * cc, fit_num * hn, x0);
        
        fit_padding = NaN(1, (3 - fit_num) * ((cc * 3) + (hn * 4)));
        error_padding = NaN(1, (3 - fit_num) * ((cc * 6) + (hn * 8)));
        ci = reshape(ci.', 1, []);
        
        new_fits = [temps(a), x0(1:end-1), fit_padding, x0(end)];
        new_errors = [temps(a), ci(1:end-2), error_padding, ci(end-1:end)];
        new_model = array2table([temps(a).*ones(length(xmodel), 1), xmodel, real(ymodel), -imag(ymodel)], 'VariableNames', model_data_vars);

        obj.fits = [obj.fits; new_fits];
        obj.model_error = [obj.model_error; new_errors];
        obj.model_data = [obj.model_data; new_model];
    end
    
    fit_vars = make_table_vars(p.Results.fit_type, max_fit_num);
    model_error_vars = make_table_vars([p.Results.fit_type '_error'], max_fit_num);
    
    obj.fits = rmmissing(obj.fits, 2, 'MinNumMissing', size(obj.fits, 1));
    obj.fits = array2table(obj.fits, 'VariableNames', fit_vars);
    
    obj.model_error = rmmissing(obj.model_error, 2, 'MinNumMissing', size(obj.model_error, 1));
    obj.model_error = array2table(obj.model_error, 'VariableNames', model_error_vars);
end

function output = sort_fits(fits, fit_type)
%{
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
%}
end

function [x0, lb, ub] = make_bounds(frequency, fit_type, num)
    min_tau = 1 / (1.05 * 2 * pi * max(frequency));
    max_tau = 1 / (0.95 * 2 * pi * min(frequency));
    rands = 10.^(((log10(max_tau) - log10(min_tau)) .* rand(1, num)) + log10(min_tau));
    
    switch fit_type
        case 'cc'
            idxs = 1:3:(num * 3);
            x0 = [mean([min_tau max_tau]), 0.05, 1];
            lb = [min_tau, 1E-7, 0.1];
            ub = [max_tau, 0.2, 10];
        case 'hn'
            idxs = 1:4:(num * 4);
            x0 = [mean([min_tau max_tau]), 0.9, 1, 5];
            lb = [min_tau, 0.01, 0.01, 1E-1];
            ub = [max_tau, 1, 1, 55];
    end
    chi_s_x0 = [1E-3];
    chi_s_lb = [1E-4];
    chi_s_ub = [1E-1];

    x0 = [repmat(x0, 1, num), chi_s_x0];
    x0(idxs) = rands;
    lb = [repmat(lb, 1, num), chi_s_lb];
    ub = [repmat(ub, 1, num), chi_s_ub];
end

function output = make_table_vars(table_type, num)
    fit_types = {'cc', 'hn', 'cc_error', 'hn_error'};
    cc_vars = {'cc_tau_', 'cc_alpha_', 'cc_chi_t_'};
    hn_vars = {'hn_tau_', 'hn_alpha_', 'hn_beta_', 'hn_chi_t_'};
    cc_error_vars = {'cc_tau_ci_neg_', 'cc_tau_ci_pos_', 'cc_alpha_ci_neg_', 'cc_alpha_ci_pos_', 'cc_chi_t_ci_neg_', 'cc_chi_t_ci_pos_'};
    hn_error_vars = {'hn_tau_ci_neg_', 'hn_tau_ci_pos_', 'hn_alpha_ci_neg_', 'hn_alpha_ci_pos_', 'hn_beta_ci_neg_', 'hn_beta_ci_pos_', 'hn_chi_t_ci_neg_', 'hn_chi_t_ci_pos_'};
    fit_vars = {cc_vars, hn_vars, cc_error_vars, hn_error_vars};

    if ~contains(table_type, 'error'), chi_s = {'chi_s'}; else, chi_s = {'chi_s_neg', 'chi_s_pos'}; end

    output = fit_vars{contains(fit_types, table_type)};
    output = cellfun(@(x, y) [x num2str(y)], repmat(output, 1, num), num2cell(ceil((1:length(output)*num)/length(output))), 'UniformOutput', false);
    output = ['TemperatureRounded', output(:)', chi_s];
end