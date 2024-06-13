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
    tuple val(meta), path("${meta.id}/*.gff"), emit: gff
    tuple val(meta), path("${meta.id}/*.err"), emit: err
    tuple val(meta), path("${meta.id}/*.faa"), emit: faa
    tuple val(meta), path("${meta.id}/*.fna"), emit: fna
    tuple val(meta), path("${meta.id}/*.fsa"), emit: fsa
    tuple val(meta), path("${meta.id}/*.gbk"), emit: gbk
    tuple val(meta), path("${meta.id}/*.sqn"), emit: sqn
    tuple val(meta), path("${meta.id}/*.tbl"), emit: tbl
    tuple val(meta), path("${meta.id}/*.tsv"), emit: tsv
    tuple val(meta), path("${meta.id}/*.txt"), emit: txt
    tuple val(meta), path("${meta.id}/*.log"), emit: log
    path("version.yml")

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def args = task.ext.args ?: ''
    """
    prokka \\
        --prefix ${prefix} \\
        --outdir ${prefix} \\
        --cpus ${task.cpus} \\
        ${args} \\
        ${assembly}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        prokka: \$(prokka -v |& sed -e "s/prokka //g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: ${meta.id}
    """
    touch ${meta.id}/empty.gff
    touch ${meta.id}/empty.err
    touch ${meta.id}/empty.faa
    touch ${meta.id}/empty.fna
    touch ${meta.id}/empty.fsa
    touch ${meta.id}/empty.gbk
    touch ${meta.id}/empty.sqn
    touch ${meta.id}/empty.tbl
    touch ${meta.id}/empty.tsv
    touch ${meta.id}/empty.txt
    touch ${meta.id}/empty.log


    cat << END_VERSIONS > version.yml
    "${task.process}":
        prokka: \$(prokka -v |& sed -e "s/prokka //g")
    END_VERSIONS
    """
}
