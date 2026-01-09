# Stage 0 – Naive Convolution Kernel

## Design Description
This stage implements a minimal 1 input → 1 output convolution kernel
using a fully combinational multiply-accumulate datapath.

No pipelining or timing optimisation is applied.

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

