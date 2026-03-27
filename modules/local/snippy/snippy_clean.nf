process SNIPPY_CLEAN {
    label "process_medium"
    tag "snippy_clean"

    container "staphb/snippy:4.6.0"

    input:
    path(full_aln)

    output:
    path("clean.full.aln"), emit: cleaned
    path("version.yml"),    emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    snippy-clean_full_aln \\
        ${args} \\
        ${full_aln} \\
        > clean.full.aln

    cat << END_VERSION > version.yml
    "${task.process}":
        snippy: \$(snippy -v | sed -e "s/snippy //g")
    END_VERSION
    """

    stub:
    """
    touch clean.full.aln

    cat << END_VERSION > version.yml
    "${task.process}":
        snippy: \$(snippy -v | sed -e "s/snippy //g")
    """
}
