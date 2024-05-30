process FASTP {
    label 'process_medium'
    tag "${meta.id}"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastp:0.23.4--h5f740d0_0' :
        'biocontainers/fastp:0.23.4--h5f740d0_0' }"

    input:
    tuple val(meta), path(reads)
    path(adapters)

    output:
    tuple val(meta), path("*trimmed.fastq.gz")

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def adapt_arg  = adapter_fasta ? "--adapter_fasta ${adapters}" : ''
    """
    fastp \\
        --in1 ${reads[0]} \\
        --in2 ${reads[1]} \\
        --out1 ${meta}_1_trimmed.fastq.gz
        --out2 ${meta}_2_trimmed.fastq.gz
        ${adapt_arg}
        --json ${meta}.json
        --html ${meta}.html
        --thread ${task.cpus}
        ${args}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    """

    stub:
    def args = task.ext.args ?: ''
    """
    touch ${meta}_1_trimmed.fastq.gz
    touch ${meta}_2_trimmed.fastq.gz
    touch ${meta}.json
    touch ${meta}.html

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    """
}
