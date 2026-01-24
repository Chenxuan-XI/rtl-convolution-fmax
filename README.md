# FPGA Convolution Kernel – Fmax-Oriented RTL Study

## Overview
This project studies how to design a convolution kernel in pure RTL
that achieves high operating frequency (Fmax) on FPGA fabric.

The focus is **not functional completeness**, but:
- micro-architecture design
- timing-driven RTL coding
- understanding FPGA critical paths

The work starts from a minimal **1 input → 1 output** convolution kernel
and incrementally optimises it towards the fabric frequency limit.

## Project Goals
- Understand why naive RTL fails to reach high Fmax
- Learn how pipelining and retiming affect timing
- Analyse FPGA timing reports and critical paths
- Build an engineering-grade RTL design portfolio

## Development Stages
- Stage 1: Timing‑Driven Frequency Exploration of a 1×1 Convolution MAC (Stage1.md)
👉 [Stage 1 — Pipelined MAC & Timing Analysis](Stage1.md)


## Tools
- SystemVerilog
- Vivado (synthesis & timing analysis)
