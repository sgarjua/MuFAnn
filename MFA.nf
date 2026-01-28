// ================== DEFAULT CONFIGURATION FOR MFA PIPELINE ==================
// Define parameters
params.input = "./test/test.csv"
params.outdir = "results"

// FANTASIA parameters
params.fantasia_dir = "$HOME/00_software/FantasiaLiteV0"

// DIAMOND database paths
params.dbsprot = "/data/shared_dbs/swissprot/uniprot_sprot_r2025_01.dmnd"
params.dbtrembl = "/data/shared_dbs/swissprot/uniprot_trembl_r2025_01.dmnd"

// AHRD parameters
params.go_gaf = "/data/shared_dbs/swissprot/goa_uniprot_all.gaf"
params.UNIPROT_SPROT = "/data/shared_dbs/swissprot/uniprot_sprot_r2025_01.fasta"
params.UNIPROT_TREMBL = "/data/shared_dbs/swissprot/uniprot_trembl_r2025_01.fasta"
params.BLACKLIST = "/data/software/AHRD/test/resources/blacklist_descline.txt"
params.FILTER_SPROT = "/data/software/AHRD/test/resources/filter_descline_sprot.txt"
params.FILTER_TREMBL = "/data/software/AHRD/test/resources/filter_descline_trembl.txt"
params.TOKEN_BLACKLIST = "/data/software/AHRD/test/resources/blacklist_token.txt"
params.AHRD_JAR = "/data/software/AHRD/dist/ahrd.jar"
params.JAVA_XMX = "2g"   // sube a "8g" o más si lo necesitas


// ================= MODULES ==================
include { cpy_fasta } from './modules/run_FANTASIA.nf'
include { run_fantasia } from './modules/run_FANTASIA.nf'

process run_diamond {

    publishDir "${params.outdir}", mode: 'copy'

    input:
        tuple val(species), path(fasta), path(db)

    output:
        tuple val(species), path(fasta), path("${species}/${species}.${db.getName()}.o6.txt")

    script:
    """
    mkdir -p ${species}
    diamond blastp --query $fasta --db $db --outfmt 6 --max-target-seqs 1 --evalue 1e-20 --out ${species}/${species}.${db.getName()}.o6.txt --threads 60 --sensitive
    """
}

process write_yaml {

    publishDir "${params.outdir}/${species}", mode: 'copy'

    input:
    tuple val(species), path(fasta), path(trembl_tsv), path(sprot_tsv)

    output:
    tuple path("config.yaml"), val(species)

    script:
    """
    cat <<EOF > config.yaml
    proteins_fasta: $fasta
    token_score_bit_score_weight: 0.468
    token_score_database_score_weight: 0.2098
    token_score_overlap_score_weight: 0.3221
    gene_ontology_result: $params.go_gaf
    reference_go_regex: '^UniProtKB\\t(?<shortAccession>[^\\t]+)\\t[^\\t]+\\t(?!NOT\\|)[^\\t]*\\t(?<goTerm>GO:\\d+)'
    prefer_reference_with_go_annos: true
    output: ${species}.proteins.funct_ahrd.tsv
    blast_dbs:
      swissprot:
        weight: 653
        description_score_bit_score_weight: 2.717061
        file: $sprot_tsv
        database: $params.UNIPROT_SPROT
        blacklist: $params.BLACKLIST
        filter: $params.FILTER_SPROT
        token_blacklist: $params.TOKEN_BLACKLIST

      trembl:
        weight: 904
        description_score_bit_score_weight: 2.590211
        file: $trembl_tsv
        database: $params.UNIPROT_TREMBL
        blacklist: $params.BLACKLIST
        filter: $params.FILTER_TREMBL
        token_blacklist: $params.TOKEN_BLACKLIST
    EOF
    """
}

process run_AHRD {

    publishDir "${params.outdir}/${species}", mode: 'copy'

    input:
    tuple path(yaml_path), val(species)

    output:
    path "${species}.proteins.funct_ahrd.tsv"

    script:
    """
    java -Xmx${params.JAVA_XMX} -jar $params.AHRD_JAR $yaml_path

    """
}


// ================= WORKFLOW DEFINITION ==================
workflow {

    ch_samples= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta), row.fasta) }

    ch_samples2= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta)) }

    // ch_fantasia_input = cpy_fasta(ch_samples)
    // run_fantasia(ch_fantasia_input)

    ch_dbs = Channel.of(params.dbsprot, params.dbtrembl)
    ch_diamond = ch_samples2.combine(ch_dbs)
    ch_diamond_out = run_diamond(ch_diamond)
    grouped_ch = ch_diamond_out
                .groupTuple(by: 0)
                .map { species, fasta_list, hit_list ->
                        def fasta = fasta_list[0]
                        def trembl_tsv = hit_list.find { it.getName().contains('trembl') }
                        def sprot_tsv = hit_list.find { it.getName().contains('sprot') }
                        tuple(
                            species,
                            fasta,
                            trembl_tsv,
                            sprot_tsv
                        )
                }
    ch_yaml = write_yaml(grouped_ch)
    run_AHRD(ch_yaml)
}
