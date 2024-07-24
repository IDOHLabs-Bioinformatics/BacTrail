#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/bactrail
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/bactrail
    Website: https://nf-co.re/bactrail
    Slack  : https://nfcore.slack.com/channels/bactrail
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { BACTRAIL_ADD                    } from './workflows/bactrail_add'
include { BACTRAIL_ANALYZE                } from './workflows/bactrail_analyze'
include { PIPELINE_INITIALISATION_ADD     } from './subworkflows/local/utils_nfcore_bactrail_pipeline'
include { PIPELINE_INITIALISATION_ANALYZE } from './subworkflows/local/utils_nfcore_bactrail_pipeline'
include { PIPELINE_COMPLETION_ADD         } from './subworkflows/local/utils_nfcore_bactrail_pipeline'
include { PIPELINE_COMPLETION_ANALYZE     } from './subworkflows/local/utils_nfcore_bactrail_pipeline'


include { getGenomeAttribute              } from './subworkflows/local/utils_nfcore_bactrail_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    GENOME PARAMETER VALUES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

// TODO nf-core: Remove this line if you don't need a FASTA file
//   This is an example of how to use getGenomeAttribute() to fetch parameters
//   from igenomes.config using `--genome`
params.fasta = getGenomeAttribute('fasta')

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run database adding pipeline depending on type of input
//
workflow NFCORE_BACTRAIL_ADD {

    take:
    samplesheet // channel: samplesheet read in from --input
    reference   // channel: reference genome read in from --reference

    main:

    //
    // WORKFLOW: Run pipeline
    //
    BACTRAIL_ADD (
        samplesheet,
        reference
    )

    emit:
    multiqc_report = BACTRAIL_ADD.out.multiqc_report // channel: /path/to/multiqc_report.html

}

//
// WORKFLOW: Run analysis pipeline depending on type of input
//
workflow NFCORE_BACTRAIL_ANALYZE {

    take:
    organism // channel: organism read in from --organism
    db_name  // channel: database name read in from --db_name

    main:

    //
    // WORKFLOW: Run pipeline
    //
    BACTRAIL_ANALYZE(
        organism,
        db_name
    )

}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:

    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    if (params.mode == 'add') {
        PIPELINE_INITIALISATION_ADD (
            params.version,
            params.help,
            params.validate_params,
            params.monochrome_logs,
            args,
            params.outdir,
            params.input,
            params.reference
        )

        //
        // WORKFLOW: Run main workflow
        //
        NFCORE_BACTRAIL_ADD (
            PIPELINE_INITIALISATION_ADD.out.samplesheet,
            PIPELINE_INITIALISATION_ADD.out.reference
        )

        //
        // SUBWORKFLOW: Run completion tasks
        //
        PIPELINE_COMPLETION_ADD (
            params.email,
            params.email_on_fail,
            params.plaintext_email,
            params.outdir,
            params.monochrome_logs,
            params.hook_url,
            NFCORE_BACTRAIL_ADD.out.multiqc_report
        )
    }
    else {
        PIPELINE_INITIALISATION_ANALYZE (
            params.version,
            params.help,
            params.validate_params,
            params.monochrome_logs,
            args,
            params.outdir
        )

        //
        // WORKFLOW: Run main workflow
        //
        NFCORE_BACTRAIL_ANALYZE (
            params.organism,
            params.db_name
        )

        //
        // SUBWORKFLOW: Run completion tasks
        //
        PIPELINE_COMPLETION_ANALYZE (
            params.email,
            params.email_on_fail,
            params.plaintext_email,
            params.outdir,
            params.monochrome_logs,
            params.hook_url
        )
    }

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
