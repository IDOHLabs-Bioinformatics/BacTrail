process DATABASE_VERIFY {
    label 'process_low'
    tag "${organism[0]}"

    container "staphb/pandas:3.0.1"

    input:
    path(schema_dir)
    val(organism)

    output:
    tuple val(organism), env(schema_path), emit: organism_schema
    path("version.yml"),                   emit: version

    script:
    """
    schema_path=\$(database_verify.py \\
        -s ${schema_dir} \\
        -o ${organism[0]} \\
        )
    ln -s ${schema_dir}/\$schema_path \$schema_path
    cat << END_VERSIONS > version.yml
    "${task.process}":
        python: \$(python3 --version | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    """
    schema_path=\$(echo stub)

    cat << END_VERSIONS > version.yml
    "${task.process}":
        python: \$(python3 --version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
