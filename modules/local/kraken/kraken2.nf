process KRAKEN2 {
    label 'process_medium'
    tag "${meta.id}"

    container "staphb/kraken2:2.17.1"

    input:
    tuple val(meta), path(reads)
    path(db)

    output:
    tuple val(meta), path("*_kraken_report.txt"), emit: report
    env("top_hit"),                               emit: top_hit
    path("version.yml"),                          emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = ''
    def prefix = task.ext.prefix = "${meta.id}"
    """
    kraken2 \\
        --db ${db} \\
        --paired \\
        --report ${prefix}_kraken_report.txt \\
        ${args} \\
        ${reads[0]} \\
        ${reads[1]} \\
        > /dev/null

    awk '\$4 == "S"' ${prefix}_kraken_report.txt > species.txt
    sort -nrk2 species.txt > sorted_species.txt
    head -n 1 sorted_species.txt > top_species.txt
    awk -F '  ' '{print\$NF}' > organism.txt
    sed -i 's/^[      ]*//' organism.txt 
    sed -i 's/ /_/g' organism.txt

    top_hit=\$(cat organism.txt)

    cat << END_VERSIONS > version.yml
    "${task.process}":
        kraken2: \$(kraken2 -v | head -n 1 | cut -d ' ' -f 3)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix = "${meta.id}"
    """
    touch ${prefix}_kraken_report.txt

    cat << END_VERSIONS > version.yml
    "${task.process}":
        kraken2: \$(kraken2 -v | head -n 1 | cut -d ' ' -f 3)
    END_VERSIONS
    """
}
