process KRAKEN2 {
    label 'process_medium'
    tag "${meta.id}"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'staphb/kraken2:2.1.1-no-db' :
        'quay.io/staphb/kraken2:2.1.1-no-db' }"

    input:
    tuple val(meta), path(reads)
    val(db)

    output:
    tuple val(meta), path("*_kraken_report.txt"),
    path("versions.yml")

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
