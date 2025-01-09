process UPDATE_DB {
    tag "${id}"
    label "process_single"
    maxForks 1

    input:
    tuple val(organism), val(id), path(assembly), path(gff), path(snippy), path(clusters)
    val db_name

    output:
    path("version.yml"), emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    python ${projectDir}/bin/update_db.py \\
        -d ${db_name} \\
        -i ${id} \\
        -o ${organism} \\
        -a ${assembly} \\
        -g ${gff} \\
        -f ${snippy}/snps.aligned.fa \\
        -v ${snippy}/snps.vcf \\
        -r ${snippy}/reference/ref.fa \\
        -c ${clusters}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        sqlite3: \$(echo 'import sqlite3;print(sqlite3.version);' | python)
    END_VERSIONS
    """

    stub:
    """
    cat << END_VERSIONS > version.yml
    "${task.process}":
        sqlite3: \$(echo 'import sqlite3;print(sqlite3.version);' | python)
    END_VERSIONS
    """
}
