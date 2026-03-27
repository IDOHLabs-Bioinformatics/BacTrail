process SAFE_RENAME {
    tag "${meta[0]}"
    label = 'process_single'

    input:
    tuple val(meta), path(fasta), val(clean_fasta), path(aligned_fa), val(clean_aligned_fa), path(vcf), val(clean_vcf), path(gff), val(clean_gff)

    output:
    tuple val(meta), path("${clean_fasta}"), path("${clean_aligned_fa}"), path("${clean_vcf}"), path("${clean_gff}"), emit: cleaned

    script:
    """
    mv ${fasta} ${clean_fasta}
    mv ${aligned_fa} ${clean_aligned_fa}
    mv ${vcf} ${clean_vcf}
    mv ${gff} ${clean_gff}
    """

    stub:
    """
    touch ${clean_fasta}
    touch ${clean_aligned_fa}
    touch ${clean_vcf}
    touch ${clean_gff}
    """

}
