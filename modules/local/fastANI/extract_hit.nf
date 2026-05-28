process EXTRACT_HIT {
    label 'process_single'
    tag "${meta.id}"

    container "staphb/pandas:3.0.1" 

    input:
    tuple val(meta), path(fastani)
    path(reference_dir)

    output:
    tuple val(meta), env(ref),                       emit: best_hit_ref
    tuple val(meta), env(organism),                  emit: organism
    path("version.yml"),                             emit: version

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    top_fastANI.py > output.txt
    ref=\$(head -n 1 output.txt)
    organism=\$(tail -n 1 output.txt)

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastANI: \$(fastANI -v 2>&1 | head -n 1 | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    ref='test'
    organism='test'

    cat << END_VERSIONS > version.yml
    "${task.process}":
        fastANI: \$(fastANI -v 2>&1 | head -n 1 | cut -d ' ' -f 2)
    END_VERSIONS
    """
}