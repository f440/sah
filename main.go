package main

import (
	"os"

	"github.com/codegangsta/cli"
)

func main() {
	app := cli.NewApp()
	app.Name = "sah"
	app.Usage = "Command line util for Atlassian Bitbucket Server"

	app.Commands = []cli.Command{
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
