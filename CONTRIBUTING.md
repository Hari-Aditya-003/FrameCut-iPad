# Contributing

Contributions to FrameCut-iPad are welcome: clearer documentation, reproducible bug reports, focused fixes, and tested improvements.

## Before starting

Read the [README](README.md), search existing issues and pull requests, and open an issue for a substantial feature or change in project direction. For small documentation fixes, a focused pull request is enough.

## Fork and branch

Fork this repository using GitHub, then clone your fork. Replace `YOUR-USERNAME` in the commands below:

```bash
git clone https://github.com/YOUR-USERNAME/FrameCut-iPad.git
cd FrameCut-iPad
git remote add upstream https://github.com/Hari-Aditya-003/FrameCut-iPad.git
git fetch upstream
git switch -c docs/describe-your-change upstream/main
```

Use descriptive branch names such as `docs/setup-guide`, `fix/import-error`, or `feat/short-description`. Target pull requests at `main`. A fork is your copy of the repository; a branch groups one change inside a repository. Stars express interest and do not grant write access.

## Setup and checks

Open `FrameCut.xcodeproj`, use the shared `FrameCut` scheme, and run Product > Test. For command-line checks and signing/distribution, see [deployment](docs/DEPLOYMENT.md).

Report Xcode version, simulator/device, iPadOS version, and test result. UI and export changes should include device checks and screenshots where useful. Keep local signing credentials and provisioning files out of the pull request.

## Submit a pull request

Keep the diff focused. Explain the problem, resulting behavior, and exact verification performed. Link a related issue when one exists. Documentation changes should use working relative links and commands that start from an explicit directory.

```bash
git add <changed-files>
git commit -m "docs: clarify setup instructions"
git push -u origin docs/describe-your-change
```

Open a pull request from your branch to this repository's `main`. Complete the PR template and respond to review feedback. Do not include unrelated generated files, personal editor state, credentials, or private user data.

## Report a bug or request a feature

Use the issue templates. Include the source commit, environment, steps to reproduce, expected result, observed result, and relevant sanitized logs. For a feature, describe the user problem, a proposed outcome, and alternatives.

## Licensing

This repository currently has no root license file. Public visibility does not by itself grant a reusable software license. Do not add a license or claim one on the maintainer's behalf; discuss licensing with the owner if your use requires an explicit grant.
