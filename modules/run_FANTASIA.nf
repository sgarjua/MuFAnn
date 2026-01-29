
process cpy_fasta {

    input:
        tuple val(species), path(fasta), val(fasta_path)

    output:
        tuple val(species), path(fasta)

    publishDir "${params.fantasia_dir}/fasta_tmp", mode: 'copy'

    script:
    """
    echo "Archivo $fasta copiado"
    """
}

process run_fantasia {

    publishDir "${params.outdir}/${species}", mode: 'copy'

    input:
        tuple val(species), path(fasta)

    output:
        path "fantasia_out"

    script:
    """
    cd ${params.fantasia_dir}

    python3 fantasia_pipeline.py \
        --serial-models \
        --embed-models prot_t5 \
        --results-csv ${species}.fantasia_results.csv \
        fasta_tmp/${fasta.getName()}

    LAST_DIR=\$(ls -dt fantasia_* | head -n 1)

    mkdir -p \$NXF_WORK/fantasia_out
    mv \$LAST_DIR \$NXF_WORK/fantasia_out/
    """
}
