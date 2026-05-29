process FASTANI {
    label 'process_medium'
    tag "${meta.id}"

    input:
    tuple val(meta), path(assembly)

    output:
    path("version.yml"), emit: version

    script:
    """
    touch version.yml
    """
}