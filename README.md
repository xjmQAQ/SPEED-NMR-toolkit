# SPEED Toolkit for Selective NMR Spectroscopy

MATLAB toolkit for **SPEED** (**SP**Ectral **E**ncoding and **D**ecoding), a framework for parallel multi-frequency selective excitation and spectral decoding in NMR spectroscopy.

This repository accompanies the manuscript:

> **SPEED: Parallel Multi-Frequency Selective Excitation for NMR Spectroscopy**

The current toolkit focuses on two practical tasks:

1. **Building encoded selective RF pulses** from single-frequency input pulses
2. **Decoding encoded FIDs** into individual channel-resolved spectra

At present, the code supports two encoding schemes:

- **Hadamard encoding**
- **Fourier encoding**

---

## Overview

Selective excitation is widely used in 1D selective NMR experiments to isolate targeted resonances and reduce spectral congestion. In conventional workflows, each target resonance is usually acquired in a separate experiment. The SPEED framework reorganizes this process into a parallel workflow:

- multiple target frequencies are encoded simultaneously,
- encoded datasets are acquired,
- individual spectra are reconstructed computationally by decoding.

This repository provides the MATLAB code used to support pulse construction, encoded-data handling, and reconstruction workflows described in the manuscript and Supporting Information.

---

## Platform scope: Varian / Agilent oriented workflow

This toolkit is primarily designed for **Varian / Agilent NMR workflows**, including:

- **Varian / Agilent VnmrJ**-based acquisition environments
- **Pbox**-generated selective pulse shapes
- **Varian / Agilent `.fid` directories** used in the decoding workflow

Accordingly, the pulse handling and FID reconstruction utilities in this repository are intended mainly for **Varian / Agilent spectrometer users** or for users working with data exported from those systems. This repository is therefore best understood as a companion toolkit for **Varian / Agilent pulse preparation, encoded acquisition, and encoded-data reconstruction**, rather than as a vendor-neutral acquisition package.

---

## Repository layout

The repository is organized as follows:

```text
SPEED-toolkit/
├─ README.md
├─ .gitignore
├─ processing/
│  ├─ speed_gui.m
│  ├─ +speed/
│  └─ ...
├─ acquisition/
│  ├─ SPEED-CLIP-COSY.c
│  ├─ SPEED-NOESY.c
│  ├─ FIDs/
│  │  └─ Encoded/
│  │     ├─ Fourier/
│  │     └─ Hadamard/
│  └─ pulses/
│     └─ Unencoded/
│        ├─ Fourier/
│        └─ Hadamard/
├─ raw/
│  ├─ 17β-estradiol/
│  ├─ Amino acids/
│  ├─ Menthol/
│  ├─ Pigbrain/
│  └─ Serum/
└─ Figures/
```

---

## What is included in each folder

### `processing/`

The `processing/` folder contains the MATLAB source code for the SPEED workflow, including:

- GUI for pulse construction and FID decoding
- core encoding and decoding functions
- RF pulse reading and writing utilities
- Varian / Agilent FID loading and reconstruction functions
- automatic phasing utility for reconstructed spectra

This folder corresponds to the processing scripts requested for reproducibility.

### `acquisition/`

The `acquisition/` folder contains acquisition-side and demonstration files, including:

- spectrometer-side pulse sequence source files:
  - `SPEED-CLIP-COSY.c`
  - `SPEED-NOESY.c`
- example unencoded RF pulse files
- example encoded Varian / Agilent `.fid` datasets for testing the decoding workflow

These files are provided to help readers and reviewers reproduce or adapt the acquisition workflow, especially in Varian / Agilent environments.

### `raw/`

The `raw/` folder contains the original study-related experimental data grouped by sample system:

- `17β-estradiol/`
- `Amino acids/`
- `Menthol/`
- `Pigbrain/`
- `Serum/`

These folders contain the raw experimental materials used to generate the manuscript and Supporting Information results.

### `Figures/`

The `Figures/` folder contains figures demonstrating the GUI workflows and repository usage.

---

## Current code modules

### GUI

- `processing/speed_gui.m`  
  A GUI with two main tabs:
  - **Build RF Pulses**
  - **Decode FIDs**

### Core MATLAB functions

- `processing/+speed/get_encoding_matrix.m`  
  Returns the encoding matrix for Hadamard or Fourier workflows

- `processing/+speed/combine_rf_pulses.m`  
  Combines individual input RF shapes into encoded pulse sets

- `processing/+speed/decode_fids.m`  
  Decodes encoded Varian / Agilent `.fid` datasets into reconstructed channels

- `processing/+speed/read_rf_shape.m` / `write_rf_shape.m`  
  Read and write RF shape files

- `processing/+speed/load_varian_fid.m` / `write_varian_fid.m`  
  Read and write Varian-format FID data

- `processing/+speed/auto_phase_spectrum.m`  
  Automatic phasing utility for reconstructed spectra

### Sequence files

The `acquisition/` folder contains spectrometer-side sequence source files for:

- `SPEED-CLIP-COSY.c`
- `SPEED-NOESY.c`

These sequence files are provided for transparency and reproducibility, especially for **Varian / Agilent users**.

---

## Requirements

### Software

- MATLAB R2020b or newer is recommended
- No external MATLAB toolboxes are strictly required beyond standard MATLAB functionality for the current codebase

### Data and vendor assumptions

