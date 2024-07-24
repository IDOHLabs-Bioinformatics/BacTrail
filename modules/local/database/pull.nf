process PULL {
    tag "Pull"
    label "process_low"

    input:
    val(organism)
    val(database)

    output:
    path('*.fasta'),     emit: fasta
    path('*.gff'),       emit: gff
    path('*.aln'),       emit: aln
    path('*.vcf'),       emit: vcf
    path("version.yml"), emit: version

    script:
    """
    name=\$(python ${projectDir}/bin/db_pull.py -o ${organism} -d ${database})

    cat << END_VERSIONS > version.yml
    "${task.process}":
        sqlite3: \$(echo 'import sqlite3;print(sqlite3.version);' | python)
    END_VERSIONS
    """

    stub:
    """
    name='id'
    touch empty.fasta
    touch empty.gff
    touch empty.aln
    touch empty.vcf

    cat << END_VERSIONS > version.yml
    "${task.process}":
        sqlite3: \$(echo 'import sqlite3;print(sqlite3.version);' | python)
    END_VERSIONS
    """
}

