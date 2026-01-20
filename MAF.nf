params.input = "./test/test.csv"
params.fantasia_dir = "$HOME/00_software/FantasiaLiteV0"
params.outdir = "results"

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
        path "*"

    script:
    """
    cd ${params.fantasia_dir}
    python3 fantasia_pipeline.py --serial-models --embed-models prot_t5 /fasta_tmp/${fasta.getName()}
    """
}


// Workflow block
workflow {

    ch_samples= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta), row.fasta) }
                        .view()

    ch_fantasia_input = cpy_fasta(ch_samples)
    run_fantasia(ch_fantasia_input)
}
