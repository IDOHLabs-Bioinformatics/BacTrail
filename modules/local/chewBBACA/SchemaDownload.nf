process SCHEMA_DOWNLOAD {
    label "process_low"
    tag "${organism}"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/chewbbaca:3.3.5--pyhdfd78af_0' :
        'biocontainers/chewBBACA:3.3.5--pyhdfd78af_0' }"

    input:
    val(organism)

    output:
    tuple val("${organism}"), path("${organism}/*"), emit: schema, optional: true
    path("version.yml"),   emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    species_id=\$(python ${projectDir}/bin/schema_ids.py -o ${organism})
    if [ \$species_id != "" ]; then
        chewBBACA.py \\
            DownloadSchema \\
            -sp \$species_id \\
            -sc 1 \\
            -o ${organism} \\
            --cpu ${task.cpus} \\
            ${args}
    fi
    cat << END_VERSIONS > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    END_VERSIONS
    """

    stub:
    """
    mkdir ${organism}
    mkdir ${organism}/schema

    cat << END_VERSIONS > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    END_VERSIONS
    """
}
