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

### Timing Sweep Results (Stage 1)

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

## Stage 1.2 — Introduce Memory Reality

Add on‑chip memory to the datapath:

```
BRAM → FF → DSP48 → FF
```

### FPGA Resource Utilization (Post-Synthesis)

**Target:** Xilinx Zynq-7020 (`xc7z020clg400-1`)
**Tool:** Vivado 2025.1
**Design:** `conv1x1_2stage` (DSP48 MAC + BRAM weight storage)

| Resource           | Used | Available | Util.  |
| ------------------ | ---- | --------- | ------ |
| Slice LUTs         | 0    | 53,200    | 0.00%  |
| Slice Registers    | 35   | 106,400   | 0.03%  |
| Block RAM (RAMB18) | 1    | 280       | 0.36%  |
| Block RAM Tiles    | 0.5  | 140       | 0.36%  |
| DSP48E1            | 1    | 220       | 0.45%  |
| BUFG               | 1    | 32        | 3.13%  |
| Bonded I/O         | 100  | 125       | 80.00% |

**Notes:**
This stage intentionally uses minimal resources, with the datapath mapped to a single DSP48 and weights stored in true Block RAM (RAMB18E1). The design serves as a clean baseline for Fmax and timing-closure experiments; high I/O usage reflects a bare kernel-level top module prior to system integration.

### Timing & Fmax Summary

The critical path is dominated by the **synchronous BRAM read to DSP48 input register** path.
At lower frequencies, the design is datapath-clean and fully meets setup/hold constraints.
At **333 MHz (3.0 ns)**, timing fails **due to setup violations**, and the **DSP48E1 primitive violates the minimum clock period (pulse-width) requirement: 3.884ns(WPWS = -0.884ns)**, which exceeds the target clock period.

| Frequency (MHz) | Clock Period (ns) | WNS (ns)  | TNS (ns) | WHS (ns) | Status |
| --------------- | ----------------- | --------- | -------- | -------- | ------ |
| 200             | 5.0               | 1.04      | 0        | 0.229    | Pass   |
| 250             | 4.0               | 0.85      | 0        | 0.204    | Pass   |
| 333             | 3.0               | -0.915    | -12.974  | 0.143    | Fail   |

The main failure reason is due to the negative WPWS, which derives from the DSP register configuration: 

```
AREG = 1
BREG = 1
MREG = 0
CREG = 1
DREG = 1
PREG = 1
ACASCREG = 1
BCASCREG = 1
```

**MREG = 0** means that DSP is combinational logic, connecting directly to the adder and output routine.
Hence, Vivado will provide a very small value on the smallest clock cycle. 
The solution to this problem is to deepen the pipeline structure of DSP48.

---
## Stage 1.3 - DSP Pipelining

Add pipelines to DSP48 used in the 1x1 Convolution MAC

The origin conv RTL:

```systemverilog
always_ff @(posedge clk) begin
    valid_s0 <= valid_in_q;
    if (valid_in_q) begin
        // x * w + b in one cycle (mapped to DSP48)
        y_s0 <= (x_q * w_q) + b_q;
    end
end
```

New structure: 

## Pipeline Structure

```text
BRAM  -> Reg
          |
          v
      [MulStage] -> Reg
          |
          v
      [AddStage] -> Reg
          |
          v
      [OutStage] -> Reg
```



---

## Stage 1.4 — Spatial Parallelism

Replicate multiple MAC units:

```
N × (DSP48 → FF)
```

Purpose:

* Measure congestion‑induced frequency degradation
* Study scaling behavior


---

## Takeaway

This project demonstrates that **high‑frequency accelerator design is fundamentally about bottleneck attribution**.

By progressing from an idealized MAC to increasingly realistic structures, each frequency loss can be:

* Measured
* Localized
* Explained

This approach mirrors real‑world FPGA performance engineering, where understanding *why* frequency degrades is more valuable than simply reporting a final MHz number.

