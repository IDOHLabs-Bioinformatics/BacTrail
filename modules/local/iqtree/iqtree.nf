process IQTREE {
    label "process_medium"
    tag "tree_build"

    container "staphb/iqtree:1.6.7"

    input:
    path(aln)

    output:
    path("*.iqtree"),   emit: 'iqtree'
    path("*.treefile"), emit: 'treefile'
    path("*.bionj"),    emit: 'bionj'
    path("*.mldist"),   emit: 'mldist'
    path("*.log"),      emit: 'log'

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    // TODO: What if there are only 2 sequences? Do I catch or just assume that this a non-issue
    """
    iqtree \\
        -s ${aln} \\
        ${args}

    cat << END_VERSION > version.yml
    "${task.process}":
        iqtree: \$(iqtree -version | head -n 1 | cut -d ' ' -f 4)
    END_VERSION
    """

    stub:
    """
    touch empty.iqtree
    touch empty.treefile
    touch empty.bionj
    touch empty.mldist
    touch empty.log

    cat << END_VERSION > version.yml
    "${task.process}":
        iqtree: \$(iqtree -version | head -n 1 | cut -d ' ' -f 4)
    END_VERSION
    """
}
