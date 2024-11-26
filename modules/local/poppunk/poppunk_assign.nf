process POPPUNK_ASSIGN {
    label 'process_medium'
    tag "${organism}"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/poppunk:2.7.2--py312hda6a541_0' :
        'biocontainers/poppunk:2.7.2--py312hda6a541_0' }"

    input:
    tuple val(organism), val(db), path(query), val(meta), path(assembly)
    val(schema_base)

    output:
    path("poppunk_clusters/poppunk_clusters_clusters.csv"), emit: clusters
    path("version.yml"),                                    emit: version

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
          --output poppunk_clusters
    else
      poppunk_assign \\
          --db ${schema_base}/${db} \\
          --query ${query} \\
          --output poppunk_clusters
    fi

    cat << END_VERSIONS > version.yml
    "${task.process}":
        poppunk: \$(poppunk --version | cut -f 2 -d ' ')
    END_VERSIONS
    """

    stub:
    """

    """

}
