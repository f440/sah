package main

import (
	"fmt"
	"os"
	"sort"
	"strings"

	"github.com/codegangsta/cli"
	"github.com/f440/sah/api"
	"github.com/f440/sah/config"
	"github.com/f440/sah/profile"
	"github.com/skratchdot/open-golang/open"
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
				profileName := c.GlobalString("profile")
				profile := profile.NewProfile(profileName)

				if len(c.Args()) == 0 {
					fmt.Println("option must be set")
					return
				}
				options := sort.StringSlice(strings.Split(c.Args()[0], "/"))
				var project, repo string
				if len(options) == 1 {
					project = "~" + profile.User
					repo = options[0]
				} else {
					project = options[0]
					repo = options[1]
				}

				ret := api.ShowRepository(profileName, project, repo)
				link := ret.(map[string]interface{})["link"]
				path := link.(map[string]interface{})["url"]
				open.Run(profile.URL + path.(string))
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
