# Sah

Sah is command line util for [Atlassian Stash](https://www.atlassian.com/software/stash).

This project was heavily inspired by the [hub](https://hub.github.com/).

## Installation

    gem install sah

## Configuration

    git config [--global] sah.profile.default.user "f440"
    git config [--global] sah.profile.default.password "freq440@gmail.com"
    git config [--global] sah.profile.default.url "https://exmaple.com"

If you use multiple stash, define profile(s) and specify it.

    git config [--global] sah.profile.my_company.user "jane"
    git config [--global] sah.profile.my_company.password "jane@example.jp"
    git config [--global] sah.profile.my_company.url "https://git@exmaple.jp"

    sah SUB_COMMAND --profile my_company
    or
    export SAH_DEFAULT_PROFILE=my_company
    sah SUB_COMMAND

## Usage

### clone

    sah clone PROJECT/REPO
    > git clone ssh://git@example.com:7999/PROJECT/REPO

    sah clone REPO
    > git clone ssh://git@example.com:7999/~YOUR_NAME/ERPO

    sah clone ~USERNAME/REPO
    > git clone ssh://git@example.com:7999/~USERNAME/REPO

### create

    sah create
    # create repository
    # repository name is same as the current repository

    sah create --name REPO
    # create repository at ~YOUR_NAME/REPO

    sah create PROJECT
    # create repository at PROJECT
    # repository name is same as the current repository

### fork

    sah fork
    # fork from current repository to ~YOUR_NAME/REPO
    # repository name is same as the origin's one

    sah fork --name MY_FORKED_REPO
    # fork from current repository to ~YOUR_NAME/MY_FORKED_REPO

    sah fork PROJECT/REPO
    # fork from PROJECT/REPO to ~YOUR_NAME/REPO

    sah fork ~USERNAME/REPO
    # fork from ~USERNAME/REPO to ~YOUR_NAME/REPO

## help

    sah help [COMMAND]
    # Describe available commands or one specific command

### project

    sah project
    # list projects

    sah project PROJECT
    # show project detail

### repository

    sah repository PROJECT
    # list repositories

    sah repository PROJECT REPO
    # show repository detail

### upstream

    upstream
    # show upstream information

    upstream --add-remote [--fetch-pull-request] [--prevent-push]
    # add upstream to remote settings

#### configutration

- `git config --global sah.config.upstream-fetch-pull-request true`  
  (the same as `--fetch-pull-request` option)  
  Setting this option to true will fetch all pull requests.
- `git config --global sah.config.upstream-prevent-push true`  
  (the same as `--prevent-push` option)  
  Setting this option to true will Prevent push to upstream repository.
- `git config --global sah.config.sah.git-protocol [ssh|http]`  
  Setting this option to specify git protocol. (default: ssh)

### user

    sah user
    # list users

    sah user USER
    # show user detail

### version

    sah version
    # Display the version of this command

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec sah` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/f440/sah.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

