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
    tuple val(meta), path("reference"),              emit: reference
    tuple val(meta), path("snps.aligned.fa"),        emit: aligned
    tuple val(meta), path("snps.bam"),               emit: bam
    tuple val(meta), path("snps.bed"),               emit: bed
    tuple val(meta), path("snps.consensus.fa"),      emit: consensus
    tuple val(meta), path("snps.consensus.subs.fa"), emit: consensus_subs
    tuple val(meta), path("snps.csv"),               emit: csv
    tuple val(meta), path("snps.gff"),               emit: gff
    tuple val(meta), path("snps.filt.vcf"),          emit: filt_vcf
    tuple val(meta), path("snps.html"),              emit: html
    tuple val(meta), path("snps.log"),               emit: log
    tuple val(meta), path("snps.raw.vcf"),           emit: raw_vcf
    tuple val(meta), path("snps.subs.vcf"),          emit: subs_vcf
    tuple val(meta), path("snps.tab"),               emit: tab
    tuple val(meta), path("snps.txt"),               emit: txt
    tuple val(meta), path("snps.vcf"),               emit: vcf
    path("version.yml"),                             emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = "${meta.id}"
    """
    snippy \\
    --cpus ${task.cpus} \\
    --outdir ${prefix}_snippy \\
    --ref ${ref} \\
    --R1 ${reads[0]} \\
    --R2 ${reads[1]} \\
    ${args}

    mv ${prefix}_snippy/* .
    cat << END_VERSIONS > version.yml
    "${task.process}":
        snippy: \$(snippy -v | sed -e "s/snippy //g")
    END_VERSIONS
    """

    stub:
    def prefix = ${meta.id}
    """
    mkdir ${meta.id}_snippy
    touch ${meta.id}_snippy/reference
    touch ${meta.id}_snippy/snps.aligned.fa
    touch ${meta.id}_snippy/snps.bam
    touch ${meta.id}_snippy/snps.bed
    touch ${meta.id}_snippy/snps.consensus.fa
    touch ${meta.id}_snippy/snps.consensus.subs.ba
    touch ${meta.id}_snippy/snps.csv
    touch ${meta.id}_snippy/snps.gff
    touch ${meta.id}_snippy/snps.filt.vcf
    touch ${meta.id}_snippy/snps.html
    touch ${meta.id}_snippy/snps.log
    touch ${meta.id}_snippy/snps.raw.vcf
    touch ${meta.id}_snippy/snps.subs.vcf
    touch ${meta.id}_snippy/snps.tab
    touch ${meta.id}_snippy/snps.txt
    touch ${meta.id}_snippy/snps.vcf

    cat << END_VERSIONS > version.yml
    """
}

