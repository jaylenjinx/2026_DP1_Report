# Script edits implied by the analytical model

These follow directly from the transfer functions derived in `main.tex`.
Run these, then paste the fitted coefficients into the blanks in Q3.1–Q3.3.

## `main_Q31_Q32.m` — Section 3, identifying `Guvc(s)`

Analytical structure: `Guvc(s) = a/(s+b)` → **1 pole, 0 zeros**, input `Vm`, output `vc`.

```matlab
y  = vc;                        % TF output: cart SPEED (not xc_m)
u  = Vm;                        % TF input : motor voltage
data = iddata(y,u,ts);
np = 1;                         % from (s + b)
nz = 0;
Guvc_id = tfest(data,np,nz)
Gux_id  = (1/s)*Guvc_id;
```

## `main_Q31_Q32.m` — Section 4, identifying `Gaca(s)`

Analytical structure: `Gaca(s) = (-1/l)/(s^2 + (bp/(m*l^2))*s + g/l)` → **2 poles, 0 zeros**,
input `ac`, output `alpha_rad`.

```matlab
y  = alpha_rad;                 % TF output: angle in rad
u  = ac;                        % TF input : cart acceleration
data = iddata(y,u,ts);
np = 2;                         % pendulum resonance
nz = 0;
Gaca_id = tfest(data,np,nz)
Gxa_id  = (s^2)*Gaca_id;
```

## Extracting the parameters (append to `main_Q31_Q32.m` or start of `main_Q33_Q34.m`)

```matlab
M = 0.22; m = 0.1; g = 9.81;    % NOTE: the shipped main_Q33_Q34.m has g = 8.1

% --- from Gaca_id: l and bp ---
[kn, kd] = tfdata(Gaca_id,'v');
kd = kd/kd(1);  kn = kn/ kd(1);         % monic denominator
a1 = kd(2);                              % = bp/(m*l^2)
a0 = kd(3);                              % = g/l
khat = kn(end);                          % = -1/l   (consistency check)

l  = g/a0;
bp = m*l^2*a1;
L  = 1.5*l;
fprintf('l = %.4f m  (check -1/khat = %.4f)\n', l, -1/khat);

% --- from Guvc_id: Kv and bc ---
[an, ad] = tfdata(Guvc_id,'v');
ahat = an(end)/ad(1);
bhat = ad(2)/ad(1);
Kv = (M+m)*ahat;
bc = (M+m)*bhat;

fprintf('L = %.4f m | bp = %.5f | Kv = %.4f N/V | bc = %.4f Ns/m\n', L,bp,Kv,bc);
```

## Q3.4 reminders

- Remark 6: the **linear** branch must use the *full* `Gux(s)` (eq. 33–34 of the report),
  not the simplified `Gux_tilde(s)`.
- The nonlinear block implements eqs. (50)–(51) of the report, i.e. the mass matrix
  inverted for `xc_ddot` and `alpha_ddot`.
- Add the team members' names inside `sim_2026_cart_pend.slx` before submitting.
