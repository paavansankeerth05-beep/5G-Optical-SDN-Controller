# 5G-Optical Intent-Based Cross-Layer Controller

An interactive, event-driven Software-Defined Networking (SDN) Core Controller Telemetry Dashboard built in MATLAB. This application simulates cross-layer optimization for 5G network slicing over a Wavelength Division Multiplexing (WDM) optical transport network, featuring intelligent CSPF routing, switchable O-E-O wavelength conversion, and inline EDFA physical layer amplification.

---

## 🚀 Features

### 1. Intent-Based Network Slicing (3GPP Standards)
Dynamically optimizes routing paths based on the requested Service Level Agreement (SLA):
* **eMBB (Enhanced Mobile Broadband):** Prioritizes bandwidth and energy efficiency targeting the `Core_DC`.
* **URLLC (Ultra-Reliable Low-Latency Communications):** Minimizes propagation delays targeting the `Edge_DC`.
* **mMTC (Massive Machine Type Communications):** Focuses heavily on network load balancing across the fiber infrastructure.

### 2. WDM Physical Layer & RWA Engine
* Simulates a persistent 4-channel optical spectrum snapshot (`\lambda_1` to `\lambda_4`).
* Implements **Constraint-Based Shortest Path First (CSPF)** routing.
* Supports toggleable **Optical-Electrical-Optical (O-E-O) Wavelength Conversion** using a look-ahead optimization strategy to mitigate wavelength continuity constraints.

### 3. Integrated Inline EDFA Amplification (New!)
* Features a real-time hop-by-hop distance tracking mechanism.
* Automatically triggers an **Inline EDFA (Erbium-Doped Fiber Amplifier)** stage if a signal travels more than **70 km** without amplification.
* Mathematically calculates and injects localized gain to perfectly offset fiber attenuation, accounting for minor Amplified Spontaneous Emission (ASE) noise penalties to keep signal degradation at a minimum.

### 4. Real-Time Telemetry & Fault Injection
* **Live Metrics:** Dynamic calculation of Coherent Receiver OSNR, Bit Error Rate (BER), Chromatic Dispersion (CD), Polarization Mode Dispersion (PMD), and Kerr-effect Non-Linear Intensity (NLI) penalties.
* **Chaos Engineering:** Interactive switch to inject live outbound fiber degradation or link congestion to test controller self-healing capabilities.
* **Topology Graph:** Reactive UI axes component visualizing active primary paths (red) and pre-computed proactive protection detours (blue dashes).

---

## 🛠 Network Infrastructure Topology

The controller operates over a 5-node core topology consisting of:
* `gNB_A`, `gNB_B`, `gNB_C` (Next-Generation NodeB Ingress Points)
* `Edge_DC` (Edge Data Center)
* `Core_DC` (Core Data Center)

---

## 📈 Simulated Physical Constants

| Parameter | Operational Value |
| :--- | :--- |
| Fiber Attenuation | 0.2 dB/km |
| Base Launch Power | 45.0 dBm |
| Receiver Noise Figure | 5.0 dB |
| EDFA Distance Threshold | 70.0 km |
| EDFA ASE Noise Penalty | 0.35 dB / stage |
| Chromatic Dispersion Coeff. | 17 ps/nm/km |
| PMD Coefficient | 0.1 ps/\sqrt{km} |

---

## 💻 Getting Started

### Prerequisites
* MATLAB (R2020a or newer recommended)
* MATLAB MATLAB App Designer / UI Toolboxes (included by default in standard installations)

### Installation & Execution
1. Clone this repository to your local machine:
   ```bash
   git clone [https://github.com/paavansankeerth05-beep/5G-Optical-SDN-Controller.git](https://github.com/paavansankeerth05-beep/5G-Optical-SDN-Controller.git)
