process SNIPPY {
    label "process_medium"
    tag "${meta.id}"

    container "staphb/snippy:4.6.0"

    input:
    tuple val(meta), path(reads), path(ref)

    output:
    tuple val(meta), path("${meta.id}_snippy"), emit: results
    path("version.yml"),                        emit: version

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

