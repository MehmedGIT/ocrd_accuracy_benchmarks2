nextflow.enable.dsl = 2

params.mets_path = "null"
params.input_file_grp = "OCR-D-GT-SEG-LINE,OCR-D-OCR"
params.workspace_path = "null"
params.docker_pwd = "null"
params.docker_volume = "$params.workspace_path:$params.docker_pwd"
params.docker_models_dir = "null"
params.models_path = "null"
params.docker_models = "$params.models_path:$params.docker_models_dir"
params.docker_image = "null"
params.docker_command = "docker run --rm -u \$(id -u) -v $params.docker_volume -v $params.docker_models -w $params.docker_pwd -- $params.docker_image"

log.info """\
    Dinglehopper
    ===========================================
    docker_image        : ${params.docker_image}
    input_file_grp      : ${params.input_file_grp}
    mets_path           : ${params.mets_path}
    workspace_path      : ${params.workspace_path}
    docker_pwd          : ${params.docker_pwd}
    docker_volume       : ${params.docker_volume}
    docker_models_dir   : ${params.docker_models_dir}
    models_path         : ${params.models_path}
    docker_models       : ${params.docker_models}
    docker_command      : ${params.docker_command}
    """
    .stripIndent()

process ocrd_dinglehopper_0 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-dinglehopper -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp} -P textequiv_level line
        """
}

workflow {
    main:
        ocrd_dinglehopper_0(params.mets_path, params.input_file_grp, "OCR-D-EVAL-SEG-LINE")
}
