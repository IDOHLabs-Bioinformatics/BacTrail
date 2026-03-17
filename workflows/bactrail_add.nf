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
include { FASTP                  } from '../modules/local/fastp/main.nf'
include { KRAKEN2                } from '../modules/local/kraken/kraken2.nf'
include { DATABASE_VERIFY        } from '../modules/local/database_verify.nf'
include { POPPUNK_ASSIGN         } from '../modules/local/poppunk/poppunk_assign.nf'
include { SNIPPY                 } from '../modules/local/snippy/snippy.nf'
include { SPADES                 } from '../modules/local/spades/spades.nf'
include { FILTER_CONTIGS         } from '../modules/local/seqtk/main.nf'
include { QUAST                  } from '../modules/local/quast/main.nf'
include { BUSCO                  } from '../modules/local/busco/main.nf'
include { FASTANI                } from '../modules/local/fastANI/fastANI.nf'
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
    ch_samplesheet     // channel: samplesheet read in from --input
    ch_reference_list  // channel: file of list of references for fastANI
    ch_reference_dir   // channel: directory of references for fastANI
    ch_schema_dir      // channel: directory of the popPUNK schemas
    ch_kraken2_db      // channel: kraken2 database
    ch_db              // channel: output database
    ch_versions        // channel: versions

    main:
    ch_multiqc_files = Channel.empty()

    ch_samplesheet
        .map { meta, reads, organism, reference, collection_date -> organism }
        .unique()
        .set{ organisms }

    //
    // MODULE: Database verify
    //
    DATABASE_VERIFY (
        ch_schema_dir,
        organisms
    )

    //
    // MODULE: fastp
    FASTP (
        ch_samplesheet
            .map{ meta, reads, organism, reference, collection_date -> tuple(meta, reads) },
        params.length_required
    )

    //
    // MODULE: Kraken2
    //
    KRAKEN2 (
        FASTP.out.trimmed,
        ch_kraken2_db
    )

    //
    // MODULE: Spades
    //
    SPADES (
        FASTP.out.trimmed
    )

    //
    // MODULE: Seqtk seq
    //
    FILTER_CONTIGS (
        SPADES.out.assembly,
        params.min_contig_length
    )

    //
    // MODULE: Quast
    //
    QUAST (
        FILTER_CONTIGS.out.filtered_contigs
    )

    //
    // MODULE: BUSCO
    //
    BUSCO (
        FILTER_CONTIGS.out.filtered_contigs
    )

    //
    // MODULE: fastANI
    //
    FASTANI (
        FILTER_CONTIGS.out.filtered_contigs,
        ch_reference_list.first(),
        ch_reference_dir.first()
    )

    //
    // MODULE: Make popPUNK query file
    //
    POPPUNK_QUERY (
        FILTER_CONTIGS.out.filtered_contigs
        .combine(ch_samplesheet, by:0)
        .groupTuple(by:3)
        .map { meta, assembly, reads, organism, reference, collection_date -> tuple(organism, assembly)}
    )

    //
    // MODULE: popPUNK cluster assignment
    //
    POPPUNK_ASSIGN (
        DATABASE_VERIFY.out.organism_schema
        .combine(POPPUNK_QUERY.out.query, by:0)
        .combine(FILTER_CONTIGS.out.filtered_contigs
                .combine(ch_samplesheet, by:0)
                .groupTuple(by:3)
                .map { meta, assembly, reads, organism, reference, collection_date -> tuple(organism, assembly)}
                , by:0),
        ch_schema_dir
    )

    //
    // MODULE: Prokka
    //
    PROKKA (
        FILTER_CONTIGS.out.filtered_contigs
    )

    //
    // MODULE: Snippy
    //
    SNIPPY (
        FASTP.out.trimmed
            .join(FASTANI.out.best_hit_ref)
    )

    UPDATE_DB (
        FILTER_CONTIGS.out.filtered_contigs
        .join(PROKKA.out.gff)
        .join(SNIPPY.out.results)
        .join(ch_samplesheet
                .map { meta, reads, organism, reference, collection_date -> tuple(meta, organism, collection_date) }
        )
        .map { meta, assembly, gff, snippy, organism, collection_date -> tuple(organism, meta, assembly, gff, snippy, collection_date) }
        .combine(POPPUNK_ASSIGN.out.clusters, by: 0),
        ch_db.first(),
        params.replace.toString().capitalize()
    )

    WRITE_STATUS(
        UPDATE_DB.out.status.collect()
    )

    ch_versions = ch_versions.mix(DATABASE_VERIFY.out.version, FASTP.out.version, KRAKEN2.out.version, SPADES.out.version,
        FILTER_CONTIGS.out.version, QUAST.out.version, BUSCO.out.version, FASTANI.out.version, POPPUNK_QUERY.out.version,
        POPPUNK_ASSIGN.out.version, PROKKA.out.version, SNIPPY.out.version, UPDATE_DB.out.version)

    ch_multiqc_files = ch_multiqc_files.mix(KRAKEN2.out.report.collect{it[1]}, FASTP.out.json.collect{it[1]},
        QUAST.out.report_tsv.collect{it[1]}, BUSCO.out.busco.collect{it[1]}, SNIPPY.out.summary.collect{it[1]})

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
