process SKESA {
    label 'process_high'
    tag '${meta.id}'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fasta"), emit: assembly
    tuple val(meta), path("*.log"),   emit: log
    path("version.yml"),              emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = ${meta.id}
    """
    skesa \\
        --reads ${reads[0]},${reads[1]} \\
        --cores ${task.cpus} \\
        --contigs_out ${prefix}_contigs.fasta
        ${args} \\
        2> ${prefix}.log

    cat << END_VERSIONS > version.yml
    "${task.process}":
        skesa: \$(skesa --version | sed -e "s/SKESA //g")
    """

    stub:
    def prefix = ${meta.id}
    """
    touch ${prefix}_contigs.fasta
    touch ${prefix}.log

    cat << END_VERSIONS > version.yml
    "${task.process}":
        skesa: \$(skesa --version | sed -e "s/SKESA //g")
    """
}
