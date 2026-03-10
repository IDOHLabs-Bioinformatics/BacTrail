process SPADES {
    label 'process_high'
    tag "${meta.id}"

    container "staphb/spades:4.2.0"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("assembly/*_assembly.fasta"), emit: assembly
    path("version.yml"),                                emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix = "${meta.id}"
    """
    spades.py \\
        -1 ${reads[0]} \\
        -2 ${reads[1]} \\
        -o assembly \\
        -t ${task.cpus} \\
        --careful \\
        ${args} \\
        > ${prefix}.log

    mv assembly/contigs.fasta assembly/${prefix}_assembly.fasta

    cat << END_VERSIONS > version.yml
    "${task.process}":
        spades: \$(spades.py --version | cut -f 4 -d ' ')
    END_VERSIONS
    """

    stub:
    """
    mkdir assembly
    touch assembly/contigs.fasta

    cat << END_VERSIONS > version.yml
    "${task.process}":
        spades: \$(spades.py --version | cut -f 4 -d ' ')
    END_VERSIONS
    """
}
