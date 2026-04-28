SPEED Toolkit for Selective NMR Spectroscopy
MATLAB toolkit for SPEED (SPEctral Encoding and Decoding), a framework for parallel multi-frequency selective excitation and spectral decoding in NMR spectroscopy.
This repository accompanies the manuscript:
> **SPEED: Parallel Multi-Frequency Selective Excitation for NMR Spectroscopy**
The current toolkit focuses on two practical tasks:
Building encoded selective RF pulses from single-frequency input pulses
Decoding encoded FIDs into individual channel-resolved spectra
At present, the code supports two encoding schemes:
Hadamard encoding
Fourier encoding
---
Overview
Selective excitation is widely used in 1D selective NMR experiments to isolate targeted resonances and reduce spectral congestion. In conventional workflows, each target resonance is usually acquired in a separate experiment. The SPEED framework reorganizes this process into a parallel workflow:
multiple target frequencies are encoded simultaneously,
encoded datasets are acquired,
individual spectra are reconstructed computationally by decoding.
This repository provides the MATLAB code used to support pulse construction, encoded-data handling, and reconstruction workflows described in the manuscript and Supporting Information.
---
Platform scope: Varian / Agilent oriented workflow
This toolkit is primarily designed for Varian / Agilent NMR workflows, including:
Varian / Agilent VnmrJ-based acquisition environments
Pbox-generated selective pulse shapes
Varian / Agilent `.fid` directories used in the decoding workflow
Accordingly, the pulse handling and FID reconstruction utilities in this repository are intended mainly for Varian / Agilent spectrometer users or for users working with data exported from those systems. This repository is therefore best understood as a companion toolkit for Varian / Agilent pulse preparation, encoded acquisition, and encoded-data reconstruction, rather than as a vendor-neutral acquisition package.
---
Repository layout
The current repository is organized as follows:
```text
SPEED-toolkit/
├─ README.md
├─ processing/
├─ raw/
│  ├─ 17β-estradiol/
│  ├─ Amino acids/
│  ├─ Menthol/
│  ├─ Pigbrain/
│  └─ Serum/
└─ acuisition/
   ├─ FIDs/
   └─ pulses/
├─ Figures/
```
What is included in each folder
`processing/`  
MATLAB source code, including:
GUI for pulse construction and FID decoding
core encoding / decoding functions
`raw/`  
Study-related materials grouped by sample system:
`17β-estradiol/`
`Amino acids/`
`Menthol/`
`Pigbrain/`
`Serum/`
`Figures/`  
Figures demonstrate the GUI of workflows.
`acquisition/`  
pulse sequence files for SPEED-CLIP-COSY and SPEED-NOESY
Sequence files are provided for transparency and reproducibility, especially for Varian / Agilent users.
Hands-on demonstration files intended for quick software evaluation:
`pulses/Unencoded/Fourier/`
`pulses/Unencoded/Hadamard/`
`FIDs/Encoded/Fourier/`
`FIDs/Encoded/Hadamard/`
These example folders are designed specifically so that reviewers and users can try the two core GUI workflows without preparing their own files:
generate encoded pulses from unencoded input pulses
decode encoded FIDs into reconstructed channel outputs
---
Current code modules
The current MATLAB package contains the following main components:
GUI
`processing/speed_gui.m`  
A GUI with two main tabs:
Build RF Pulses
Decode FIDs

Core MATLAB functions
`processing/+speed/get_encoding_matrix.m`  
Returns the encoding matrix for Hadamard or Fourier workflows
`processing/+speed/combine_rf_pulses.m`  
Combines individual input RF shapes into encoded pulse sets
`processing/+speed/decode_fids.m`  
Decodes encoded Varian / Agilent `.fid` datasets into reconstructed channels
`processing/+speed/read_rf_shape.m` / `write_rf_shape.m`  
Read and write RF shape files
`processing/+speed/load_varian_fid.m` / `write_varian_fid.m`  
Read and write Varian-format FID data
`processing/+speed/auto_phase_spectrum.m`  
Automatic phasing utility for reconstructed spectra
---
Requirements
Software
MATLAB R2020b or newer is recommended
No external MATLAB toolboxes are strictly required beyond standard MATLAB functionality for the current codebase
Data and vendor assumptions
RF shapes are expected in the format handled by the helper functions in `processing/+speed/`
Encoded datasets are expected as Varian / Agilent `.fid` directories
The toolkit is intended to complement, not replace:
Varian / Agilent VnmrJ
Pbox
---
Quick start
1. Open MATLAB and add the source folder
```matlab
addpath(genpath('processing'))
```
2. Launch the GUI
```matlab
speed_gui
```
---
Guided demo using the `acquisition/` folder
Demo A — build encoded pulses from example unencoded pulses
This demo corresponds to the Build RF Pulses function in the GUI.
Hadamard example
Open MATLAB and run:
```matlab
   addpath(genpath('processing'))
   speed_gui
   ```
