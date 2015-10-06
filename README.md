# Sah

Sah is command line util for [Atlassian Bitbucket Server](https://www.atlassian.com/software/bitbucket/server).

This project was heavily inspired by the [hub](https://hub.github.com/).

## (not impremented) Installation

    gem install sah

## (not impremented) Configuration

    git config [--global] sah.profile.default.user "f440"
    git config [--global] sah.profile.default.password "freq440@gmail.com"
    git config [--global] sah.profile.default.url "https://exmaple.com"

If you use multiple Bitbucket Server, define profile(s) and specify it.

    git config [--global] sah.profile.my_company.user "jane"
    git config [--global] sah.profile.my_company.password "jane@example.jp"
    git config [--global] sah.profile.my_company.url "https://git@exmaple.jp"

    sah SUB_COMMAND --profile my_company
    or
    export SAH_DEFAULT_PROFILE=my_company
    sah SUB_COMMAND

## Usage

### (not impremented) browse

    sah browse
    # browse current repository

    sah browse REMOTE
    # browse remote repository named REMOTE

    sah browse REPO
    # browse ~YOUR_NAME/REPO

    sah browse PROJECT/REPO
    # browse PROJECT/REPO

    sah browse --branch
    # browse branch list in current repository

    sah browse --branch BRANCH
    # browse BRANCH in current repository

    sah browse --commit COMMITHASH
    # browse COMMITHASH in current repository

    sah browse --pull-request
    # browse pull request list in current repository

    sah browse --pull-request PULL_REQUEST
    # browse PULL_REQUEST in current repository

### (not impremented) clone

    sah clone PROJECT/REPO [DIR]
    > git clone ssh://git@example.com:7999/PROJECT/REPO [DIR]

    sah clone REPO [DIR]
    > git clone ssh://git@example.com:7999/~YOUR_NAME/ERPO [DIR]

    sah clone ~USERNAME/REPO [DIR]
    > git clone ssh://git@example.com:7999/~USERNAME/REPO [DIR]

### (not impremented) create

    sah create
    # create repository
    # repository name is same as the current repository

    sah create --name REPO
    # create repository at ~YOUR_NAME/REPO

    sah create PROJECT
    # create repository at PROJECT
    # repository name is same as the current repository

### (not impremented) fork

    sah fork
    # fork from current repository to ~YOUR_NAME/REPO
    # repository name is same as the origin's one

    sah fork --name MY_FORKED_REPO
    # fork from current repository to ~YOUR_NAME/MY_FORKED_REPO

    sah fork PROJECT/REPO
    # fork from PROJECT/REPO to ~YOUR_NAME/REPO

    sah fork ~USERNAME/REPO
    # fork from ~USERNAME/REPO to ~YOUR_NAME/REPO

### (not impremented) help

    sah help [COMMAND]
    # Describe available commands or one specific command

### (not impremented) project

    sah project
    # list projects

    sah project PROJECT
    # show project detail

### (not impremented) pull-request

    sah pull-request
    # create pull-request to upstream repository's default branch
    # open $EDITOR to edit title and description

### (not impremented) repository

    sah repository PROJECT
    # list repositories

    sah repository PROJECT REPO
    # show repository detail

### (not impremented) upstream

    sah upstream
    # show upstream information

    sah upstream --add-remote [--fetch-pull-request] [--prevent-push] [--remote-name=REMOTE-NAME]
    # add upstream to remote settings

#### (not impremented) configutration

- `git config --global sah.config.upstream-fetch-pull-request true`  
  (the same as `--fetch-pull-request` option)  
  Setting this option to true will fetch all pull requests.
- `git config --global sah.config.upstream-prevent-push true`  
  (the same as `--prevent-push` option)  
  Setting this option to true will Prevent push to upstream repository.
- `git config --global sah.config.upstream-remote-name hoge`  
  (the same as `--remote-name` option)  
  Setting this option to any value will specify git remote name of upstream repository.

### (not impremented) user

    sah user
    # list users

    sah user USER
    # show user detail

### version

    sah version
    # Display the version of this command

### Configutration

- `git config --global sah.config.protocol [ssh|http]`  
  Setting this option to specify git protocol. (default: ssh)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/f440/sah.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

