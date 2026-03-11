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

include { BACTRAIL_ADD                 } from './workflows/bactrail_add'
include { BACTRAIL_ANALYZE             } from './workflows/bactrail_analyze'
include { PIPELINE_INITIALISATION      } from './subworkflows/local/utils_nfcore_bactrail_pipeline'
include { PIPELINE_COMPLETION_ADD      } from './subworkflows/local/utils_nfcore_bactrail_pipeline'
include { PIPELINE_COMPLETION_ANALYZE  } from './subworkflows/local/utils_nfcore_bactrail_pipeline'


include { getGenomeAttribute           } from './subworkflows/local/utils_nfcore_bactrail_pipeline'

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
    samplesheet     // channel: samplesheet read in from --input
    reference_list  // channel: file of list of references for fastANI
    reference_dir   // channel: directory of references for fastANI
    schema_dir      // channel: directory of the popPUNK schemas
    kraken2_db      // channel: kraken2 database
    db              // channel: output database
    versions        // channel: versions

    main:

    //
    // WORKFLOW: Run pipeline
    //
    BACTRAIL_ADD (
        samplesheet,
        reference_list,
        reference_dir,
        schema_dir,
        kraken2_db,
        db,
        versions
    )

    emit:
    multiqc_report = BACTRAIL_ADD.out.multiqc_report // channel: /path/to/multiqc_report.html

}

//
// WORKFLOW: Run analysis pipeline depending on type of input
//
workflow NFCORE_BACTRAIL_ANALYZE {

    take:
    organism               // channel: organism read in from --organism
    db_name                // channel: database name read in from --db_name
    cluster                // channel: the cluster to analyze if provided
    collection_date_start  // channel: the start date of the range to analyze
    collection_date_end    // channel: the end date of the range to analyze

    main:

    //
    // WORKFLOW: Run pipeline
    //
    BACTRAIL_ANALYZE(
        organism,
        db_name,
        cluster,
        collection_date_start,
        collection_date_end
    )

}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow ADD {

    def mode = 'add'

    PIPELINE_INITIALISATION (
        params.version,
        params.help,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input,
        params.schema_dir,
        params.db_name,
        params.kraken2_db,
        params.reference_list,
        params.reference_dir,
        params.organism,
        params.cluster,
        params.remove_recombinants,
        params.replace,
        params.collection_date_start,
        params.collection_date_end,
        mode
    )

    NFCORE_BACTRAIL_ADD (
        PIPELINE_INITIALISATION.out.samplesheet,
        PIPELINE_INITIALISATION.out.reference_list,
        PIPELINE_INITIALISATION.out.reference_dir,
        PIPELINE_INITIALISATION.out.schema_dir,
        PIPELINE_INITIALISATION.out.kraken2_db,
        PIPELINE_INITIALISATION.out.db,
        PIPELINE_INITIALISATION.out.versions
    )

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

workflow ANALYZE {

    def mode = 'analyze'

    PIPELINE_INITIALISATION (
        params.version,
        params.help,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input,
        params.schema_dir,
        params.db_name,
        params.kraken2_db,
        params.reference_list,
        params.reference_dir,
        params.organism,
        params.cluster,
        params.remove_recombinants,
        params.replace,
        params.collection_date_start,
        params.collection_date_end,
        mode
    )

    NFCORE_BACTRAIL_ANALYZE (
        params.organism,
        params.db_name,
        params.cluster,
        params.collection_date_start,
        params.collection_date_end
    )

    PIPELINE_COMPLETION_ANALYZE (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.outdir,
        params.monochrome_logs,
        params.hook_url
    )
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
