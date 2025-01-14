process GUBBINS {
    label 'process_medium'
    tag "recombinant removal"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gubbins:3.4--py39pl5321he4a0461_0' :
        'biocontainers/gubbins:3.4--py39pl5321he4a0461_0' }"

    input:
    path(cleaned_alignment)

    output:
    path("gubbins.filtered_polymorphic_sites.fasta"), emit: gubbins_filtered

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    run_gubbins.py \\
        -p gubbins \\
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
