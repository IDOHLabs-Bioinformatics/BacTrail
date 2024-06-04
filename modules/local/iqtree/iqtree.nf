process IQTREE {
    label "process_medium"
    tag "tree_build"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/iqtree:2.3.4--h21ec9f0_0' :
        'biocontainers/iqtree:2.3.4--h21ec9f0_0' }"

    input:
    path(aln)

    output:
    path("*.iqtree"),   emit: 'iqtree'
    path("*.treefile"), emit: 'treefile'
    path("*.bionj"),    emit: 'bionj'
    path("*.mldist"),   emit: 'mldist'
    path("*.log"),      emit: 'log'

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    iqtree \\
        -s ${aln} \\
        ${args}

    cat << END_VERSION > version.yml
    "${task.process}":
        iqtree: \$(iqtree -version | head -n 1 | cut -d ' ' -f 4)
    END_VERSION
    """

    stub:
    """
    touch empty.iqtree
    touch empty.treefile
    touch empty.bionj
    touch empty.mldist
    touch empty.log

    cat << END_VERSION > version.yml
    "${task.process}":
        iqtree: \$(iqtree -version | head -n 1 | cut -d ' ' -f 4)
    END_VERSION
    """
}
