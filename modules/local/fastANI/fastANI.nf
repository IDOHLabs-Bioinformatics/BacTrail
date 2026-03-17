process FASTANI {
    label 'process_medium'
    tag "${meta.id}"

    container "staphb/fastani:1.34"

    input:
    tuple val(meta), path(assembly)
    path(reference_list)
    path(reference_dir)

    output:
    tuple val(meta), path("${meta.id}_fastANI.txt"), emit: ani
    tuple val(meta), path("${meta.id}_fastANI.log"), emit: log
    path("version.yml"),                            emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix = "${meta.id}"
    """
    fastANI \\
        -q ${assembly} \\
        --rl ${reference_list} \\
        -o ${prefix}_fastANI.txt \\
        -t ${task.cpus} \\
        ${args} \\
        2> ${prefix}_fastANI.log

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastANI: \$(fastANI -v 2>&1 | head -n 1 | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix = "${meta.id}"
    """
    touch ${prefix}_fastANI.txt
    touch ${prefix}_fastANI.log

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastANI: \$(fastANI -v 2>&1 | head -n 1 | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
