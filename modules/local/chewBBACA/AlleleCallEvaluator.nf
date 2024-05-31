process ALLELE_CALL_EVALUATOR {
    label "process_medium"
    tag "Allele_call"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/chewbbaca:3.3.5--pyhdfd78af_0' :
        'biocontainers/chewBBACA:3.3.5--pyhdfd78af_0' }"

    input:
    path(allele_results)
    path(schema)
    path(organism)

    output:
    path("*_${organism}")
    path("version.yml"), emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    date=\$(date +"%F")

    chewBBACA.py \\
        AlleleCallEvaluator \\
        --input-files ${allele_results} \\
        --schema-directory ${schema} \\
        --output-directory \$date_${organism}
        --cpu ${task.cpus} \\
        ${args}

    cat << VERSIONS_END > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    VERSIONS_END
    """

    stub:
    """
    cat << VERSIONS_END > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    """
}
