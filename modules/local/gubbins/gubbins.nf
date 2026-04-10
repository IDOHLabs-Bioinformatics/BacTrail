process GUBBINS {
    label 'process_medium'
    tag "recombinant removal"

    container "staphb/gubbins:3.4.1"

    input:
    tuple val(cluster), path(cleaned_alignment)

    output:
    tuple val(cluster), path("*.filtered_polymorphic_sites.fasta"), emit: gubbins_filtered
    path("version.yml"),                                            emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    run_gubbins.py \\
        -p ${cluster} \\
        ${args} \\
        ${cleaned_alignment}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        gubbins: \$(run_gubbins.py --version)
    END_VERSIONS
    """

    stub:
    """
    touch gubbins.filtered_polymorphic_sites.fasta

    cat << END_VERSIONS > version.yml
    "${task.process}":
        gubbins: \$(run_gubbins.py --version)
    END_VERSIONS
    """

}
