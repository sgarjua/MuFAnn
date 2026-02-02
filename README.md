# MuFASA — Multi-source Functional Annotation and Support Analysis

MuFASA is a **Nextflow pipeline** for protein functional annotation. It integrates **two independent annotation modules**:

1. **Homology-based annotation** using **DIAMOND** and **AHRD**
2. **Embedding-based annotation** using **FANTASIA Lite**

Each module requires **external resources**, and paths to these resources must be provided for the module to run.

---

## Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Core Parameters](#core-parameters)
* [Module 1: Homology-based Annotation](#module-1-homology-based-annotation)
* [Module 2: Embedding-based Annotation](#module-2-embedding-based-annotation)
* [Example Execution](#example-execution)
* [Notes](#notes)

---

## Requirements

* **Nextflow** ≥ 22.x
* **Java** (for AHRD)
* **Python 3** (for FANTASIA Lite)
* **DIAMOND** installed and available in `$PATH`
* **FANTASIA Lite** installed and accessible (optional)
* Required databases and annotation files: SwissProt, TrEMBL, GOA, AHRD resources

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/sgarjua/MuFASA.git
cd MuFASA
```

2. Install dependencies:

```bash
# Example: DIAMOND
conda install -c bioconda diamond
```

3. Ensure Java and Python 3 are available:

```bash
java -version
python3 --version
```

---

## Usage

Run the pipeline:

```bash
nextflow run main.nf --input <input.csv> --outdir <results/>
```

* Use `--help` for full parameter description:

```bash
nextflow run main.nf --help
```

* Use `-resume` to continue a previous run.

---

## Core Parameters (Required)

| Parameter  | Description                                           |
| ---------- | ----------------------------------------------------- |
| `--input`  | CSV file describing the samples/proteomes to annotate |
| `--outdir` | Output directory                                      |

---

## Module 1: Homology-based Annotation (DIAMOND + AHRD)

Performs sequence similarity searches with DIAMOND and functional refinement with AHRD.

**Required parameters:**

| Parameter           | Description                                |
| ------------------- | ------------------------------------------ |
| `--dbsprot`         | Path to DIAMOND SwissProt database (.dmnd) |
| `--dbtrembl`        | Path to DIAMOND TrEMBL database (.dmnd)    |
| `--GO_GAF`          | Gene Ontology annotation file (.gaf)       |
| `--UNIPROT_SPROT`   | SwissProt protein FASTA file               |
| `--UNIPROT_TREMBL`  | TrEMBL protein FASTA file                  |
| `--BLACKLIST`       | AHRD description blacklist file            |
| `--FILTER_SPROT`    | AHRD SwissProt filter file                 |
| `--FILTER_TREMBL`   | AHRD TrEMBL filter file                    |
| `--TOKEN_BLACKLIST` | AHRD token blacklist file                  |
| `--AHRD_JAR`        | Path to AHRD JAR file                      |

**Optional parameters:**

| Parameter           | Description                     | Default |
| ------------------- | ------------------------------- | ------- |
| `--threads`         | Number of threads for DIAMOND   | 60      |
| `--evalue`          | DIAMOND e-value threshold       | 1e-20   |
| `--max_target_seqs` | Max hits per query              | 1       |
| `--JAVA_XMX`        | Maximum Java heap size for AHRD | 2g      |

---

## Module 2: Embedding-based Annotation (FANTASIA Lite)

Performs protein functional annotation using embedding models from FANTASIA Lite.

**Optional parameter:**

| Parameter           | Description                     | Default |
| ------------------- | ------------------------------- | ------- |
| `--fantasia_models` | List of embedding models to use | prot_t5 |

---

## Example Execution

```bash
nextflow run main.nf \
    --input input.csv \
    --outdir results \
    --dbsprot /path/to/sprot.dmnd \
    --dbtrembl /path/to/trembl.dmnd \
    --GO_GAF /path/to/goa.gaf \
    --UNIPROT_SPROT /path/to/sprot.fasta \
    --UNIPROT_TREMBL /path/to/trembl.fasta \
    --AHRD_JAR /path/to/ahrd.jar
    --fantasia_models prot_t5
```


---

## Notes

* All paths to external resources are **mandatory** for the corresponding module to run.
* FANTASIA Lite module is optional; if not needed, no extra paths are required.
* Modules can be enabled/disabled in the workflow logic.
* Use `-resume` to continue a previous execution.
* Increase `--JAVA_XMX` for large proteomes if necessary.
