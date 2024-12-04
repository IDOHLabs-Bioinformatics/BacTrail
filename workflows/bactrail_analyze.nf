/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PULL                 } from '../modules/local/database/pull'
include {SNIPPY_CORE           } from '../modules/local/snippy/snippy_core'
include {SNIPPY_CLEAN          } from '../modules/local/snippy/snippy_clean'
include {SNP_SITES             } from '../modules/local/snippy/snp_sites.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BACTRAIL_ANALYZE {

    take:
    organism
    db_name

    main:

    PULL (
        organism,
        db_name
    )

    SNIPPY_CORE (
        PULL.out.fasta,
        PULL.out.aln,
        PULL.out.vcf,
        PULL.out.reference
    )

    SNIPPY_CLEAN (
        SNIPPY_CORE.out.wg_align
    )

    SNP_SITES (
        SNIPPY_CLEAN.out.cleaned
    )
}
