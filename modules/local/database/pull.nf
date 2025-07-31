process PULL {
    tag "Pull"
    label "process_low"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'staphb/pandas' :
        'quay.io/staphb/pandas' }"

    input:
    val(organism)
    val(database)
    val(cluster)

    output:
    path('*.fasta'),     emit: fasta
    path("*.fna"),       emit: reference
    path('*.gff'),       emit: gff
    path('*.aligned.fa'),       emit: aln
    path('*.vcf'),       emit: vcf
    path("version.yml"), emit: version

    script:
    """
    db_pull.py -o ${organism} -d ${database} -c ${cluster}

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

