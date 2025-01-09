process SNIPPY_CORE {
    label "process_medium"
    tag "snippy_core"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/snippy:4.6.0--hdfd78af_1' :
        'biocontainers/snippy:4.6.0--hdfd78af_1' }"

    input:
    path(fasta)
    path(align)
    path(vcf)
    path(ref)

    output:
    path("*.aln"),           emit: core_aln
    path("*.full.aln"),      emit: wg_align
    path("*.ref.fa"),        emit: ref
    path("*.tab"),           emit: core_snps
    path("*.txt"),           emit: stats
    path("*.vcf"),           emit: vcf
    path("*.self_mask.bed"), emit: bed, optional: true
    path("version.yml"),     emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    directories=''
    for file in *.fasta; do
      handle=\$(echo \$file | awk -F '.fasta' '{print\$1}')
      mkdir \$handle
      mv \$file \$handle
      mv \$handle.aligned.fa \$handle
      mv \$handle.vcf \$handle
    done

    snippy-core \\
        --ref ${ref} \\
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
