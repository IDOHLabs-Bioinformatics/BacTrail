process FASTP {
    label 'process_medium'
    tag "${meta.id}"

    container "staphb/fastp:1.1.0"

    input:
    tuple val(meta), path(reads)
    val(length_required)

    output:
    tuple val(meta), path("*trimmed.fastq.gz"), emit: trimmed
    tuple val(meta), path("*.json"),            emit: json
    tuple val(meta), path("*.html"),            emit: html
    tuple val(meta), path("*.log"),             emit: log
    path("version.yml"),                        emit: version


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    fastp \\
        --in1 ${reads[0]} \\
        --in2 ${reads[1]} \\
        --out1 ${prefix}_1_trimmed.fastq.gz \\
        --out2 ${prefix}_2_trimmed.fastq.gz \\
        --length_required ${length_required} \\
        --json ${prefix}.json \\
        --html ${prefix}.html \\
        --thread ${task.cpus} \\
        ${args} \\
        2> ${prefix}.log

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_1_trimmed.fastq.gz
    touch ${prefix}_2_trimmed.fastq.gz
    touch ${prefix}.json
    touch ${prefix}.html

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    END_VERSIONS
    """
}
