process SNP_DISTS {
    label "process_low"
    tag "snp_dists"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/snp-dists:0.8.2--he4a0461_4' :
        'biocontainers/snp-dists:0.8.2--he4a0461_4' }"


    input:
    path(cleaned_alignment)

    output:
    path("dists.txt"),      emit: snp_selected
    path("version.yml"),    emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    snp-dists ${cleaned_alignment} > dists.txt

    cat << END_VERSION > version.yml
    "${task.process}":
        snp-dists: \$(snp-dists -v | sed -e "s/snippy //g")
    END_VERSION
    """

    stub:
    """
    touch dists.txt

    cat << END_VERSION > version.yml
    "${task.process}":
        snippy: \$(snp-dists -v | cut -d ' ' -f 2")
    END_VERSION
    """
}
