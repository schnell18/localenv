# Contributing to localenv

First off, thank you for considering contributing to localenv. It's people like you that make
localenv such a great tool. This document is intended to establish guidelines and best practise to
make changes to fix bugs or implement new features. Following these guidelines helps to communicate
that you respect the time of the developers managing and developing this open source project. In
return, they should reciprocate that respect in addressing your issue, assessing changes, and
helping you finalize your pull requests.

## Who can contribute?

Contribution doesn't have to be submit pull request with code change. Beside code, contributions
also include but not limited to submitting detailed bug report that can be reproduced easily,
engaging in issue discussion and supplying insightful analysis, providing relevant information.

Therefore contributors include:
- Users that found a bug,
- Users that want to propose new functionalities or enhancements,
- Users that want to help other users to troubleshoot their environments,
- Developers that want to fix bugs,
- Developers that want to implement new functionalities or enhancements.

## Development environment setup

Note: Some steps are OPTIONAL but all are RECOMMENDED.

1. Fork the project repository and clone it:

   ```shell
   $ git clone https://github.com/USERNAME/localenv.git
   $ cd localenv
   ```

2. Install podman a Python virtual environment. Example using
   [homebrew](https://brew.sh/):

    ```shell
    $ brew install podman
    ```

   On Linux, use the distribution-specific package manager to install podman. For example, on
   Debian/Unbutu based distributions, run:
    ```shell
    $ sudo apt-get install -y podman
    ```

3. (OPTIONAL) Install `pre-commit` git hook scripts
   (https://pre-commit.com/#3-install-the-git-hook-scripts):

   ```shell
   $ pre-commit install
   ```

4. Create a new branch, develop and add tests when possible.
5. Run linting and testing before committing code. Ensure all the hooks are passing.

   ```shell
   $ pre-commit run --all-files
   ```

6. Commit your code to your fork's branch.
   - Make sure you include a `Signed-off-by` message in your commits.
     Read [this guide](https://github.com/containers/common/blob/main/CONTRIBUTING.md#sign-your-prs)
     to learn how to sign your commits.
   - In the commit message, reference the Issue ID that your code fixes and a brief description of
     the changes.
     Example: `Fixes #516: Allow empty network`
7. Open a pull request to `schnell18/localenv` and wait for a maintainer to review your work.

## Adding new middlewares

When you plan to introduce a new infra to be managed by localenv, you need follow these guidelines:

- If the infra requires login, set the seed user's login name to `localenv` and password to `localenv`
- The docker-compose.yml should be named as `descriptor.yml`
- Map the storage to represent internal state to the files on host under the `.state` directory so
  that the middleware state survives computer reboot.
- Use official container image or derivatives with known Dockerfile based on automated image build and
  publish so that the image can be reproduced and scrutinized for security audit.
- You may custom official container image for inclusion of additional tools, patching startup
  scripts, or simply make it running as root. In this case, the Dockerfile and the github actions
  workflow to build and publish the image must be included in the PR. See files under `Containfiles`
  and `.github/workflow` for inspiration.
- The infras run in a rootless podman process, therefore it doesn't matter to use root in the
  container. In fact, it is recommended to use root as it facilitates file sharing between host and
  container.

The major effort to add a middleware (a.k.a. infra) centers on creating a docker-compose file named
`descriptor.yml`. You specify image of the middleware, persistent state storage or log directories
structure under the `.state` sub-folder. And you come up additional supporting shell and Powershell
scripts as pre and post hooks. All these files should be organized into a sub tree as follows:

    xxx
    ├── descriptor.yml
    └── provision
        ├── conf1
        │   └── files relevant to the middleware
        ├── post
        │   ├── setup.ps1
        │   ├── setup.sh
        │   └── webui.txt
        ├── pre
        │   ├── prepare.ps1
        │   └── prepare.sh
        ├── schema
        │   ├── data
        │   │   ├── 01-roles.csv
        │   │   └── 02-users.csv
        │   └── schema.sql

The files and directires under the `provision` folder are optional. The scripts under the
`provision/pre` folder are pre hooks to execute any preparation tasks before the container is
launched. The scripts inside the `provision/post` folders are post hooks to run any action after the
containers are started. The `webui.txt` file specifies the URL of the admin Web
UI of the middleware. The localenv will launch the default browser to navigate to the admin Web UI
when the webui is ready. The `schema` folder holds the database schema file and initial data
in .csv format (delimited by vertical bar, instead of comma). These files are useful when the
middleware depends on a rational database.
