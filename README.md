# Sah

Sah is command line util for [Atlassian Stash](https://www.atlassian.com/software/stash).

This project was heavily inspired by the [hub](https://hub.github.com/).

## (not impremented) Installation

    gem install sah

## Configuration

    git config sah.default.user "f440"
    git config sah.default.password "freq440@gmail.com"
    git config sah.default.url "ssh://git@exmaple.com:7999"

If you use multiple stash, define profile(s) and specify it.

    git config sah.my_company.user "fuse"
    git config sah.my_company.password "fuse@example.jp"
    git config sah.my_company.url "https://example.jp"

    sah SUB_COMMAND --profile my_company
    or
    export SAH_DEFAULT_PROFILE=my_company
    sah SUB_COMMAND

    $ gem install sah

## Usage

### help

    sah help SUBCOMMAND

### clone

    sah clone project/repos
    > git clone ssh://git@example.com:7999/project/repos

    sah clone repos
    > git clone ssh://git@example.com:7999/~me/repos

    sah clone ~user/repos
    > git clone ssh://git@example.com:7999/~user/repos

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec sah` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/f440/sah.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

