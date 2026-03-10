process PANAROO {
    label 'process_high'
    tag "core_genome"

    container "staphb/panaroo:1.6.0"

    input:
    path(gffs)

    output:
    path("core_genome/core_gene_alignment.aln"), emit: core
    path("version.yml"),   emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    panaroo \\
        -i *.gff \\
        -o core_genome \\
        --clean-mode strict \\
        -a core \\
        -t ${task.cpus} \\
        $args

    cat << END_VERSIONS > version.yml
    "${task.process}":
        panaroo: \$(panaroo --version | sed -e "s/panaroo //g")
    END_VERSIONS
    """

    stub:
    """
    today=\$(date +%F)
    mkdir \$today_core_genome

    cat << END_VERSIONS > version.yml
    "${task.process}":
        panaroo: \$(panaroo --version | sed -e "s/panaroo //g")
    """
}
