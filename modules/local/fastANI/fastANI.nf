process FASTANI {
    label 'process_medium'
    tag "${meta.id}"
    maxForks 1

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("${meta.id}_fastANI.txt"), emit: ani
    path("version.yml"),                             emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${meta.id}_fastANI.txt
    touch version.yml
    """
}