In the GUI, open the Build RF Pulses tab
Select encoding method: Hadamard
Choose the input folder:
```text
   acquisition/pulses/Unencoded/Hadamard/
   ```
Choose an output folder
Click Build Encoded Pulses
The program will combine the single-frequency input pulses into encoded pulse sets for Hadamard-type parallel excitation.
<p align="center">
  <img src="Figures/gui_build_rf_pulses.png" alt="Build RF Pulses GUI" width="900">
</p>
Fourier example
Repeat the same procedure using:
```text
acquisition/pulses/Unencoded/Fourier/
```
and select Fourier as the encoding method.
---
Demo B — decode example encoded FIDs
This demo corresponds to the Decode FIDs function in the GUI.
Hadamard example
Launch the GUI:
```matlab
   addpath(genpath('src'))
   speed_gui
   ```
Open the Decode FIDs tab
Select decoding method: Hadamard
Choose the encoded FID folder:
```text
   acquisition/FIDs/Encoded/Hadamard/
   ```
Choose an output folder
Click Decode FIDs
The program will reconstruct individual channel-resolved outputs from the encoded Varian / Agilent FID datasets.
Fourier example
Repeat the same workflow using:
```text
acquisition/FIDs/Encoded/Fourier/
```
and select Fourier as the decoding method.
<p align="center">
  <img src="Figures/gui_decode_fids.png" alt="Decode FIDs GUI" width="900">
</p>
---
Encoding notes
Hadamard mode
Hadamard encoding uses the nearest valid Hadamard order supported by the code:
`N = 1 -> 1`
`N = 2 -> 2`
`N = 3 -> 4`
`N = 4 -> 4`
`N = 5–8 -> 8`
If the number of targets does not exactly match a Hadamard order, the code pads the missing channels with zeros. Therefore, the theoretical sensitivity improvement corresponds to the best-case matched configuration, while practical gains may be stepwise and somewhat suboptimal when the target count does not match a valid Hadamard order exactly.
Fourier mode
Fourier encoding uses an `N × N` complex encoding matrix and preserves the number of encoded pulse sets equal to the number of inputs.
---
Data note
The `raw/` folder contains study-related materials organized by sample type and figure classification from the main text and Supporting Information. It is intended to help readers and reviewers map repository contents directly onto the reported experimental results.
The `acquisition/` folder, by contrast, is intended as a lightweight entry point for software testing. It contains ready-to-run pulse and FID examples for trying the GUI workflows.
---
Citation
If you use this code, please cite the associated manuscript and, where relevant, the foundational encoding literature below.
Related literature
Krishnamurthy, K. Hadamard excitation sculpting. Journal of Magnetic Resonance 2001, 153 (1), 144–150. DOI: 10.1006/jmre.2001.2428
Kupče, Ē.; Freeman, R. Frequency-domain Hadamard spectroscopy. Journal of Magnetic Resonance 2003, 162 (1), 158–165. DOI: 10.1016/S1090-7807(02)00194-5
Kakita, V. M. R.; Hosur, R. V. Hadamard Homonuclear Broadband Decoupled TOCSY NMR: Improved Efficacy in Detecting Long-range Chemical Shift Correlations. ChemPhysChem 2016, 17 (24), 4037–4042. DOI: 10.1002/cphc.201600769
Zhang, Z. Y.; Smith, P. E. S.; Frydman, L. Reducing acquisition times in multidimensional NMR with a time-optimized Fourier encoding algorithm. The Journal of Chemical Physics 2014, 141 (19), 194201. DOI: 10.1063/1.4901561
---
Contact
Corresponding scientific contact  
Yuqing Huang  
Department of Electronic Science, State Key Laboratory of Physical Chemistry of Solid Surfaces, Xiamen University, Xiamen, Fujian 361005, China  
Email: yqhuangw@xmu.edu.cn
---
Limitations
The decoding workflow currently assumes Varian / Agilent-style `.fid` data
The toolkit is primarily oriented toward Varian / Agilent pulse and acquisition environments
Performance in strongly overlapping spectral regions depends on encoding strategy and experimental design
This repository is not intended to replace vendor-side acquisition software such as VnmrJ or Pbox
---
