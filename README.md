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

## Dependencies

MuFASA requires the following software:

* **Nextflow** ≥ 22.x — [Nextflow installation guide](https://www.nextflow.io/docs/latest/getstarted.html)
* **Java** 11+ — required for **AHRD** — [Java downloads](https://www.oracle.com/java/technologies/javase-downloads.html)
* **Python 3** — required for **FANTASIA Lite** — [Python downloads](https://www.python.org/downloads/)
* **DIAMOND** ≥ 2.x — [DIAMOND GitHub](https://github.com/bbuchfink/diamond)
* **FANTASIA Lite** — [FANTASIA GitHub](https://github.com/CBBIO/FANTASIA-Lite)
* **AHRD** — [AHRD GitHub](https://github.com/groupschoof/AHRD)

### Databases and resources

Each module requires external resources:

1. **Homology-based annotation (DIAMOND + AHRD):**
   Required databases and annotation files are detailed in the official documentation of [DIAMOND](https://github.com/bbuchfink/diamond) and [AHRD](https://github.com/groupschoof/AHRD).

2. **Embedding-based annotation (FANTASIA Lite):**
   Pre-trained models and input requirements are detailed in the [FANTASIA Lite documentation](https://github.com/CBBIO/FANTASIA-Lite).

> ⚠️ All resources referenced in the respective documentation are mandatory for the corresponding module to run successfully.

---

## Input

* A CSV file describing the samples/proteomes to annotate (e.g., `test/test.csv`).
* Each row must include at least: `species` and `fasta` file path.

---

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
| `--fantasia_dir`    | Path to FANTASIA Lite installation directory          |

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
nextflow run main.nf \
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
    --fantasia_dir /path/to/FantasiaLite
```

* Results will be written in the `results/` folder.
* Use `-resume` to continue a previous execution.

---

## Notes

* **All resources are mandatory** for the corresponding module.
* Modules can be enabled/disabled via workflow logic.
* Increase `--JAVA_XMX` for large proteomes.
