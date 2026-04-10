process SNP_DISTS {
    label "process_low"
    tag "snp_dists"

    container "staphb/snp-dists:1.2.0"

    input:
    tuple val(cluster), path(cleaned_alignment)

    output:
    path("*dists.tsv"),      emit: snp_selected
    path("version.yml"),    emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    snp-dists ${cleaned_alignment} > ${cluster}_dists.tsv

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
