package main

import (
	"os"

	"./config"
	"./profile"

	"github.com/codegangsta/cli"
)

func main() {
	app := cli.NewApp()
	app.Name = "sah"
	app.Usage = "Command line util for Atlassian Bitbucket Server"

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:   "profile",
			Usage:  "Set a specific profile (default: default)",
			EnvVar: "SAH_DEFAULT_PROFILE",
		},
	}

	app.Commands = []cli.Command{
		{
			Name:  "dev",
			Usage: "sandbox",
			Action: func(c *cli.Context) {
				config := config.NewConfig()
				profileName := c.GlobalString("profile")
				profile := profile.NewProfile(profileName)
				print(config.UpstreamPreventPush)
				print(profile.Name)
			},
		},
		{
			Name:  "browse",
			Usage: "browse repository",
			Action: func(c *cli.Context) {
				// TODO
			},
		},
		{
			Name:  "clone",
			Usage: "clone repository",
			Action: func(c *cli.Context) {
				// TODO
			},
		},
		{
			Name:  "create",
			Usage: "create repository",
			Action: func(c *cli.Context) {
				// TODO
			},
		},
		{
			Name:  "fork",
			Usage: "fork repository",
			Action: func(c *cli.Context) {
				// TODO
			},
		},
		{
			Name:  "project",
			Usage: "Show project information",
			Action: func(c *cli.Context) {
				// TODO
			},
		},
		{
			Name:  "repository",
			Usage: "Show repository information",
			Action: func(c *cli.Context) {
				// TODO
			},
		},
		{
			Name:  "upstream",
			Usage: "Show upstream information",
			Action: func(c *cli.Context) {
				// TODO
			},
		},
		{
			Name:  "user",
			Usage: "Show user information",
			Action: func(c *cli.Context) {
				// TODO
			},
		},
		{
			Name:  "version",
			Usage: "Show version",
			Action: func(c *cli.Context) {
				print(app.Version, "\n")
			},
		},
	}

	app.Run(os.Args)
}
