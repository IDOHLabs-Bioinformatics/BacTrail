process PANAROO {
    label 'process_high'
    tag "core_genome"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/panaroo:1.5.0--pyhdfd78af_0' :
        'biocontainers/panaroo:1.5.0--pyhdfd78af_0' }"

    input:
    path(gffs)

    output:
    path("*_core_genome"), emit: core
    path("version.yml"),   emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    today=\$(date +%F)

    panaroo \\
        -i *.gff \\
        -o \$today_core_genome \\
        --clean-mode strict \\
        $args

    cat << END_VERSIONS > version.yml
    "${task.process}":
        panaroo: \$(panaroo --version | sed -e "s/panaroo //g")
    END_VERSIONS
    """

    stub:
    """
    today=\$(date +%F)
    mkdir \$today_core_genome

    cat << END_VERSIONS > version.yml
    "${task.process}":
        panaroo: \$(panaroo --version | sed -e "s/panaroo //g")
    """
}
