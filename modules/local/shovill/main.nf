process SHOVILL {
    tag "${meta.id}"
    label "process_medium"

    container "staphb/shovill:1.4.2"

    input:
    tuple val(meta), path(reads)
    val(depth)

    output:
    tuple val(meta), path("assembly/contigs.fa"), emit: assembly
    path("version.yml"),                                    emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    shovill \\
        --outdir assembly \\
        --R1 ${reads[0]} \\
        --R2 ${reads[1]} \\
        --depth ${depth} \\
        --cpus ${task.cpus} \\
        --assembler spades

    cat << END_VERSIONS > version.yml
    "${task.process}":
        shovill: \$(shovill -v | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    """
    mkdir -p assembly
    touch assembly/contigs.fa

    cat << END_VERSIONS > version.yml
    "${task.process}":
        shovill: \$(shovill -v | cut -d ' ' -f 2)
    END_VERSIONS
    """


}