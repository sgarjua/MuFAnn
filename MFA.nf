params.input = "./test/test.csv"
params.fantasia_dir = "$HOME/00_software/FantasiaLiteV0"
params.outdir = "results"
params.dbsprot = "/data/shared_dbs/swissprot/uniprot_sprot_r2025_01.dmnd"
params.dbtrembl = "/data/shared_dbs/swissprot/uniprot_trembl_r2025_01.dmnd"

include { cpy_fasta } from './modules/run_FANTASIA.nf'
include { run_fantasia } from './modules/run_FANTASIA.nf'

process run_diamond {

    publishDir "${params.outdir}/${species}", mode: 'copy'

    input:
        tuple val(species), path(fasta), path(db), 

    output:
        path "*"

    script:
    """
    mkdir -p ${params.outdir}/${species}
    diamond blastp --query $fasta --db $db --outfmt 6 --max-target-seqs 1 --evalue 1e-20 --out ${params.outdir}/${species}.${db.getName()}.o6.txt --threads 24 --sensitive
    """
}




// Workflow block
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
    ch_diamond = ch_samples2.combine(ch_dbs).view()
    run_diamond(ch_diamond)
}
