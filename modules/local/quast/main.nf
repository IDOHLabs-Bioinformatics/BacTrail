process QUAST {
    label 'process_low'
    tag "${meta.id}"

    container "staphb/quast:5.3.0"

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("${meta.id}_quast/report.tsv"),  emit: report_tsv
    tuple val(meta), path("${meta.id}_quast/report.html"), emit: report_html
    tuple val(meta), path("${meta.id}_quast/report.pdf"),  emit: report_pdf


    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    quast.py \\
        -o ${prefix}_quast \\
        -t ${task.cpus} \\
        ${assembly}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        quast: \$(quast.py -v | awk -F ' ' '{print \$2}')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir ${prefix}_quast
    touch ${prefix}_quast/report.tsv
    touch ${prefix}_quast/report.html
    touch ${prefix}_quast/report.pdf

    cat << END_VERSIONS > version.yml
    "${task.process}":
        quast: \$(quast.py -v | awk -F ' ' '{print \$2}')
    END_VERSIONS
    """
}
