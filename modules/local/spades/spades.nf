process SPADES {
    label 'process_high'
    tag "${meta.id}"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/spades:4.0.0--h5fb382e_0' :
        'biocontainers/spades:4.0.0--h5fb382e_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("assembly/*_assembly.fasta"),                emit: assembly
    tuple val(meta.org), val(meta), path("assembly/*_assembly.fasta"), emit: org_assembly
    path("version.yml"),                                            emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix = "${meta.id}"
    """
    spades.py \\
        -1 ${reads[0]} \\
        -2 ${reads[1]} \\
        -o assembly \\
        -t ${task.cpus} \\
        --isolate \\
        ${args} \\
        > ${prefix}.log

    mv assembly/contigs.fasta assembly/${prefix}_assembly.fasta

    cat << END_VERSIONS > version.yml
    "${task.process}":
        spades: \$(spades.py --version | cut -f 4 -d ' ')
    END_VERSIONS
    """

    stub:
    """
    mkdir assembly
    touch assembly/contigs.fasta

    cat << END_VERSIONS > version.yml
    "${task.process}":
        spades: \$(spades.py --version | cut -f 4 -d ' ')
    """

}
