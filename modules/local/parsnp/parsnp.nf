process PARSNP {
    label "process_medium"
    tag "core genome"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/parsnp:2.0.5--hdcf5f25_0' :
        'biocontainers/parsnp:2.0.5--hdcf5f25_0' }"

    input:
    path(assemblies)

    output:
    path("core_genome/*.xmfa"),    emit: alignment
    path("core_genome/*.ggr"),     emit: visual
    path("core_genome/*.mblocks"), emit: mblocks
    path("core_genome/*.tree"),    emit: tree

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    parsnp \\
        -d *.fasta \\
        -o core_genome \\
        ${args}

    cat << END_VERSION > version.yml
    "${task.process}":
        parsnp: \$(parsnp -V | sed -e "s/parsnp //g")
    END_VERSION
    """

    stub:
    """
    mkdir core_genome
    touch core_genome/empty.xmfa
    touch core_genome/empty.ggr
    touch core_genome/empty.mblocks
    touch core_genome/empty.trees

    cat << END_VERSION > version.yml
    "${task.process}":
        parsnp: \$(parsnp -V | sed -e "s/parsnp //g")
    END_VERSION
    """
}
