process POPPUNK_ASSIGN {
    label 'process_medium'
    tag "${organism}"

    container "staphb/poppunk:2.7.5"

    input:
    tuple val(organism), val(db), path(query), path(assembly)
    val(schema_base)

    output:
    tuple val(organism), path("*poppunk_clusters.csv"), emit: clusters
    path("version.yml"),                                emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    base=\$(echo ${schema_base})
    last_character=\$(echo \$base | rev | cut -c 1)
    if [ \$(echo \$base | rev | cut -c 1) == / ]; then
      poppunk_assign \\
          --db ${schema_base}${db} \\
          --query ${query} \\
          --output poppunk_clusters \\
          ${args}
    else
      poppunk_assign \\
          --db ${schema_base}/${db} \\
          --query ${query} \\
          --output poppunk_clusters \\
          ${args}
    fi

    mv poppunk_clusters/poppunk_clusters_clusters.csv ${organism}_poppunk_clusters.csv

    cat << END_VERSIONS > version.yml
    "${task.process}":
        poppunk: \$(poppunk --version | cut -f 2 -d ' ')
    END_VERSIONS
    """

    stub:
    """
    touch poppunk_clusters/poppunk_clusters_clusters.csv

    cat << END_VERSIONS > version.yml
    "${task.process}":
        poppunk: \$(poppunk --version | cut -f 2 -d ' ')
    END_VERSIONS
    """

}
