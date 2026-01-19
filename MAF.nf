params.input = "./test/test.csv"
params.fantasia_dir = "~/00_software/FantasiaLiteV0"
params.outdir = "results"

process run_fantasia {

    publishDir "${params.outdir}/${sample_id}", mode: 'copy'

    input:
        tuple val(sample_id), path(sample_file)

    output:
        path "*"

    script:
    """
    cd ${params.fantasia_dir}

    python3 fantasia_pipeline.py \
        --serial-models \
        --embed-models prot_t5 \
        ${sample_file}
    """
}


// Workflow block
workflow {

    ch_samples= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta)) }

    run_fantasia(ch_samples)
}
