process FILTER_CONTIGS {
    tag "${meta.id}"
    label "process_low"

    container "staphb/seqtk:1.5"

    input:
    tuple val(meta), path(assembly)
    val min_contig_len

    output:
    tuple val(meta), path("*_filtered_contigs.fasta"), emit: filtered_contigs
    path "version.yml",                                emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    seqtk seq -L ${min_contig_len} ${assembly} > ${prefix}_filtered_contigs.fasta

    cat <<-END_VERSIONS > version.yml
    "${task.process}":
        seqtk: \$(seqtk |& head -n 3 | tail -n 1 | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_filtered_contigs.fasta

    cat <<-END_VERSIONS > version.yml
    "${task.process}":
        seqtk: \$(seqtk |& head -n 3 | tail -n 1 | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
