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
```

### 2. Quick Web Simulation (EDA Playground)
Verify the RTL logic entirely in your browser without installing a local toolchain:
1. Go to [EDA Playground](https://edaplayground.com/) and set the simulator to **Icarus Verilog 0.9.7** (Check "Open EPWave after run").
2. Paste `/rtl/baseline_mac.v` into the **Design** window.
3. Paste `/sim/tb_baseline.v` into the **Testbench** window.
4. Upload `test_vectors.txt` using the **Add file** menu. 
5. Click **Run** to simulate the hardware and view the output waveforms.

### 3. Local Logic Simulation
If you prefer a local offline environment, the design can be simulated using any standard Verilog simulator (e.g., Icarus Verilog). The testbenches automatically parse the generated `test_vectors.txt` file and verify the output.
```bash
iverilog -o sim.vvp rtl/swp_design.v sim/swp_testbench.v
vvp sim.vvp
```
### 4. Hardware Synthesis (Xilinx Vivado)
Synthesis and physical extraction metrics were performed using **Xilinx Vivado 2025.2** targeting the Zynq-7000 FPGA family. To reproduce the area and power numbers:

1. Create a new Vivado RTL project targeting the `xc7k70tfbv676-1` device.
2. Import the source files from the `/rtl/` directory.
3. Set either `baseline_mac.v` or `swp_mac.v` as the **Top Module**.
4. Run **Synthesis** and generate the *Report Utilization* and *Report Power* metrics.

---

## Results & Metrics
The proposed SWP architecture was evaluated against a standard INT8 baseline. By forcing strict LUT-based synthesis (`use_dsp = "no"`), the following gate-level hardware trade-offs were extracted:

| Metric | Baseline (Standard INT8) | Proposed SWP (INT8 / 2x INT4) | Hardware Overhead |
| :--- | :---: | :---: | :---: |
| **Area (Slice LUTs)** | 60 | 100 | **+66%** |
| **Internal Power** | 1.04 W | 1.54 W | **+48%** |
| **Peak Throughput** | 1x | 2x (in INT4 mode) | **+100%** |

#### Architectural Advantage
While the isolation logic and multiplexing incur a 66% LUT overhead, the SWP MAC inherently executes two parallel INT4 math operations per clock cycle in Mode 1. For NMS-free architectures like **YOLO26**—which eliminate heavy DFL/Softmax blocks—spending 40 additional LUTs to achieve a **100% throughput increase** is a highly efficient silicon trade-off for edge inference.

---

## Citation
If you use this architecture or verification environment in your research, please cite our work:

```bibtex
@inproceedings{akul2026yolo26swp,
  title={A Sub-Word Parallel MAC Architecture for NMS-Free YOLO26 Edge Inference},
  author={Akul},
  booktitle={Pending IEEE Conference Submission},
  year={2026}
}
```
### Pro-Tips for your GitHub:
* **The Dividers:** I added `---` lines. These create thin horizontal separators that make the page much easier to read.
* **Bolding:** I used `**` around key numbers (like +100%) to make sure a recruiter or reviewer's eyes go straight to your best results.
* **Alignment:** The `:---:` in the table code ensures your numbers are centered in their columns.

Now that your documentation is finished, are we ready to move on to drafting the **Research Abstract** for your conference submission?
