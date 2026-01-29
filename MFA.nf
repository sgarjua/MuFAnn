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
params.GO_GAF = "/data/shared_dbs/swissprot/goa_uniprot_all.gaf"
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
include { run_diamond } from './modules/run_HOMOLOGY.nf'
include { write_yaml } from './modules/run_HOMOLOGY.nf'
include { run_AHRD } from './modules/run_HOMOLOGY.nf'


// ================= WORKFLOW DEFINITION ==================
workflow {

    ch_samples= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta), row.fasta) }

    ch_samples2= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta)) }

    ch_fantasia_input = cpy_fasta(ch_samples)
    run_fantasia(ch_fantasia_input)

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
