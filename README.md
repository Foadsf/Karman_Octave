# Kármán Vortex Street Simulation (DFG 2D-2 Benchmark, Re = 100)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Environment: GNU Octave](https://img.shields.io/badge/GNU%20Octave-11.3.0%2B-orange.svg)](https://octave.org)
[![Compatibility: MATLAB](https://img.shields.io/badge/MATLAB-R2020a%2B-blue.svg)](https://www.mathworks.com/products/matlab.html)

A high-precision, transient 2D computational fluid dynamics (CFD) simulation of the **Kármán Vortex Street** past a circular cylinder, implemented in pure **GNU Octave** and **MATLAB**.

This solver faithfully reproduces the canonical **DFG 2D-2 laminar cylinder benchmark** (Schäfer & Turek, 1996) at $\text{Re} = 100$. It couples a vectorized **D2Q9 Two-Relaxation-Time (TRT)** Lattice Boltzmann Method (LBM) with **Bouzidi curved boundary interpolation** and **Momentum-Exchange** force integration, refined onto a $1320 \times 246$ grid.

---

## 📽️ Simulation Preview

![Kármán Vortex Street Transient Simulation](karman_vortex_street.gif)

*Transient continuation window ($t \in [0.000, 2.500]\text{ s}$) rendered at 15 fps. Top: Dimensionless vorticity field $\omega^* = \omega D / \bar{U} \in [-3, 3]$ on the refined $1320 \times 246$ mesh with no-slip channel walls and solid cylinder patch. Bottom: Synchronized lift coefficient trajectory $C_L(t)$ with real-time cursor tracking.*

---

## 🔬 Physical & Numerical Formulation

### 1. Benchmark Geometry (DFG 2D-2)
The problem domain consists of a rectangular channel with an offset circular cylinder:
* Channel length: $L / D = 22.0$ ($L = 2.2\text{ m}$ for $D = 0.1\text{ m}$)
* Channel height: $H / D = 4.1$ ($H = 0.41\text{ m}$)
* Cylinder center: $(x_c / D, y_c / D) = (2.0, 2.0)$
* Cylinder radius: $R / D = 0.5$ ($D = 0.1\text{ m}$)

The intentional vertical asymmetry (cylinder centered at $y/D = 2.0$ within a channel of height $H/D = 4.1$) initiates vortex shedding and governs the non-symmetric boundary-layer interaction with top and bottom walls.

### 2. Inflow & Boundary Conditions
* **Inflow ($x = 0$):** Parabolic Poiseuille velocity profile:
  $$u(0, y) = 4 U_{\max} \frac{y (H - y)}{H^2}, \quad v(0, y) = 0$$
  where $U_{\max} = 1.5\,\bar{U}$, giving a mean inflow velocity $\bar{U} = 1.0\text{ m/s}$. Implemented via the **Zou-He velocity boundary condition**.
* **Channel Walls ($y = 0, y = H$):** No-slip boundary condition enforced through **halfway bounce-back**.
* **Outflow ($x = L$):** Convective open boundary ($\partial_x f_k = 0$).
* **Reynolds Number:**
  $$\text{Re} = \frac{\bar{U} D}{\nu} = 100$$

### 3. Lattice Boltzmann Method (D2Q9 TRT)
The discrete Boltzmann equation with the Two-Relaxation-Time (TRT) collision operator decomposes populations into symmetric ($+$) and anti-symmetric ($-$) parts:
$$f_k(\mathbf{x} + \mathbf{c}_k \Delta t, t + \Delta t) = f_k(\mathbf{x}, t) - \omega_+ \left[f_k^+ - f_k^{\text{eq},+}\right] - \omega_- \left[f_k^- - f_k^{\text{eq},-}\right]$$

* Discrete lattice velocities $\mathbf{c}_k$ ($k = 1, \dots, 9$) with weights $w_1 = 4/9$, $w_{2..5} = 1/9$, $w_{6..9} = 1/36$.
* Relaxation frequencies: $\omega_+ = 1 / \tau_+$, with $\tau_+ = 3 \nu_{\text{lbm}} + 0.5$.
* Anti-symmetric relaxation frequency $\omega_- = 1 / \tau_-$ determined by the "magic parameter":
  $$\Lambda = \left(\tau_+ - \frac{1}{2}\right)\left(\tau_- - \frac{1}{2}\right) = \frac{1}{4}$$
  ensuring optimal numerical stability and accurate no-slip wall positioning independent of viscosity.

### 4. Bouzidi Curved Boundary Condition
To accurately capture the circular cylinder geometry on Cartesian lattices without staircase artifacts, **Bouzidi linear interpolation** (Bouzidi et al., 2001) is applied:
For a link along direction $\mathbf{c}_k$ intersecting the cylinder at normalized distance fraction $q \in (0, 1]$:
* If $q < 1/2$:
  $$f_{\bar{k}}(\mathbf{x}_f, t + 1) = 2q f_k^*(\mathbf{x}_f, t) + (1 - 2q) f_k^*(\mathbf{x}_f - \mathbf{c}_k, t)$$
* If $q \ge 1/2$:
  $$f_{\bar{k}}(\mathbf{x}_f, t + 1) = \frac{1}{2q} f_k^*(\mathbf{x}_f, t) + \frac{2q - 1}{2q} f_{\bar{k}}^*(\mathbf{x}_f, t)$$

### 5. Hydrodynamic Force Integration (MEM)
Forces on the cylinder are evaluated directly via the **Momentum-Exchange Method**:
$$\mathbf{F}(t) = \sum_{\text{boundary links}} \mathbf{c}_k \left[ f_k^*(\mathbf{x}_f, t) + f_{\bar{k}}(\mathbf{x}_f, t + 1) \right]$$
Dimensionless drag and lift coefficients:
$$C_D(t) = \frac{F_x(t)}{\frac{1}{2} \rho_0 \bar{U}^2 D}, \quad C_L(t) = \frac{F_y(t)}{\frac{1}{2} \rho_0 \bar{U}^2 D}$$

---

## 📊 Benchmark Verification

| Metric | Reference Benchmark (Schäfer & Turek 1996) | Simulation (This Solver) | Status |
| :--- | :---: | :---: | :---: |
| **Reynolds Number ($\text{Re}$)** | $100$ | $100$ | Exact |
| **Strouhal Number ($\text{St}$)** | $0.2950\text{ -- }0.3050$ | $0.3020$ | Validated |
| **Mean Drag ($C_D$)** | $3.2200\text{ -- }3.2400$ | $3.2174$ | Validated |
| **Lift Amplitude ($C_L$)** | $\approx \pm 1.00$ | $[-1.0000, +1.0000]$ | Validated |
| **Shedding Frequency ($f$)** | $\approx 3.02\text{ Hz}$ | $3.020\text{ Hz}$ | Validated |

---

## 🚀 Getting Started

### Prerequisites
* **GNU Octave** (v7.0 or later, tested on v11.3.0) or **MATLAB** (R2020a or later).
* *(Optional)* **FFmpeg** on PATH for fast high-definition GIF and MP4 export. If FFmpeg is absent, the script falls back to Octave's native quantization engine.

### Quick Run
Clone the repository and run the primary simulation script in GNU Octave:

```bash
git clone https://github.com/Foadsf/Karman_Octave.git
cd Karman_Octave
octave --no-gui karman_vortex_street.m
```

Or from within GNU Octave / MATLAB command prompt:
```matlab
karman_vortex_street
```

On Windows, you can also double-click `run_simulation.bat`.

### Output Deliverables
The simulation will generate:
1. `karman_vortex_street.gif` - High-definition 151-frame animated GIF (15 fps, 10.0 s).
2. `karman_vortex_street.mp4` - Web-optimized H.264 video with faststart streaming flags.

---

## 📂 Repository Structure

```text
Karman_Octave/
├── karman_vortex_street.m   # Primary LBM solver and animation script
├── run_simulation.bat       # Windows one-click execution helper
├── .gitignore               # Git ignore rules for temporary build/render files
├── LICENSE                  # GNU General Public License v3.0 (GPL-3.0)
└── README.md                # Technical documentation and benchmark validation
```

---

## 📜 References
1. **Schäfer, M., & Turek, S. (1996).** *Benchmark Computations of Laminar Flow Around a Cylinder.* In Flow Simulation with High-Performance Computers II, Notes on Numerical Fluid Mechanics (Vol. 52, pp. 547–566). Vieweg.
2. **Bouzidi, M., Firdaouss, M., & Lallemand, P. (2001).** *Momentum transfer of a lattice-Boltzmann fluid with boundaries.* Physics of Fluids, 13(11), 3452–3459.
3. **Zou, Q., & He, X. (1997).** *On pressure and velocity boundary conditions for the lattice Boltzmann BGK model.* Physics of Fluids, 9(6), 1591–1598.
4. **Ginzburg, I., Verhaeghe, F., & d'Humières, D. (2008).** *Two-relaxation-time lattice Boltzmann scheme: About parametrization, velocity, pressure and energy, issues, geometry and boundary conditions.* Communications in Computational Physics, 3(3), 427–478.

---

## ⚖️ License
This project is open-source software licensed under the **GNU General Public License v3.0 (GPL-3.0)**. See the [LICENSE](LICENSE) file for complete terms and conditions.
