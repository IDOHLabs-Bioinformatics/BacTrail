process UPDATE_DB {
    tag "${meta.id}"
    label "process_single"

    input:
    tuple val(meta), path(reads), path(assembly), path(gff), path(aligned), path(vcf)
    val(db_name)

    output:
    path("version.yml"), emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    python ${projectDir}/bin/update_db.py \\
        -d ${db_name} \\
        -i ${meta.id} \\
        -o ${meta.org} \\
        -a ${assembly} \\
        -g ${gff} \\
        -f ${aligned} \\
        -v ${vcf}

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
