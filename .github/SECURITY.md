# Security Policy

## Supported versions

behavior-kit is distributed from `main`. Only the latest commit on `main` is supported;
please update to the current scaffold (`bk --update`) before reporting an issue.

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Instead, use GitHub's private vulnerability reporting:

1. Go to the repository's **Security** tab.
2. Click **Report a vulnerability**.
3. Describe the issue, the affected files or commands, and steps to reproduce.

We'll acknowledge the report, investigate, and coordinate a fix and disclosure with you.
Because behavior-kit is installed by piping `install.sh` into a shell, reports about the
installer, scaffold scripts, or anything that could execute unexpected code in a user's
project are especially appreciated.
