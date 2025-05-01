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
    tuple val(meta), path("*.gff"), emit: gff
    tuple val(meta), path("*.err"), emit: err
    tuple val(meta), path("*.faa"), emit: faa
    tuple val(meta), path("*.fna"), emit: fna
    tuple val(meta), path("*.fsa"), emit: fsa
    tuple val(meta), path("*.gbk"), emit: gbk
    tuple val(meta), path("*.sqn"), emit: sqn
    tuple val(meta), path("*.tbl"), emit: tbl
    tuple val(meta), path("*.tsv"), emit: tsv
    tuple val(meta), path("*.txt"), emit: txt
    tuple val(meta), path("*.log"), emit: log
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

    mv ${prefix}/* .

    cat << END_VERSIONS > version.yml
    "${task.process}":
        prokka: \$(prokka -v |& sed -e "s/prokka //g")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: ${meta.id}
    """
    touch empty.gff
    touch empty.err
    touch empty.faa
    touch empty.fna
    touch empty.fsa
    touch empty.gbk
    touch empty.sqn
    touch empty.tbl
    touch empty.tsv
    touch empty.txt
    touch empty.log


    cat << END_VERSIONS > version.yml
    "${task.process}":
        prokka: \$(prokka -v |& sed -e "s/prokka //g")
    END_VERSIONS
    """
}
