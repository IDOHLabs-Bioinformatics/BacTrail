process FASTANI {
    label 'process_medium'
    tag "${meta.id}"
    maxForks 1

    container "staphb/fastani:1.34"

    input:
    tuple val(meta), path(assembly)
    path(reference_list)
    path(reference_dir)

    output:
    tuple val(meta), path("*_fastani.txt"), emit: ani
    path("version.yml"), emit: version

    script:
    """
    fastANI \\
        -q ${assembly} \\
        --rl ${reference_list} \\
        -o ${meta.id}_fastani.txt

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastANI: \$(fastANI --version 2>&1 | head -n 1 | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    """
    touch ${meta.id}_fastani.txt

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastANI: \$(fastANI --version 2>&1 | head -n 1 | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
