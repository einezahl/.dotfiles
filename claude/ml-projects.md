# ML / training project conventions

Opt a repo into these rules by adding `@~/.claude/ml-projects.md` to its `CLAUDE.md`.

## Configuration & CLI

- One YAML per run under `options/{train,test,infer}/` (or a Hydra config tree). Variations → new files, not in-place edits. Keep the filename and the run's internal `name` in sync.
- Scripts take a single `-opt path/to/config.yml` argument (or equivalent Hydra invocation). Hyperparameters, paths, and model knobs live in the YAML, not in argparse flags. This keeps every run fully reproducible from its config file.
- Record the pretrained weights path explicitly in the config. Fine-tuning from an EMA-trained checkpoint → remember to point the param-key to the EMA state.

## Experiment tracking

- Wrap every call to the tracking backend (MLflow / W&B / ...) in a class whose methods catch-and-warn. Logging must never abort training.
- Metric keys: `train/<name>` or `val/<name>`. Log a summed `train/loss_total` even when components are also logged.
- Log the training YAML and the latest checkpoint as artifacts.
- With a SQLite-backed MLflow, set an explicit artifact root on shared storage — the CWD-relative default will put artifacts on `$TMPDIR` or node-local scratch and they'll disappear.

## Checkpoint policy

- Default: save `<model>_best_<metric>` (overwritten on improvement) + `<model>_final`. Skip per-iter dumps unless debugging training stability.
- Resume states (optimizer + RNG) are multi-GB for transformer-sized models. First thing to exclude from any mirror; only emit if resume-from-crash is a real requirement.

## Inference bundles (self-describing outputs)

An inference output directory must be self-describing. A reviewer six months later, given only the directory, should be able to reconstruct how the predictions were produced. Always copy in:

- the inference config,
- the model weights file,
- the training config,
- the training log.

## HPC workflow

- Multi-login-node clusters load-balance `ssh <cluster>` across hosts. For MLflow UIs, SSH tunnels, and anything stateful, pin both sides to a specific host (`ssh <clusterN>`, or run `hostname` on the server side and use that).
- Rsync experiment directories incrementally (`rsync -avhL --info=progress2`). Size+mtime comparison is faster than `--checksum` and usually correct. The `-L` flag materializes weight symlinks (e.g. `*_latest.pth`) as real local files.
