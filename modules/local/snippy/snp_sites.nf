process SNP_SITES {
    label "process_low"
    tag "snp_sites"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/snippy:4.6.0--hdfd78af_1' :
        'biocontainers/snippy:4.6.0--hdfd78af_1' }"


    input:
    path(alignment)

    output:
    path("clean.core.aln"), emit: snp_selected
    path("version.yml"),    emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    snp-sites -c ${alignment} > clean.core.aln

    cat << END_VERSION > version.yml
    "${task.process}":
        snp-sites -V | cut -d ' ' -f 2
    END_VERSION
    """

    stub:
    """
    touch clean.core.aln

    cat << END_VERSION > version.yml
    "${task.process}":
        snp-sites -V | cut -d ' ' -f 2
    END_VERSION
    """
}
