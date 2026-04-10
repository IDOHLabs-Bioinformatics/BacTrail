process SNIPPY_CORE {
    label "process_medium"
    tag "${cluster}"

    container "staphb/snippy:4.6.0"

    input:
    tuple val(cluster), path(fasta), path(align), path(vcf)
    path(ref)

    output:
    tuple val(cluster), path("*.aln"),           emit: core_aln
    tuple val(cluster), path("*.full.aln"),      emit: wg_align
    tuple val(cluster), path("*.ref.fa"),        emit: ref
    tuple val(cluster), path("*.tab"),           emit: core_snps
    tuple val(cluster), path("*.txt"),           emit: stats
    tuple val(cluster), path("*.vcf"),           emit: vcf
    tuple val(cluster), path("*.self_mask.bed"), emit: bed, optional: true
    path("version.yml"),                         emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    for file in *.fasta; do
      handle=\$(echo \$file | awk -F '.fasta' '{print\$1}')
      mkdir \$handle
      mv \$file \$handle
      mv \$handle.aligned.fa \$handle
      mv \$handle.vcf \$handle
    done

    ls

    ls -d */

    snippy-core \\
        --ref ${ref} \\
        --prefix ${cluster}_core \\
        ${args} \\
        \$(ls -d */)

    cat << END_VERSION > version.yml
    "${task.process}":
        snippy: \$(snippy -v | sed -e "s/snippy //g")
    END_VERSION
    """

    stub:
    """
    touch empty.aln
    touch empty.full.aln
    touch empty.ref.fa
    touch empty.tab
    touch empty.txt
    touch empty.vcf

    cat << END_VERSION > version.yml
    "${task.process}":
        snippy: \$(snippy -v | sed -e "s/snippy //g")
    """
}
