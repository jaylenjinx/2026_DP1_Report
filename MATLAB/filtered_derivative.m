function y = filtered_derivative(x, ts, fc)
%FILTERED_DERIVATIVE  Derivative of sampled signal with 1st-order LP smoothing
%   y = filtered_derivative(x, ts, fc)
%   x  : vector of samples
%   ts : sampling time (s)
%   fc : low-pass cutoff frequency (Hz) applied to the derivative
%
%   The filter implements: y[n] = alpha*y[n-1] + (1-alpha)*d[n]
%   where d[n] is the numerical derivative and alpha = exp(-2*pi*fc*ts).

    arguments
        x (:,1) double    % allow column; orientation preserved later
        ts (1,1) double {mustBePositive}
        fc (1,1) double {mustBeNonnegative}
    end

    N = numel(x);
    if N < 2
        y = zeros(size(x)); return;
    end

    % --- Numerical derivative (central difference, with proper edges) ---
    d = zeros(N,1);
    d(2:N-1) = (x(3:N) - x(1:N-2)) / (2*ts);   % central
    d(1)     = (x(2)   - x(1))      / ts;      % forward
    d(N)     = (x(N)   - x(N-1))    / ts;      % backward

    % --- One-pole low-pass on the derivative ---
    if fc == 0
        y = zeros(N,1);  % LP at 0 Hz -> derivative is fully suppressed
    else
        alpha = exp(-2*pi*fc*ts);        % pole at e^(−2πfc ts)
        b = 1 - alpha;                    % numerator
        a = [1  -alpha];                  % denominator
        y = filter(b, a, d);              % causal IIR, same length
    end

    % Match input orientation
    if isrow(x), y = y.'; end
end