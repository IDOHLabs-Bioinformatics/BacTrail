/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PULL                   } from '../modules/local/database/pull'
include { SNIPPY_CORE            } from '../modules/local/snippy/snippy_core'
include { SNIPPY_CLEAN           } from '../modules/local/snippy/snippy_clean'
include { SNP_SITES              } from '../modules/local/snippy/snp_sites.nf'
include { GUBBINS                } from '../modules/local/gubbins/gubbins.nf'
include { SNP_DISTS              } from '../modules/local/snp_dists/snp_dists.nf'
include { PANAROO                } from '../modules/local/panaroo/panaroo.nf'
include { IQTREE                 } from '../modules/local/iqtree/iqtree.nf'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-validation'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_bactrail_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BACTRAIL_ANALYZE {

    take:
    organism
    db_name
    cluster
    collection_date_start
    collection_date_end
    ch_versions

    main:
    ch_multiqc_files = Channel.empty()

    PULL (
        organism,
        db_name,
        cluster,
        collection_date_start,
        collection_date_end
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

    if (params.remove_recombinants) {
        GUBBINS (
            SNIPPY_CLEAN.out.cleaned
        )

        SNP_SITES (
            GUBBINS.out.gubbins_filtered
        )

        SNP_DISTS (
            SNP_SITES.out.snp_selected
        )

        // add conditions specific versions
        ch_versions = ch_versions.mix(GUBBINS.out.version, SNP_SITES.out.version, SNP_DISTS.out.version)
    }

    else {
        SNP_SITES (
            SNIPPY_CLEAN.out.cleaned
        )

        SNP_DISTS (
            SNP_SITES.out.snp_selected
        )

        // add condition specific versions
        ch_versions = ch_versions.mix(SNP_SITES.out.version, SNP_DISTS.out.version)
    }

    PANAROO (
        PULL.out.gff.collect()
    )

    IQTREE (
        PANAROO.out.core
    )

    // mix all multiqc files
    ch_versions = ch_versions.mix(PULL.out.version, SNIPPY_CORE.out.version, SNIPPY_CLEAN.out.version,
        PANAROO.out.version, IQTREE.out.version)


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
