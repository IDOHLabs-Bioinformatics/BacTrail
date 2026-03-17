process UPDATE_DB {
    tag "${meta.id}"
    label "process_single"
    maxForks 1

    container "staphb/pandas:3.0.1"

    input:
    tuple val(organism), val(meta), path(assembly), path(gff), path(snippy), val(collection_date), path(clusters)
    val db_name
    val replace

    output:
    env(status),         emit: status
    path("version.yml"), emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    if [ "${replace}" == "False" ]; then
      status=\$(update_db.py \\
          -d ${db_name} \\
          -i ${meta.id} \\
          -o ${organism[0]} \\
          -a ${assembly} \\
          -g ${gff} \\
          -f ${snippy}/snps.aligned.fa \\
          -v ${snippy}/snps.vcf \\
          -r ${snippy}/reference/ref.fa \\
          -c ${clusters} \\
          -s ${collection_date[0]})
    else
      status=\$(update_db.py \\
          -d ${db_name} \\
          -i ${meta.id} \\
          -o ${organism[0]} \\
          -a ${assembly} \\
          -g ${gff} \\
          -f ${snippy}/snps.aligned.fa \\
          -v ${snippy}/snps.vcf \\
          -r ${snippy}/reference/ref.fa \\
          -c ${clusters} \\
          -s ${collection_date[0]} \\
          --replace)
    fi

    cat << END_VERSIONS > version.yml
    "${task.process}":
        sqlite3: \$(echo 'import sqlite3;print(sqlite3.version);' | python3)
    END_VERSIONS
    """

    stub:
    """
    cat << END_VERSIONS > version.yml
    "${task.process}":
        sqlite3: \$(echo 'import sqlite3;print(sqlite3.version);' | python3)
    END_VERSIONS
    """
}
