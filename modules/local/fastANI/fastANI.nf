process FASTANI {
    label 'process_medium'
    tag "${meta.id}"

    container "staphb/fastani:1.34"

    input:
    tuple val(meta), path(assembly)

    output:
    path("version.yml"),                  emit: version

    script:
    """
    touch version.yml
    """
}
