#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

MODELS_DIR="~/ocrd_models"
echo "OCR-D models dir: $MODELS_DIR"
DOCKER_IMAGE="ocrd/all:maximum"
DOCKER_MODELS_DIR="/usr/local/share"
DOCKER_PWD="/data"

WORKSPACES_ROOT="$SCRIPT_DIR/workspaces"
WORKFLOWS_ROOT="$SCRIPT_DIR/workflows"

NF_PATH_DEFAULT_WF="$WORKFLOWS_ROOT/default_workflow.nf"
NF_PATH_ODEM_WF="$WORKFLOWS_ROOT/odem_workflow.nf"
NF_PATH_DINGLEHOPPER_WF="$WORKFLOWS_ROOT/dinglehopper.nf"

function run_nf_workflow() {
	# $1 - workflow path
	# $2 - workspace dir path
	# $3 - mets path
	# $4 - input file group

	echo "Running nextflow workflow: $1"
	echo "Workspace dir: $2"
	echo "Input file grp: $4"
	nextflow run "$1" \
	-ansi-log true \
	-with-report \
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
	WS_DIR_PATH="$2/data"
	METS_PATH="$WS_DIR_PATH/mets.xml"
	echo "Processing workspace: $WS_DIR_PATH"
	run_nf_workflow $1 $WS_DIR_PATH $METS_PATH "OCR-D-IMG"
	run_nf_workflow $NF_PATH_DINGLEHOPPER_WF $WS_DIR_PATH $METS_PATH "OCR-D-GT-SEG-PAGE,OCR-D-OCR"

}

for ws_dir in $WORKSPACES_ROOT/*; do
    recognize_and_evaluate $NF_PATH_ODEM_WF $ws_dir
done
