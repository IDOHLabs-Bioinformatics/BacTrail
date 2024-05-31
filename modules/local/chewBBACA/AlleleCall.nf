process ALLELE_CALL {
    label "process_medium"
    tag "Allele_call"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/chewbbaca:3.3.5--pyhdfd78af_0' :
        'biocontainers/chewBBACA:3.3.5--pyhdfd78af_0' }"

    input:
    path(assembly_file)
    path(schema)
    val(organism)
    // path(training_file) // is this needed at all? Use whats in the schema directory, and it should be constant then

    output:
    tuple val(meta), path("*${organism}"), emit: allele_call
    path("version.yml"),                   emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    date=\$(data +"%F")

    chewBBACA.py \\
        AlleleCall \\
        --input-files ${assembly} \\
        --schema-directory ${schema} \\
        --output-directory \$date_${organism} \\
        # --training-file ${training_file} \\
        --cpu-cores ${task.cpus} \\
        ${args}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    END_VERSIONS
    """

    stub:
    """
    date=$(data +"%F")
    mkdir \$date_${organism}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        chewBBACA: \$(chewBBACA.py -v | sed -e "s/chewBBACA version: //g")
    END_VERSIONS
    """
}
