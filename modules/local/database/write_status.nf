process WRITE_STATUS {
    tag "status"
    label "process_single"

    input:
    val(statuses)

    output:
    path("insert_status.csv"), emit: status_output

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    echo
    update_statuses.py -s '${statuses}'
    """
}
