process SNIPPY {
    label "process_medium"
    tag "${meta.id}"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/snippy:4.6.0--hdfd78af_1' :
        'biocontainers/snippy:4.6.0--hdfd78af_1' }"

    input:
    tuple val(meta), path(reads)
    path(ref)

    output:
    tuple val(meta), path("${prefix}_snippy"), emit: res_dir
    path("version.yml"),                       emit: version

    script:
    def args = task.ext.args ?: ''
    def prefix = ${meta.id}
    """
    snippy \\
    --cpus ${task.cpus} \\
    --outdir ${prefix}_snippy \\
    --ref ${ref} \\
    --R1 ${reads[0]} \\
    --R2 ${reads[1]} \\
    > ${prefix}_snippy.log

    cat << END_VERSIONS > version.yml
    "${task.process}":
        snippy: \$(snippy -v | sed -e "s/snippy //g")
    END_VERSIONS
    """

    stub:
    def prefix = ${meta.id}
    """
    mkdir ${prefix}

    cat << END_VERSIONS > version.yml
    """
}

