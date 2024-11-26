process POPPUNK_QUERY {
    label 'process_low'
    tag "${organism}"

    input:
    tuple val(organism), val(metas), path(assemblies)

    output:
    tuple val(organism), path("popPUNK_query.txt"), emit: query
    path("version.yml"),                            emit: verision

    script:
    """
    python ${projectDir}/bin/make_poppunk_query.py -a '${assemblies}'

    cat << END_VERSIONS > version.yml
    "${task.process}":
        python: \$(python --version | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    """
    touch popPUNK_query.txt

    cat << END_VERSIONS > version.yml
    "${task.process}":
        python: \$(python --version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
