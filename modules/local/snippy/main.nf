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
    tuple val(meta), path("${prefix}_snippy/reference"), emit: reference
    tuple val(meta), path("${prefix}_snippy/snps.aligned.fa"), emit: aligned
    tuple val(meta), path("${prefix}_snippy/snps.bam"), emit: bam
    tuple val(meta), path("${prefix}_snippy/snps.bed"), emit: bed
    tuple val(meta), path("${prefix}_snippy/snps.consensus.fa"), emit: consensus
    tuple val(meta), path("${prefix}_snippy/snps.consensus.subs.ba"), emit: consensus_subs
    tuple val(meta), path("${prefix}_snippy/snps.csv"), emit: csv
    tuple val(meta), path("${prefix}_snippy/snps.gff"), emit: gff
    tuple val(meta), path("${prefix}_snippy/snps.filt.vcf"), emit: filt_vcf
    tuple val(meta), path("${prefix}_snippy/snps.html"), emit: html
    tuple val(meta), path("${prefix}_snippy/snps.log"), emit: log
    tuple val(meta), path("${prefix}_snippy/snps.raw.vcf"), emit: raw_vcf
    tuple val(meta), path("${prefix}_snippy/snps.subs.vcf"), emit: subs_vcf
    tuple val(meta), path("${prefix}_snippy/snps.tab"), emit: tab
    tuple val(meta), path("${prefix}_snippy/snps.txt"), emit: txt
    tuple val(meta), path("${prefix}_snippy/snps.vcf"), emit: vcf
    path("version.yml"),                       emit: version

    when:
    task.ext.when == null || task.ext.when

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
    ${args}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        snippy: \$(snippy -v | sed -e "s/snippy //g")
    END_VERSIONS
    """

    stub:
    def prefix = ${meta.id}
    """
    mkdir ${prefix}_snippy
    touch ${prefix}_snippy/reference
    touch ${prefix}_snippy/snps.aligned.fa
    touch ${prefix}_snippy/snps.bam
    touch ${prefix}_snippy/snps.bed
    touch ${prefix}_snippy/snps.consensus.fa
    touch ${prefix}_snippy/snps.consensus.subs.ba
    touch ${prefix}_snippy/snps.csv
    touch ${prefix}_snippy/snps.gff
    touch ${prefix}_snippy/snps.filt.vcf
    touch ${prefix}_snippy/snps.html
    touch ${prefix}_snippy/snps.log
    touch ${prefix}_snippy/snps.raw.vcf
    touch ${prefix}_snippy/snps.subs.vcf
    touch ${prefix}_snippy/snps.tab
    touch ${prefix}_snippy/snps.txt
    touch ${prefix}_snippy/snps.vcf

    cat << END_VERSIONS > version.yml
    """
}

