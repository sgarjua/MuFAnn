
process run_diamond {

    publishDir "${params.outdir}", mode: 'copy'

    input:
        tuple val(species), path(fasta), path(db)

    output:
        tuple val(species), path(fasta), path("${species}/${species}.${db.getName()}.o6.txt")

    script:
    """
    mkdir -p ${species}
    diamond blastp \
        --query $fasta \
        --db $db \
        --outfmt 6 \
        --max-target-seqs $params.max_target_seqs \
        --evalue $params.evalue \
        --out ${species}/${species}.${db.getName()}.o6.txt \
        --threads $params.threads \
        --sensitive
    """
}

process write_yaml {

    publishDir "${params.outdir}/${species}", mode: 'copy'

    input:
    tuple val(species), path(fasta), path(trembl_tsv), path(sprot_tsv)

    output:
    tuple path("config.yaml"), val(species), path(fasta), path(trembl_tsv), path(sprot_tsv)

    script:
    """
    cat <<EOF > config.yaml
    proteins_fasta: $fasta
    token_score_bit_score_weight: 0.468
    token_score_database_score_weight: 0.2098
    token_score_overlap_score_weight: 0.3221
    gene_ontology_result: $params.GO_GAF
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
    tuple path(yaml_path), val(species), path(fasta), path(trembl_tsv), path(sprot_tsv)

    output:
    path "${species}.proteins.funct_ahrd.tsv"

    script:
    """
    java -Xmx${params.JAVA_XMX} -jar $params.AHRD_JAR $yaml_path

    """
}