process BUSCO {
    label 'process_medium'
    tag "${meta.id}"

    container "staphb/busco:6.0.0"

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("*busco"), emit: busco
    path("version.yml"),             emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix = "${meta.id}"
    """
    busco --auto-lineage -m geno -i ${assembly} -o ${prefix}_busco

    cat << END_VERSIONS > version.yml
    "${task.process}":
        BUSCO: \$(busco -v 2>&1 | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    """
    touch ${prefix}_busco

    cat << END_VERSIONS > version.yml
    "${task.process}":
        BUSCO: \$(busco -v 2>&1 | cut -d ' ' -f 2)
    END_VERSIONS
    """

}
