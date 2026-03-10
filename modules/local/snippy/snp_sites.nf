process SNP_SITES {
    label "process_low"
    tag "snp_sites"

    container "staphb/snippy:4.6.0"


    input:
    path(alignment)

    output:
    path("clean.core.aln"), emit: snp_selected
    path("version.yml"),    emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    snp-sites \\
        -c ${alignment} \\
         ${args} \\
         > clean.core.aln

    cat << END_VERSION > version.yml
    "${task.process}":
        snp-sites: \$(snp-sites -V | cut -d ' ' -f 2)
    END_VERSION
    """

    stub:
    """
    touch clean.core.aln

    cat << END_VERSION > version.yml
    "${task.process}":
        snp-sites: \$(snp-sites -V | cut -d ' ' -f 2)
    END_VERSION
    """
}
