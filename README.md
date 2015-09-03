# Sah

Sah is command line util for [Atlassian Stash](https://www.atlassian.com/software/stash).

This project was heavily inspired by the [hub](https://hub.github.com/).

## (not impremented) Installation

    gem install sah

## Configuration

    git config [--global] sah.default.user "f440"
    git config [--global] sah.default.password "freq440@gmail.com"
    git config [--global] sah.default.ssh-url "ssh://git@exmaple.com:7999"
    git config [--global] sah.default.base-url "https://exmaple.com"

If you use multiple stash, define profile(s) and specify it.

    git config [--global] sah.my_company.user "jane"
    git config [--global] sah.my_company.password "jane@example.jp"
    git config [--global] sah.my_company.ssh-url "ssh://git@exmaple.jp:7999"
    git config [--global] sah.my_company.base-url "https://git@exmaple.jp"

    sah SUB_COMMAND --profile my_company
    or
    export SAH_DEFAULT_PROFILE=my_company
    sah SUB_COMMAND

## Usage

### help

    sah help SUBCOMMAND

### clone

    sah clone project/repos
    > git clone ssh://git@example.com:7999/project/repos

    sah clone repos
    > git clone ssh://git@example.com:7999/~my/repos

    sah clone ~user/repos
    > git clone ssh://git@example.com:7999/~user/repos

### fork

    sah fork
    # fork from current repository to my/repo

    sah fork project/repo
    # fork from project/repo to my/repo

    sah fork ~user/repo
    # fork from ~user/repo to my/repo

### remote

    sah remote add remote-name project/repos
    > git remote add remote-name $STASH_URL/project/repos

    sah remote add remote-name ~user/repos
    > git remote add remote-name $STASH_URL/~user/repos

    sah remote add remote-name repos
    > git remote add remote-name $STASH_URL/~my/repos

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec sah` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/f440/sah.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

