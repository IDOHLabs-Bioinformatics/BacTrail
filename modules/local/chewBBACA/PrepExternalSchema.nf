process PREP_EXTERNAL_SCHEMA {
    label "process_medium"
    tag "schema_prep"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/chewbbaca:3.3.5--pyhdfd78af_0' :
        'biocontainers/chewBBACA:3.3.5--pyhdfd78af_0' }"

    input:
    tuple val(organism), path(schema)

    output:
    path("${organism}_schema"), emit: schema
    path("version.yml"),        emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    chewBBACA.py \\
        PrepExternalSchema \\
        --schema-directory ${schema} \\
        --output-directory ${organism}_schema \\
        --cpu ${task.cpus} \\
        ${args}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    END_VERSIONS
    """

    stub:
    """
    mkdir ${organism}_schema

    cat << END_VERSIONS > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    END_VERSIONS
    """
}
