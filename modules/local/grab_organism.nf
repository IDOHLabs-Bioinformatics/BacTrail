process GRAB_ORGANISM {
    label "process_low"
    tag "${meta.organism}"

    input:
    tuple val(meta), path(reads), path(reference)

    output:
    val(meta.organism), emit: organism

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    """

    stub:
    """
    """
}
