#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

MODELS_DIR="~/ocrd_models/ocrd-resources"
echo "OCR-D models dir: $MODELS_DIR"
DOCKER_IMAGE="ocrd/all:latest"
DOCKER_MODELS_DIR="/usr/local/share/ocrd-resources"
DOCKER_PWD="/data"

WORKSPACES_ROOT="$SCRIPT_DIR/workspaces"
WORKFLOWS_ROOT="$SCRIPT_DIR/workflows"

NF_PATH_REPORTS="$SCRIPT_DIR/nf_reports"
NF_PATH_OPERANDI_WF="$WORKFLOWS_ROOT/operandi_workflow.nf"
NF_PATH_ODEM_WF="$WORKFLOWS_ROOT/odem_workflow.nf"
NF_PATH_SBB_WF="$WORKFLOWS_ROOT/sbb_workflow.nf"
NF_PATH_SBB_WF2="$WORKFLOWS_ROOT/sbb_workflow2.nf"
NF_PATH_SBB_WF3="$WORKFLOWS_ROOT/sbb_workflow3.nf"
NF_PATH_DINGLEHOPPER_WF="$WORKFLOWS_ROOT/dinglehopper.nf"

function run_nf_workflow() {
	# $1 - workflow path
	# $2 - workspace dir path
	# $3 - mets path
	# $4 - input file group
	REPORT_PATH="$NF_PATH_REPORTS/$(basename $1 .nf)/$(basename $2).html"
	echo "Running nextflow workflow: $1"
	echo "Workspace dir: $2"
	echo "Input file grp: $4"
	echo "Report path: $REPORT_PATH"
	nextflow run "$1" \
	-ansi-log true \
	-with-report "$REPORT_PATH" \
	--docker_image="$DOCKER_IMAGE" \
	--models_path="$MODELS_DIR" \
	--docker_models_dir="$DOCKER_MODELS_DIR" \
	--docker_pwd="$DOCKER_PWD" \
	--workspace_path="$2" \
	--mets_path="$3" \
	--input_file_grp="$4"
}

function recognize_and_evaluate() {
	# S1 - workflow path
	# $2 - workspace dir
	# $3 - report file name
	WS_DIR_PATH="$2"
	METS_PATH="$WS_DIR_PATH/mets.xml"
	echo "Processing workspace: $WS_DIR_PATH"
	run_nf_workflow $1 $WS_DIR_PATH $METS_PATH "OCR-D-IMG"
	run_nf_workflow $NF_PATH_DINGLEHOPPER_WF $WS_DIR_PATH $METS_PATH "OCR-D-GT-SEG-PAGE,OCR-D-OCR"

}

for ws_dir in $WORKSPACES_ROOT/*; do
    recognize_and_evaluate $NF_PATH_SBB_WF2 $ws_dir
done
