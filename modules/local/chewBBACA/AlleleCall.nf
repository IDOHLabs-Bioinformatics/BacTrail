process ALLELE_CALL {
    label "process_high"
    tag "Allele_call"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/chewbbaca:3.3.5--pyhdfd78af_0' :
        'biocontainers/chewBBACA:3.3.5--pyhdfd78af_0' }"

    input:
    tuple val(organism), path(assemblies), path(schema)

    // path(training_file) // is this needed at all? Use whats in the schema directory, and it should be constant then

    output:
    tuple val(organism), path(schema), path("*${organism}"), emit: dir
    path("*${organism}/cds_coordinates.tsv"),                emit: coords
    path("*${organism}/loci_summary_stats.tsv"),             emit: summary_stats
    path("*${organism}/paralogous_counts.tsv"),              emit: paralogous_counts
    path("*${organism}/results_alleles.tsv"),                emit: result_alleles
    path("*${organism}/results_statistics.tsv"),             emit: result_stats
    path("*${organism}/invalid_cds.txt"),                    emit: invalid
    path("*${organism}/logging_info.txt"),                   emit: logging_info
    path("*${organism}/paralogous_loci.tsv"),                emit: paralogous_loci
    path("*${organism}/results_contigsInfo.tsv"),            emit: info
    path("version.yml"),                                     emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    date=\$(date +"%F")

    chewBBACA.py \\
        AlleleCall \\
        --input-files . \\
        --schema-directory ${schema} \\
        --output-directory \$(date +"%F")_${organism} \\
        --cpu-cores ${task.cpus} \\
        ${args}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    END_VERSIONS
    """

    stub:
    """
    mkdir \$(date +"%F")_${organism}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    END_VERSIONS
    """
}
