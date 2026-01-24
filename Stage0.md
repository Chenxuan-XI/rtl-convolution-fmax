# Timing‑Driven Frequency Exploration of a 1×1 Convolution MAC

## Overview
* Target operation: **1×1 convolution MAC**
  [ y = x \times w + b ]
* Focus: **datapath and clocking limits**, not functional completeness
* Toolchain: **Vivado (Xilinx 7‑series)**
* Hardware bring‑up: **not required**
* Evaluation method: **post place‑and‑route timing analysis**

> The goal is not to maximize MHz for a deployable system, but to **explain why and where frequency degrades** as architectural realism increases.

---

## Stage 1.1 — Idealized MAC Frequency Limit

### Objective

Establish the **upper bound** on achievable frequency for a single MAC datapath by isolating arithmetic and register timing.

### Architecture

```
input registers
    ↓
DSP48 (x * w + b, registered)
    ↓
Downstream FF (capture)
```

* Single MAC
* No BRAM
* No control logic
* No spatial parallelism
* Single module, explicitly frozen pipeline

### Key Design Choice

A downstream register is intentionally added to create a **true register‑to‑register timing path**:

```
DSP48 register → FF
```

This ensures that Vivado reports a meaningful setup‑time critical path instead of an I/O‑limited path.

---

## Timing Sweep Results (Stage 1)

### Methodology

* A single clock constraint is applied via XDC
* Clock period is progressively reduced
* Timing is evaluated after full implementation
* Primary metrics:

  * WNS (setup slack)
  * WPWS (pulse‑width / minimum period slack)

### Results Summary

| Clock Period (ns) | Frequency (MHz) | WNS (ns) | WPWS (ns) |  Status  |
| ----------------: | --------------: | -------: | --------: | :------: |
|               5.0 |             200 |   +3.447 |    +2.000 |   Pass   |
|               4.0 |             250 |   +2.447 |    +1.500 |   Pass   |
|               3.0 |             333 |   +1.447 |    +0.845 |   Pass   |
|               2.2 |           454.5 |   +0.673 |    +0.045 |   Pass   |
|               2.1 |           476.2 |   +0.611 |    −0.055 | **Fail** |
|               2.0 |             500 |   +0.207 |    −0.155 | **Fail** |

* The MAC datapath exhibits a **stable critical delay of ~1.55 ns**, implying an **arithmetic-limited upper bound of ~645 MHz**.
* Under tighter constraints (≤ 2.1 ns), **setup timing still passes**; failures arise **only from clock pulse-width (WPWS)** violations.
* This marks a clear transition from **datapath-limited** to **clock-primitive-limited** operation.

> **Conclusion:**
> The compute datapath itself sustains ~645 MHz, while the **practical, clock-safe frequency on this device is ~455–475 MHz**, bounded by DSP48 / BUFG clocking limits.

This stage establishes a **clean baseline**: arithmetic is not the bottleneck—any future fmax degradation must stem from memory, routing, or control logic.

---

## Stage 2 — Introduce Memory Reality

Add on‑chip memory to the datapath:

```
BRAM → DSP48 → FF
```

Purpose:

* Quantify the cost of memory access
* Observe routing and placement effects

## Stage 3 — Spatial Parallelism

Replicate multiple MAC units:

```
N × (DSP48 → FF)
```

Purpose:

* Measure congestion‑induced frequency degradation
* Study scaling behavior

## Stage 4 — Control and Scheduling (Optional)

Introduce realistic control signals (valid/enable/fanout) to evaluate control‑path criticality.

---

## Takeaway

This project demonstrates that **high‑frequency accelerator design is fundamentally about bottleneck attribution**.

By progressing from an idealized MAC to increasingly realistic structures, each frequency loss can be:

* Measured
* Localized
* Explained

This approach mirrors real‑world FPGA performance engineering, where understanding *why* frequency degrades is more valuable than simply reporting a final MHz number.

