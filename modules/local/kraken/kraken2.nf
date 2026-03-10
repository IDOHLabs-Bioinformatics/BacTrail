process KRAKEN2 {
    label 'process_medium'
    tag "${meta.id}"

    container "staphb/kraken2:2.17.1"

    input:
    tuple val(meta), path(reads)
    val(db)

    output:
    tuple val(meta), path("*_kraken_report.txt"), emit: report
    env("top_hit"),                               emit: top_hit
    path("versions.yml"),                         emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = ''
    def prefix = task.ext.prefix = "${meta.id}"
    """
    kraken2 \\
        --db ${db} \\
        --paired \\
        --report ${prefix}_kraken_report.txt \\
        ${args} \\
        ${reads[0]} \\
        ${reads[1]} \\
        > /dev/null

    top_hit=\$(awk '\$4 == "S"' ${prefix}_kraken_report.txt | sort -nrk2 | head -n 1 | awk -F '  ' '{print\$NF}' | sed 's/^[      ]*//' | sed 's/ /_/g')

    cat << END_VERSIONS > versions.yml
    "${task.process}":
        kraken2: \$(kraken2 -v | head -n 1 | cut -d ' ' -f 3)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix = "${meta.id}"
    """
    touch ${prefix}_kraken_report.txt

    cat << END_VERSIONS > versions.yml
    "${task.process}":
        kraken2: \$(kraken2 -v | head -n 1 | cut -d ' ' -f 3)
    END_VERSIONS
    """
}
