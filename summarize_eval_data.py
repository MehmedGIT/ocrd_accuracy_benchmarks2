from json import dumps, load
from pathlib import Path

script_dir = Path(__file__).resolve().parent
odem_workflow_results_path = Path(f"{script_dir}/results_odem_workflow")
operandi_workflow_results_path = Path(f"{script_dir}/results_operandi_workflow")
sbb_workflow_results_path = Path(f"{script_dir}/results_sbb_workflow")
sbb_workflow2_results_path = Path(f"{script_dir}/results_sbb_workflow2")
sbb_workflow3_results_path = Path(f"{script_dir}/results_sbb_workflow3")

summarized_results = {}

def read_workspace_eval_jsons(ws_path: Path):
    combined_results = []
    eval_f_grp = Path(f"{ws_path}/OCR-D-EVAL-SEG-LINE")
    for curr_file in eval_f_grp.iterdir():
        if curr_file.is_file() and curr_file.suffix == ".json":
            with Path(curr_file).open("r", encoding="UTF-8") as f_json:
                 curr_json = load(f_json)
                 combined_results.append(curr_json)
    return sorted(combined_results, key=lambda x: x['gt'])

def fill_summarized_results(path: Path, wf_name: str):
    summarized_results[wf_name] = {}
    for curr_file in path.iterdir():  
        if curr_file.is_dir():
            ws_json = read_workspace_eval_jsons(curr_file)
            ws_name = Path(curr_file).name
            summarized_results[wf_name][ws_name] = ws_json
    summarized_results[wf_name] = dict(sorted(summarized_results[wf_name].items()))

fill_summarized_results(odem_workflow_results_path, "odem_workflow.nf")
fill_summarized_results(operandi_workflow_results_path, "operandi_workflow.nf")
fill_summarized_results(sbb_workflow_results_path, "sbb_workflow.nf")

with open('summarized_results.json', 'w') as results_file: 
     results_file.write(dumps(summarized_results, indent=4))

