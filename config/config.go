package config

import "github.com/tcnksm/go-gitconfig"

type Config struct {
	UpstreamPreventPush      bool
	UpstreamFetchPullRequest bool
}

func NewConfig() *Config {
	config := Config{}

	config.UpstreamPreventPush = false
	upstreamPreventPush, _ := gitconfig.Entire("sah.config.upstream-prevent-push")
	if upstreamPreventPush == "true" {
		config.UpstreamPreventPush = true
	}

	config.UpstreamFetchPullRequest = false
	upstreamFetchPullRequest, _ := gitconfig.Entire("sah.config.upstream-fetch-pull-request")
	if upstreamFetchPullRequest == "true" {
		config.UpstreamFetchPullRequest = true
	}

	return &config
}
