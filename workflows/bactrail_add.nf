/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-validation'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_bactrail_pipeline'
include { GRAB_ORGANISM          } from '../modules/local/grab_organism.nf'
include { DATABASE_VERIFY        } from '../modules/local/database_verify.nf'
include { POPPUNK_ASSIGN         } from '../modules/local/poppunk/poppunk_assign.nf'
include { SNIPPY                 } from '../modules/local/snippy/snippy.nf'
include { SPADES                 } from '../modules/local/spades/spades.nf'
include { POPPUNK_QUERY          } from '../modules/local/poppunk_query.nf'
include { PROKKA                 } from '../modules/local/prokka/prokka.nf'
include { UPDATE_DB              } from '../modules/local/database/update_db.nf'
include { WRITE_STATUS           } from '../modules/local/database/write_status.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BACTRAIL_ADD {

    take:
    ch_samplesheet // channel: samplesheet read in from --input

    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    ch_samplesheet
        .map { meta, reads, organism, reference -> organism }
        .unique()
        .set{ organisms }

    //
    // MODULE: Database verify
    //
    DATABASE_VERIFY(
        params.schema_dir,
        organisms
    )

    //
    // MODULE: Spades
    //
    SPADES (
        ch_samplesheet
            .map{ meta, reads, organism, reference -> tuple(meta, reads) }
    )

    //
    // MODULE: Make popPUNK query file
    //
    POPPUNK_QUERY (
        SPADES.out.assembly
        .combine(ch_samplesheet, by:0)
        .groupTuple(by:3)
        .map { meta, assembly, reads, organism, reference -> tuple(organism, assembly)}
    )

    //
    // MODULE: popPUNK cluster assignment
    //
    POPPUNK_ASSIGN (
        DATABASE_VERIFY.out.organism_schema
        .combine(POPPUNK_QUERY.out.query, by:0)
        .combine(SPADES.out.assembly
                .combine(ch_samplesheet, by:0)
                .groupTuple(by:3)
                .map { meta, assembly, reads, organism, reference -> tuple(organism, assembly)}
                , by:0),
        params.schema_dir
    )

    //
    // MODULE: Prokka
    //
    PROKKA (
        SPADES.out.assembly
    )

    //
    // MODULE: Snippy
    //
    SNIPPY (
        ch_samplesheet
            .map{ meta, reads, organism, reference -> tuple(meta, reads, reference) }
    )
    params.replace.toString().capitalize()
    UPDATE_DB (
        SPADES.out.assembly
        .join(PROKKA.out.gff)
        .join(SNIPPY.out.results)
        .join(ch_samplesheet
                .map { meta, reads, organism, reference -> tuple(meta, organism) }
        )
        .map { meta, assembly, gff, snippy, organism -> tuple(organism, meta, assembly, gff, snippy) }
        .combine(POPPUNK_ASSIGN.out.clusters, by: 0),
        params.db_name,
        params.replace.toString().capitalize()
    )

    // UPDATE_DB.out.status.collect().view()

    WRITE_STATUS(
        UPDATE_DB.out.status.collect()
    )

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(storeDir: "${params.outdir}/pipeline_info", name: 'nf_core_pipeline_software_mqc_versions.yml', sort: true, newLine: true)
        .set { ch_collated_versions }

    //
    // MODULE: MultiQC
    //
    ch_multiqc_config                     = Channel.fromPath("$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config              = params.multiqc_config ? Channel.fromPath(params.multiqc_config, checkIfExists: true) : Channel.empty()
    ch_multiqc_logo                       = params.multiqc_logo ? Channel.fromPath(params.multiqc_logo, checkIfExists: true) : Channel.empty()
    summary_params                        = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary                   = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ? file(params.multiqc_methods_description, checkIfExists: true) : file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(methodsDescriptionText(ch_multiqc_custom_methods_description))
    ch_multiqc_files                      = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_files                      = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files                      = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml', sort: false))

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList()
    )

    emit:
    multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
