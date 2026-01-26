params.input = "./test/test.csv"
params.fantasia_dir = "$HOME/00_software/FantasiaLiteV0"
params.outdir = "results"

include { cpy_fasta, run_fantasia } from './modules/run_FANTASIA.nf'

process run_diamond {

    publishDir "${params.outdir}/${species}", mode: 'copy'

    input:
        tuple val(species), path(fasta)

    output:
        path "*"

    script:
    """
    python3 diamond blastp --query $fasta--db $db --outfmt 6 --max-target-seqs 1 --evalue 1e-20 --out ${params.outdir}/${species} --threads 24 --sensitive
    """
}



// Workflow block
workflow {

    ch_samples= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta), row.fasta) }
                        .view()

    // ch_fantasia_input = cpy_fasta(ch_samples)
    // run_fantasia(ch_fantasia_input)

    run_diamond(ch_samples)

}
