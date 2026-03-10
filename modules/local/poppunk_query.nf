process POPPUNK_QUERY {
    label 'process_low'
    tag "${organism[0]}"

    container "staphb/pandas:3.0.1"

    input:
    tuple val(organism), path(assemblies)

    output:
    tuple val(organism), path("*popPUNK_query.txt"), emit: query
    path("version.yml"),                             emit: version

    script:
    """
    make_poppunk_query.py -a '${assemblies}' -o ${organism[0]}

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
