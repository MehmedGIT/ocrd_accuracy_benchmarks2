nextflow.enable.dsl = 2

params.mets_path = "null"
params.input_file_grp = "OCR-D-IMG"
params.workspace_path = "null"
params.docker_pwd = "null"
params.docker_volume = "$params.workspace_path:$params.docker_pwd"
params.docker_models_dir = "null"
params.models_path = "null"
params.docker_models = "$params.models_path:$params.docker_models_dir"
params.docker_image = "null"
params.docker_command = "docker run --rm -u \$(id -u) -v $params.docker_volume -v $params.docker_models -w $params.docker_pwd -- $params.docker_image"

log.info """\
    Odem Workflow
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

process ocrd_cis_ocropy_binarize_0 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-cis-ocropy-binarize -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp} -p '{"dpi": 300}'
        """
}

process ocrd_anybaseocr_crop_1 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-anybaseocr-crop -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp} -p '{"dpi": 300}'
        """
}

process ocrd_cis_ocropy_denoise_2 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-cis-ocropy-denoise -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp} -p '{"dpi": 300}'
        """
}

process ocrd_cis_ocropy_deskew_3 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-cis-ocropy-deskew -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp} -p '{"level-of-operation": "page"}'
        """
}

process ocrd_tesserocr_segment_region_4 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-tesserocr-segment-region -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp} -p '{"padding": 5.0, "find_tables": false, "dpi": 300}'
        """
}

process ocrd_segment_repair_5 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-segment-repair -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp} -p '{"plausibilize": true, "plausibilize_merge_min_overlap": 0.7}'
        """
}

process ocrd_cis_ocropy_clip_6 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-cis-ocropy-clip -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp}
        """
}

process ocrd_cis_ocropy_segment_7 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-cis-ocropy-segment -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp} -p '{"dpi": 300}'
        """
}

process ocrd_cis_ocropy_dewarp_8 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-cis-ocropy-dewarp -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp}
        """
}

process ocrd_tesserocr_recognize_9 {
    maxForks 1

    input:
        path mets_file
        val input_file_grp
        val output_file_grp

    output:
        path mets_file

    script:
        """
        ${params.docker_command} ocrd-tesserocr-recognize -m ${mets_file} -I ${input_file_grp} -O ${output_file_grp} -p '{"model": "Fraktur"}'
        """
}

workflow {
    main:
        ocrd_cis_ocropy_binarize_0(params.mets_path, params.input_file_grp, "OCR-D-BINPAGE")
        ocrd_anybaseocr_crop_1(ocrd_cis_ocropy_binarize_0.out, "OCR-D-BINPAGE", "OCR-D-SEG-PAGE-ANYOCR")
        ocrd_cis_ocropy_denoise_2(ocrd_anybaseocr_crop_1.out, "OCR-D-SEG-PAGE-ANYOCR", "OCR-D-DENOISE-OCROPY")
        ocrd_cis_ocropy_deskew_3(ocrd_cis_ocropy_denoise_2.out, "OCR-D-DENOISE-OCROPY", "OCR-D-DESKEW-OCROPY")
        ocrd_tesserocr_segment_region_4(ocrd_cis_ocropy_deskew_3.out, "OCR-D-DESKEW-OCROPY", "OCR-D-SEG-BLOCK-TESSERACT")
        ocrd_segment_repair_5(ocrd_tesserocr_segment_region_4.out, "OCR-D-SEG-BLOCK-TESSERACT", "OCR-D-SEGMENT-REPAIR")
        ocrd_cis_ocropy_clip_6(ocrd_segment_repair_5.out, "OCR-D-SEGMENT-REPAIR", "OCR-D-CLIP")
        ocrd_cis_ocropy_segment_7(ocrd_cis_ocropy_clip_6.out, "OCR-D-CLIP", "OCR-D-SEGMENT-OCROPY")
        ocrd_cis_ocropy_dewarp_8(ocrd_cis_ocropy_segment_7.out, "OCR-D-SEGMENT-OCROPY", "OCR-D-DEWARP")
        ocrd_tesserocr_recognize_9(ocrd_cis_ocropy_dewarp_8.out, "OCR-D-DEWARP", "OCR-D-OCR")
}
