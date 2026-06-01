process FASTANI {
    label 'process_medium'
    tag "${meta.id}"

    container "staphb/fastani:1.34"

    input:
    tuple val(meta), path(assembly)
    path(reference_list)
    path(reference_dir)

    output:
    path("version.yml"),                  emit: version
    path("*.txt")

    script:
    """
    fastANI \\
        -q ${assembly} \\
        --rl ${reference_list} \\
        -o ${meta.id}_fastani.txt

    touch version.yml
    ls > files.txt
    """
}
