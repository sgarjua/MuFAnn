params.input = "./test/test.tsv"
params.fantasia_dir = "/00_software/FANTASIA-Lite"
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

    Channel
        .fromPath(params.input)
        .splitCsv(header: true, sep: '\t')
        .map { row -> 
            def sample_id = row[0]
            def fasta = row[1]
            tuple(sample_id, file(fasta))
        }
        .view { row -> "ID=${row.sample_id} FILE=${row.fasta}" }
        .set { ch_samples }

    run_fantasia(ch_samples)
}
