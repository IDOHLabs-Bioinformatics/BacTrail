process DOWNLOAD_CHECK {
    label "process_low"
    tag "check"

    input:
    val(meta)
    val(schemas)

    output:
    stdout

    when:
    task.ext.when == null || task.ext.when

    shell:
    """
    cd !{schemas}
    for file in *
      do
        compare=\$(echo \$file | awk -F '_' '{print\$1 "_" \$2}')
        if [ "\$compare" != "!{meta}" ]; then
          result=!{meta}
        else
          result=""
          break
        fi
      done
    echo \$result
    """

    stub:
    """
    echo ''
    """

}
