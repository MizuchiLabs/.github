# MizuchiLabs shared config

Reusable workflows, a renovate preset and config templates for all MizuchiLabs repos.

## Workflows

| Workflow          | What it does                                                                                                                                                                                                      |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `go-ci.yaml`      | Builds and checks `web/` if present, `go mod tidy -diff`, golangci-lint, `go test -race -shuffle=on`, govulncheck, `goreleaser check`, actionlint                                                                 |
| `go-release.yaml` | Computes the next version with git-cliff, runs `go-ci` on that commit, tags, then releases with goreleaser or a plain GitHub release for libraries. Retries a tag that has no release yet. Removes untagged images |
| `go-nightly.yaml` | On every push to main, builds the `kos` image with ko, pushes `:nightly`, signs it and removes the previous one |
| `actionlint.yaml` | Lints workflows, for repos that are not Go                                                                                                                                                                        |

Callers live in `templates/go/workflows/`, copy them into a new repo. Extra jobs go next to the shared one:

```yaml
jobs:
  ci:
    uses: MizuchiLabs/.github/.github/workflows/go-ci.yaml@main
```

Callers pin `@main` on purpose so a fix lands everywhere at once. Everything inside this repo is SHA pinned and renovate keeps it fresh.

Self-hosted runners keep their own caches. Hosted runners only save the Go and pnpm caches from `main`, other branches restore from it. Release and nightly builds skip the Actions cache and start from empty Go caches on any runner.

Conventions the workflows rely on:

- `go.mod` at the root, `.goreleaser.yaml` (not `.yml`) if the repo ships binaries
- a frontend lives in `web/` with `packageManager` set, `check` and `lint` scripts are run when they exist
- `kos:` in the goreleaser config turns on nightly images, the ghcr login and image cleanup, the nightly reads `main`, `base_image`, `repositories` and `platforms` from the first entry
- a kata/licx public key is passed as the `LICENSE_PUBLIC_KEY` secret and read as `.Env.LICENSE_PUBLIC_KEY`
- a `RUNNER` variable on a repo or the org moves every job to that runner label, `self-hosted` for the home runners. Fork PRs always stay on hosted runners

## Releases

Releases run every Wednesday at 03:40 UTC (early morning in Vienna), and only when commits since the last tag change what ships. Commits that only touch docs, CI, tests or dev config don't count, and neither do `chore(deps)` updates. The list lives in `GIT_CLIFF_EXCLUDE_PATH` in `go-release.yaml`. A `sec` commit on main releases right away. The first release is always cut by hand, with a `v*` tag or a manual run. Stable image tags are never deleted, only untagged leftovers and the previous nightly.

## Renovate

Each repo's `.github/renovate.json` only extends `local>MizuchiLabs/.github`, the rules live in `default.json`. Everything automerges, CI is the gate. Updates under `web/` are committed as `fix(deps)` because they ship in the binary, vulnerability fixes as `sec(deps)` so they release immediately.

## Templates

`templates/` holds files that can't be referenced remotely. Run `./sync.sh` to copy them into the sibling checkouts, `./sync.sh --check` to only report drift.
