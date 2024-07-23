process DOWNLOAD_CHECK {
    label "process_low"
    tag "check"

    input:
    val(organism)
    val(schemas)

    output:
    env need,  emit: needed
    env avail, emit: available

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    need=\$(python ${projectDir}/bin/download_check.py -t ${organism} -s ${schemas} 2> err.tmp)
    avail=\$(cat err.tmp)
    rm err.tmp
    """

    stub:
    """
    need=\$(echo '')
    avail=\$(echo '')
    """

}
