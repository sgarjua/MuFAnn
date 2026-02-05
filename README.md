# MuFAnn — Multi-source Functional Annotation Pipeline

MuFAnn is a **Nextflow pipeline** for comprehensive **protein functional annotation**. It assigns **biological functions** to protein sequences, essential for interpreting genomes, metagenomes, and proteomes.

The pipeline integrates **two complementary modules**:

1. **Homology-based annotation (DIAMOND + AHRD)**

   * Compares proteins to **SwissProt and TrEMBL** databases using DIAMOND.
   * Refines functional descriptions with **AHRD**, assigning **Gene Ontology (GO) terms)**.
   * Produces **high-confidence annotations** for proteins with close homologs.

2. **Embedding-based annotation (FANTASIA Lite)**

   * Uses **protein embeddings** from FANTASIA Lite to predict functional properties.
   * Complements homology-based results for proteins with few or no close homologs.

**Key outputs:**

* Functional descriptions per protein
* GO terms (molecular function, biological process, cellular component)
* Curated, standardized results ready for downstream analysis
<img width="1357" height="616" alt="04f033ea-1810-400c-ba25-d3d6216e353b" src="https://github.com/user-attachments/assets/213cbd52-8128-4b0a-b466-af46c4de7ada" />

---


## Installation

MuFAnn is implemented as a **Nextflow pipeline** that integrates two mandatory annotation strategies:

* **Homology-based annotation** (DIAMOND + AHRD)
* **Deep-learning–based annotation** (FANTASIA-Lite)

All external tools must be installed manually before running the pipeline.


### 1. Java (required by Nextflow)

Nextflow **requires Java 17 or later**. The recommended installation method is **SDKMAN**.

```bash
curl -s https://get.sdkman.io | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 17.0.10-tem
```

Verify:

```bash
java -version
```


### 2. Nextflow

Nextflow is distributed as a single executable.

```bash
curl -s https://get.nextflow.io | bash
chmod +x nextflow
sudo mv nextflow /usr/local/bin/
```

Verify:

```bash
nextflow -version
```


### 3. BLAST and DIAMOND

Required for homology-based annotation.

```bash
conda install -y -c bioconda blast diamond
```

Verify:

```bash
blastp -version
diamond version
```


### 4. FANTASIA-Lite

Clone the official repository and install its Python dependencies.

```bash
git clone https://github.com/CBBIO/FANTASIA-Lite.git
cd FANTASIA-Lite
pip install -e .
```

Repository:
[https://github.com/CBBIO/FANTASIA-Lite](https://github.com/CBBIO/FANTASIA-Lite)



### 5. AHRD

Clone the AHRD repository.

```bash
git clone https://github.com/groupschoof/AHRD.git
```

AHRD is a Java application and does not require compilation.

> [!IMPORTANT]
> **AHRD external resources are mandatory**
>
> MuFAnn does **not** download or configure AHRD resources automatically.
> Users must manually obtain and provide paths to all AHRD-required files, including:
>
> - `ahrd.jar`
> - Gene Ontology annotation file (GOA / `.gaf`)
> - Reference protein FASTA files (SwissProt and TrEMBL)
> - AHRD configuration files:
>   - description blacklist
>   - token blacklist
>   - SwissProt and TrEMBL filter files
>
> These files are required for the homology-based annotation module to run.
> Incorrect paths or missing resources will cause the pipeline to fail.
>
> Please consult the official AHRD documentation before use:  
> https://github.com/groupschoof/AHRD



### 6. MuFAnn pipeline

Clone the pipeline repository:

```bash
git clone https://github.com/sgarjua/MuFAnn.git
cd MuFAnn
```

---

## Input

* A CSV file describing the samples/proteomes to annotate (e.g., `test/test.csv`).
* Each row must include at least: `species` and `fasta` file path.


## Usage

### Required parameters

| Parameter           | Description                                           |
| ------------------- | ----------------------------------------------------- |
| `--input`           | CSV file describing the samples/proteomes to annotate |
| `--outdir`          | Output directory                                      |
| `--dbsprot`         | Path to DIAMOND SwissProt database (.dmnd)            |
| `--dbtrembl`        | Path to DIAMOND TrEMBL database (.dmnd)               |
| `--GO_GAF`          | Gene Ontology annotation file (.gaf)                  |
| `--UNIPROT_SPROT`   | SwissProt protein FASTA file                          |
| `--UNIPROT_TREMBL`  | TrEMBL protein FASTA file                             |
| `--BLACKLIST`       | AHRD description blacklist file                       |
| `--FILTER_SPROT`    | AHRD SwissProt filter file                            |
| `--FILTER_TREMBL`   | AHRD TrEMBL filter file                               |
| `--TOKEN_BLACKLIST` | AHRD token blacklist file                             |
| `--AHRD_JAR`        | Path to AHRD JAR file                                 |

### Optional parameters

| Parameter           | Description                           | Default |
| ------------------- | ------------------------------------- | ------- |
| `--threads`         | Number of threads for DIAMOND         | 60      |
| `--evalue`          | DIAMOND e-value threshold             | 1e-20   |
| `--max_target_seqs` | Maximum hits per query                | 1       |
| `--JAVA_XMX`        | Maximum Java heap size for AHRD       | 2g      |
| `--fantasia_models` | List of embedding models for FANTASIA | prot_t5 |

---

## Quick Start with Test Data

The repository includes a **test input CSV**:

```
test/test.csv
```

Run the pipeline with **all required resources**:

```bash
nextflow run MUFANN.nf \
    --input test/test.csv \
    --outdir results \
    --dbsprot /path/to/uniprot_sprot.dmnd \
    --dbtrembl /path/to/uniprot_trembl.dmnd \
    --GO_GAF /path/to/goa_uniprot_all.gaf \
    --UNIPROT_SPROT /path/to/uniprot_sprot.fasta \
    --UNIPROT_TREMBL /path/to/uniprot_trembl.fasta \
    --BLACKLIST /path/to/blacklist_descline.txt \
    --FILTER_SPROT /path/to/filter_descline_sprot.txt \
    --FILTER_TREMBL /path/to/filter_descline_trembl.txt \
    --TOKEN_BLACKLIST /path/to/blacklist_token.txt \
    --AHRD_JAR /path/to/ahrd.jar \
```

* Results will be written in the `results/` folder.
* Use `-resume` to continue a previous execution.

---

## Notes

* **All resources are mandatory** for the corresponding module.
* Modules can be enabled/disabled via workflow logic.
* Increase `--JAVA_XMX` for large proteomes.
