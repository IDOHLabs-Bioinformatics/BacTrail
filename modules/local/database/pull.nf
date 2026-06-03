process PULL {
    tag "Pull"
    label "process_low"

    container "staphb/pandas:3.0.1"

    input:
    val(organism)
    val(sample_list)
    path(database)
    val(cluster)
    val(collection_date_start)
    val(collection_date_end)

    output:
    path('*.fasta'),      emit: fasta
    path("*.fna"),        emit: reference
    path('*.gff'),        emit: gff
    path('*.aligned.fa'), emit: aln
    path('*.vcf'),        emit: vcf
    path("version.yml"),  emit: version

    script:
    """
    db_pull.py \\
        --database ${database} \\
        --organism ${organism} \\
        --sample_list ${sample_list} \\
        --cluster ${cluster} \\
        --collection_date_start ${collection_date_start} \\
        --collection_date_end ${collection_date_end}

    cat << END_VERSIONS > version.yml
    "${task.process}":
        sqlite3: \$(echo 'import sqlite3;print(sqlite3.version);' | python3)
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
        sqlite3: \$(echo 'import sqlite3;print(sqlite3.version);' | python3)
    END_VERSIONS
    """
}