- RF shapes are expected in the format handled by the helper functions in `processing/+speed/`
- Encoded datasets are expected as **Varian / Agilent `.fid` directories**
- The toolkit is intended to complement, not replace:
  - **Varian / Agilent VnmrJ**
  - **Pbox**

---

## Quick start

### 1. Open MATLAB and add the processing folder

```matlab
addpath(genpath('processing'))
```

### 2. Launch the GUI

```matlab
speed_gui
```

---

## Guided demo using the `acquisition/` folder

### Demo A — build encoded pulses from example unencoded pulses

This demo corresponds to the **Build RF Pulses** function in the GUI.

#### Hadamard example

1. Open MATLAB and run:

   ```matlab
   addpath(genpath('processing'))
   speed_gui
   ```

2. In the GUI, open the **Build RF Pulses** tab

3. Select encoding method: **Hadamard**

4. Choose the input folder:

   ```text
   acquisition/pulses/Unencoded/Hadamard/
   ```

5. Choose an output folder

6. Click **Build Encoded Pulses**

The program will combine the single-frequency input pulses into encoded pulse sets for Hadamard-type parallel excitation.

<p align="center">
  <img src="Figures/Encoding demonstration.png" alt="Build RF Pulses GUI" width="900">
</p>

#### Fourier example

Repeat the same procedure using:

```text
acquisition/pulses/Unencoded/Fourier/
```

and select **Fourier** as the encoding method.

---

### Demo B — decode example encoded FIDs

This demo corresponds to the **Decode FIDs** function in the GUI.

#### Hadamard example

1. Launch the GUI:

   ```matlab
   addpath(genpath('processing'))
   speed_gui
   ```

2. Open the **Decode FIDs** tab

3. Select decoding method: **Hadamard**

4. Choose the encoded FID folder:

   ```text
   acquisition/FIDs/Encoded/Hadamard/
   ```

5. Choose an output folder

6. Click **Decode FIDs**

The program will reconstruct individual channel-resolved outputs from the encoded Varian / Agilent FID datasets.

#### Fourier example

Repeat the same workflow using:

```text
acquisition/FIDs/Encoded/Fourier/
```

and select **Fourier** as the decoding method.

<p align="center">
  <img src="Figures/Dncoding demonstration.png" alt="Decode FIDs GUI" width="900">
</p>

---

## Encoding notes

### Hadamard mode

Hadamard encoding uses the nearest valid Hadamard order supported by the code:

- `N = 1 -> 1`
- `N = 2 -> 2`
- `N = 3 -> 4`
- `N = 4 -> 4`
- `N = 5–8 -> 8`

If the number of targets does not exactly match a Hadamard order, the code pads the missing channels with zeros. Therefore, the theoretical sensitivity improvement corresponds to the **best-case matched configuration**, while practical gains may be stepwise and somewhat suboptimal when the target count does not match a valid Hadamard order exactly.

### Fourier mode

Fourier encoding uses an `N × N` complex encoding matrix and preserves the number of encoded pulse sets equal to the number of inputs.

---

## Data note

The `raw/` folder contains the original study-related experimental data organized by sample type and figure classification from the main text and Supporting Information. It is intended to help readers and reviewers map repository contents directly onto the reported experimental results.

The `acquisition/` folder contains acquisition-side materials, including pulse sequence source files, example RF pulses, and example encoded FID datasets for testing the GUI workflows.

The `processing/` folder contains the MATLAB scripts used for pulse construction, encoding/decoding, and spectral reconstruction.

---

## Citation

If you use this code, please cite the associated manuscript and, where relevant, the foundational encoding literature below.

### Related literature

1. Krishnamurthy, K. **Hadamard excitation sculpting.** *Journal of Magnetic Resonance* **2001**, *153* (1), 144–150. DOI: **10.1006/jmre.2001.2428**

2. Kupče, Ē.; Freeman, R. **Frequency-domain Hadamard spectroscopy.** *Journal of Magnetic Resonance* **2003**, *162* (1), 158–165. DOI: **10.1016/S1090-7807(02)00194-5**

3. Kakita, V. M. R.; Hosur, R. V. **Hadamard Homonuclear Broadband Decoupled TOCSY NMR: Improved Efficacy in Detecting Long-range Chemical Shift Correlations.** *ChemPhysChem* **2016**, *17* (24), 4037–4042. DOI: **10.1002/cphc.201600769**

4. Zhang, Z. Y.; Smith, P. E. S.; Frydman, L. **Reducing acquisition times in multidimensional NMR with a time-optimized Fourier encoding algorithm.** *The Journal of Chemical Physics* **2014**, *141* (19), 194201. DOI: **10.1063/1.4901561**

---

## Contact

**Corresponding scientific contact**  
**Yuqing Huang**  
Department of Electronic Science, State Key Laboratory of Physical Chemistry of Solid Surfaces, Xiamen University, Xiamen, Fujian 361005, China  
Email: **yqhuangw@xmu.edu.cn**

---

## Limitations

- The decoding workflow currently assumes **Varian / Agilent-style `.fid` data**
- The toolkit is primarily oriented toward **Varian / Agilent pulse and acquisition environments**
- Performance in strongly overlapping spectral regions depends on encoding strategy, selective pulse design, and experimental conditions
- Hadamard-mode sensitivity gains are optimal when the number of target resonances matches the Hadamard order
- This repository is not intended to replace vendor-side acquisition software such as **VnmrJ** or **Pbox**
