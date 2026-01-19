nextflow.enable.dsl=2

params.input = "./test/test.csv"
params.fantasia_dir = "~/00_software/FantasiaLiteV0"
params.outdir = "results"
params.

process run_fantasia {

    publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
        tuple val(species), path(fasta)

    output:
        path "*"

    script:
    """
    # Nos movemos al directorio de Fantasia
    cd ${params.fantasia_dir}

    # Ejecutamos Fantasia apuntando al FASTA en el work dir temporal
    python3 fantasia_pipeline.py \
        --serial-models \
        --embed-models prot_t5 \
        ${fasta.toAbsolutePath()}
    """
}


// Workflow block
workflow {

    ch_samples= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta)) }

    run_fantasia(ch_samples)
}
