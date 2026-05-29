process FASTANI {
    label 'process_medium'
    tag "${meta.id}"

    container "staphb/busco:6.0.0"

    input:
    tuple val(meta), path(assembly)

    output:
    path("version.yml"),                  emit: version

    script:
    """
    touch version.yml
    """
}
