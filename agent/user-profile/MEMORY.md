This Windows machine: gh CLI is not installed and GitHub REST API via Invoke-WebRequest returns 403, but git itself has network access (git ls-remote works) and Node's fetch reaches api.github.com fine. So GitHub data scripts should use fetch, and never assume gh or PowerShell HTTP is available.
§
PowerShell here rejects heredocs (the <<EOF syntax fails to parse), so multi-line git commit messages must be written to a scratch file first and passed with `git commit -F <file>`. Also npm.ps1 is blocked by execution policy; call "C:\Program Files\nodejs\npm.cmd" instead.
§
Git Credential Manager here can silently hold a stale credential for the wrong GitHub account (Sit0527) or a read-only fine-grained PAT (github_pat_*, len 93). Fix: `git credential reject` with protocol=https/host=github.com, then run git-credential-manager github login. Always confirm with `git push --dry-run` and by reading /repos/{owner}/{repo} permissions (needs push:true) before declaring a push blocked.
