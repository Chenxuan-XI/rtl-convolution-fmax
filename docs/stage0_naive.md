# Stage 0 – Naive Convolution Kernel

## Design Description
This stage implements a minimal 1 input → 1 output convolution kernel
using a fully combinational multiply-accumulate datapath.

No pipelining or timing optimisation is applied.
- kernel: 1×1 convolution, y = x*w (optional +b later)
- data type: signed INT8
- interface: in_valid/out_valid only (no backpressure)
- architecture v0.0: combinational multiply (+ add) then output register
- latency: 1 cycle (out_valid delayed from in_valid by 1)
- verification: cycle-accurate reference model in TB

## RTL Structure
- single-cycle multiplication
- combinational adder
- registered output

## Expected Issues
- Long combinational path
- Poor Fmax due to MAC chain
- No consideration of FPGA DSP pipeline

## Purpose of This Stage
This implementation serves as a timing baseline
to understand why naive RTL cannot reach high frequency.

