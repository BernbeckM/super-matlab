classdef PlotHelper
    properties (Hidden = true, Constant)
        colorAlpha = 0.8;
        
        defaultAxesBox = 'on';
        defaultLineLineWidth = 1.0;
        defaultAxesLineWidth = 1.5;
        defaultAxesFontWeight = 'bold';
    end
    
    methods (Static)
        function plotDataset(x, y, group, plotType, colorSpacing, marker, varargin)
            if isempty(x) || isempty(y), return; end
            PlotHelper.setDefaults();
            p = inputParser;
            p.addParameter('Axes', gca);
            p.parse(varargin{:});
            groups = unique(group);
            toggle = double(~mod(colorSpacing+(0:length(groups)-1), colorSpacing));

            for a = 1:length(groups)
                rows = group == groups(a);
                switch plotType
                    case 'scatter'
                        scatter(p.Results.Axes, x(rows), y(rows), [], PlotHelper.colorSelector(groups(a), toggle(a)), 'filled', marker, 'MarkerFaceAlpha', PlotHelper.colorAlpha + (1 - PlotHelper.colorAlpha)*toggle(a));
                    case 'line'
                        currentPlot = plot(p.Results.Axes, x(rows), y(rows), 'Color', PlotHelper.colorSelector(groups(a), toggle(a)));
                        currentPlot.Color(4) = PlotHelper.colorAlpha + (1 - PlotHelper.colorAlpha)*toggle(a);
                end
            end
        end

        function color = colorSelector(temperature, a)
            color = hsv2rgb([1-tanh(temperature/30)' double(~mod(a + 3, 3)) ones(length(temperature), 1)*0.9]);
        end

        function setDefaults()
            set(groot,'defaultAxesBox', PlotHelper.defaultAxesBox);
            set(groot,'defaultLineLineWidth', PlotHelper.defaultLineLineWidth);
            set(groot,'defaultAxesLineWidth', PlotHelper.defaultAxesLineWidth);
            set(groot,'defaultAxesFontWeight', PlotHelper.defaultAxesFontWeight);
            hold on;
            axis square;
        end
        
        function setLimits()
            currentXLim = xlim; xRange = currentXLim(2) - currentXLim(1);
            currentYLim = ylim; yRange = currentYLim(2) - currentYLim(1);
            currentXScale = get(gca, 'XScale');
            switch currentXScale
                case 'linear'
                    newXLim = 0.05*[-xRange xRange] + currentXLim;
                case 'log'
                    newXLim = power(10, 0.05*[-log10(xRange) log10(xRange)] + log10(currentXLim));
            end
            currentYScale = get(gca, 'YScale');
            switch currentYScale
                case 'linear'
                    newYLim = 0.04*[-yRange yRange] + currentYLim;
                case 'log'
                    newYLim = power(10, 0.05*[-log10(yRange) log10(yRange)] + log10(currentYLim));
            end

            xlim(newXLim);
            ylim(newYLim);
        end
        
        function setArrheniusAxes()
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