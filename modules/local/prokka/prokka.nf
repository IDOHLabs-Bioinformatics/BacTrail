process PROKKA {
    label "process_medium"
    tag "${meta.id}"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/prokka:1.14.6--pl5321hdfd78af_5' :
        'biocontainers/prokka:1.14.6--pl5321hdfd78af_5' }"

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("${prefix}/*.gff"), emit: gff
    tuple val(meta), path("${prefix}/*.err"), emit: err
    tuple val(meta), path("${prefix}/*.faa"), emit: faa
    tuple val(meta), path("${prefix}/*.fna"), emit: fna
    tuple val(meta), path("${prefix}/*.fsa"), emit: fsa
    tuple val(meta), path("${prefix}/*.gbk"), emit: gbk
    tuple val(meta), path("${prefix}/*.sqn"), emit: sqn
    tuple val(meta), path("${prefix}/*.tbl"), emit: tbl
    tuple val(meta), path("${prefix}/*.tsv"), emit: tsv
    tuple val(meta), path("${prefix}/*.txt"), emit: txt
    tuple val(meta), path("${prefix}/*.log"), emit: log
    path("version.yml")

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}""
    def args = task.ext.args ?: ''
    """
    prokka \\
        --prefix ${prefix} \\
        --outdir ${prefix} \\
        --cpus ${task.cpus} \\
        ${args}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        prokka: \$(prokka -v |& sed -e "s/prokka //g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: ${meta.id}
    """
    touch ${prefix}/empty.gff
    touch ${prefix}/empty.err
    touch ${prefix}/empty.faa
    touch ${prefix}/empty.fna
    touch ${prefix}/empty.fsa
    touch ${prefix}/empty.gbk
    touch ${prefix}/empty.sqn
    touch ${prefix}/empty.tbl
    touch ${prefix}/empty.tsv
    touch ${prefix}/empty.txt
    touch ${prefix}/empty.log


    cat << END_VERSIONS > version.yml
    "${task.process}":
        prokka: \$(prokka -v |& sed -e "s/prokka //g")
    END_VERSIONS
    """
}
