# YOLO26 SWP Hardware Accelerator

![Language](https://img.shields.io/badge/Language-Verilog-blue)
![Language](https://img.shields.io/badge/Language-Python-yellow)
![Tool](https://img.shields.io/badge/Synthesis-Xilinx_Vivado-red)
![Tool](https://img.shields.io/badge/Simulation-Icarus_Verilog-lightgrey)

## Overview
This repository contains the RTL design, verification environment, and synthesis constraints for a novel **Sub-Word Parallel (SWP) Multiply-Accumulate (MAC) unit**. 

Designed to optimize the NMS-free head of the YOLO26 architecture, this hardware dynamically switches between standard **1x INT8** multiplication and **2x INT4** sub-word parallel multiplication. By stripping out legacy DFL/Softmax layers and utilizing dynamic quantization, this architecture significantly increases throughput while maintaining a minimal area footprint.

This project was developed over a 21-day Silicon Sprint as the hardware foundation for an upcoming IEEE conference paper.

## Repository Structure
* `/python_model/` - Contains the Python script used to generate the mathematical ground truth.
* `/rtl/` - The Verilog source files for the baseline MAC and the novel SWP architecture.
* `/sim/` - Testbenches and simulation vectors (`test_vectors.txt`).
* `/synthesis/` - Xilinx Vivado utilization and power reports.

## Key Features
* **Dynamic Mode Switching:** 1-bit control signal toggles between INT8 and dual INT4 operations.
* **DSP Optimization:** Verified using pure LUT-based synthesis (`use_dsp = "no"`) to provide granular, apples-to-apples area comparisons against baseline architectures.
* **Automated Verification:** Python-generated test vectors feed into automated Verilog testbenches for rapid validation of signed 2's complement arithmetic across chopped bit-slices.

## How to Run

### 1. Generate the Golden Model
Navigate to the `/python_model` directory and run the vector generation script to create the expected outputs for both INT8 and INT4 modes.
```bash
python generate_vectors.py
