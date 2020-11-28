classdef PlotHelper
    properties (Hidden = true, Constant)
        defaultAxesBox = 'on';
        defaultLineLineWidth = 1.5;
        defaultAxesLineWidth = 1.5;
        defaultAxesFontWeight = 'bold';
    end
    
    methods (Static)
        function plot(x, y, group)
            if isempty(x) || isempty(y), return; end
            sp.PlotHelper.set_defaults();
            
            groups = unique(group);
            for a = 1:length(groups)
                rows = group == groups(a);
                plot(x(rows), y(rows), 'Tag', string(groups(a)));
            end
        end

        function scatter(x, y, group, marker)
            if isempty(x) || isempty(y), return; end
            sp.PlotHelper.set_defaults();

            groups = unique(group);
            for a = 1:length(groups)
                rows = group == groups(a);
                scatter(x(rows), y(rows), 27, 'filled', marker, 'Tag', string(groups(a)));
            end
        end

        function make_legend(units)
            current_axes = gca();
            objs = findobj('Parent', current_axes, '-regexp', 'Tag', '[^'']', 'Type', 'scatter', 'MarkerFaceAlpha', 1);
            
            tags = [];
            colors = [];
            for a = 1:length(objs)
                tags = [tags; str2double(objs(a).Tag)];
                colors = [colors; objs(a).CData];
            end
            [tags, ia, ~] = unique(tags);
            colors = colors(ia, :);

            dummy_plots = [];
            for a = 1:length(tags)
                dummy_plots = [dummy_plots; line(current_axes, NaN, NaN, 'LineStyle', 'none', 'Marker', 'none', 'Color', 'none')];
            end
            
            tags = arrayfun(@(x, y) sprintf('\\color[rgb]{%f,%f,%f}%.1f %s', colors(y, 1), colors(y, 2), colors(y, 3), x, units), tags, [1:size(colors, 1)]', 'UniformOutput', false);
            
            legend(dummy_plots, tags, 'Interpreter', 'tex');

        end
        
        function make_pretty(spacing, units)
            sp.PlotHelper.set_spacing(spacing);
            sp.PlotHelper.sort_plots();
            sp.PlotHelper.make_legend(units);
        end

        function set_color()
            current_axes = gca();
            cmap = jet(100);

            plots = findobj('Parent', current_axes, '-regexp', 'Tag', '[^'']');
            % for some reason plots.Tag throws an error when the array
            % contains lines and scatters, but works when homogenous
            temps = zeros(length(plots), 1);
            for a = 1:length(plots)
                temps(a) = str2double(plots(a).Tag);
            end
            cold = min(temps); hot = max(temps);
            for a = 1:length(plots)
                tag = str2double(plots(a).Tag);
                temp_scaled = floor(rescale(tag, 1, length(cmap), 'InputMin', cold, 'InputMax', hot));
                color_hsv = rgb2hsv(cmap(temp_scaled, :));
                color_hsv(3) = color_hsv(3) * 0.85;
                color_rgb = hsv2rgb(color_hsv);
                switch plots(a).Type
                    case 'line'
                        plots(a).Color = color_rgb;
                        plots(a).Color(4) = 1.0;
                    case 'scatter'
                        plots(a).CData = color_rgb;
                        plots(a).MarkerFaceAlpha = 1.0;
                end
            end
            sp.PlotHelper.sort_plots();
        end

        function sort_plots()
            current_axes = gca();
            objs = findobj('Parent', current_axes);
            tags = cellfun(@str2num, get(objs, 'Tag'));
            [~, idxs] = sort(tags, 'descend');
            current_axes.Children = objs(idxs);
            objs = findobj('Parent', current_axes, '-regexp', 'Tag', '[^'']', 'Type', 'scatter');
            uistack(objs, 'top');
            objs = findobj('Parent', current_axes, '-regexp', 'Tag', '[^'']', 'Type', 'scatter', 'MarkerFaceAlpha', 0.5);
            uistack(objs, 'bottom');
        end

        function set_spacing(spacing)
            sp.PlotHelper.set_color();
            current_axes = gca();

            plots = current_axes.Children;
            tags = zeros(length(plots), 1);
            for a = 1:length(plots)
                tags(a) = str2double(plots(a).Tag);
            end

            unique_tags = unique(tags);
            color_idxs = (1:(spacing + 1):length(unique_tags));
            grey_idxs = unique_tags(setdiff(1:end, color_idxs));
            for a = 1:length(grey_idxs)
                objs = findobj('Parent', current_axes, 'Tag', num2str(grey_idxs(a)));
                for b = 1:length(objs)
                    switch objs(b).Type
                        case 'line'
                            old_color = objs(b).Color;
                            new_color = rgb2hsv(old_color);
                            new_color(2) = 0;
                            new_color(3) = 0.75;
                            objs(b).Color = hsv2rgb(new_color);
                            objs(b).Color(4) = 0.5;
                        case 'scatter'
                            old_color = objs(b).CData;
                            new_color = rgb2hsv(old_color);
                            new_color(2) = 0;
                            new_color(3) = 0.75;
                            objs(b).CData = hsv2rgb(new_color);
                            objs(b).MarkerFaceAlpha = 0.5;
                    end
                end
            end
        end

        function set_defaults()
            set(groot,'defaultAxesBox', sp.PlotHelper.defaultAxesBox);
            set(groot,'defaultLineLineWidth', sp.PlotHelper.defaultLineLineWidth);
            set(groot,'defaultAxesLineWidth', sp.PlotHelper.defaultAxesLineWidth);
            set(groot,'defaultAxesFontWeight', sp.PlotHelper.defaultAxesFontWeight);
            set(groot,'defaultLegendBox', 'off');
            hold on;
            axis square;
        end
        
        function set_impedence_axes(plot_type)
            switch plot_type
                case 'in'
                    x_scale = 'log';
                    labels = {'Frequency (Hz)', '\chi\prime (emu mol^{-1})'};
                case 'out'
                    x_scale = 'log';
                    labels = {'Frequency (Hz)', '\chi\prime\prime (emu mol^{-1})'};
                case 'cole'
                    x_scale = 'linear';
                    labels = {'\chi\prime (emu mol^{-1})', '\chi\prime\prime (emu mol^{-1})'};
            end
            set(gca, 'XScale', x_scale);
            xlabel(labels{1}); ylabel(labels{2});
        end
        
        function set_arrhenius_axes()
            ax1 = gca;
            ax2 = axes('Position', get(ax1, 'Position'), 'Color', 'none');
            set(ax1, 'Box', 'off', 'XAxisLocation', 'top', 'YAxisLocation', 'right', 'Color', 'none');
            xlabel(ax1, '1/T (K^{-1})'); ylabel(ax1, 'ln(\tau)');
            set(ax2, 'Box', 'off');
            xlabel(ax2, 'T (K)'); ylabel(ax2, '\tau (s)');
            linkaxes([ax1, ax2]);
            linkprop([ax1, ax2], {'Position', 'PlotBoxAspectRatio'});
            uistack(gca, 'bottom');
            yticks(log(10.^(-5:4)));
            yticklabels({'10^{-5}', '10^{-4}', '10^{-3}', '10^{-2}', '10^{-1}', '1', '10', '10^{2}', '10^{3}', '10^{4}'});
            xlim(1 ./ [50 1.9]);
            xticks(1 ./ [16 8 4 2]);
            xticklabels(cellstr(num2str([16; 8; 4; 2])));
        end
    end
end