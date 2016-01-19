package api

import (
	"encoding/json"
	"io/ioutil"
	"net/http"

	"github.com/f440/sah/profile"
)

// def show_branches(project, repository)
// def fork_repository(project, repo, name=nil)
// def create_repository(project, repo)
// def list_project
// def show_project(project)
// def list_user
// def show_user(user)
// def list_repository(project)

// def show_repository(project, repository)
func ShowRepository(profile_name, project, repo string) interface{} {
	profile := profile.NewProfile(profile_name)
	url := profile.URL + "/rest/api/1.0/projects/" + project + "/repos/" + repo
	client := &http.Client{}
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		panic(err)
	}
	req.SetBasicAuth(profile.User, profile.Password)
	res, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK {
		panic(res)
	}
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		panic(err)
	}

	var f interface{}
	json.Unmarshal(body, &f)
	return f
}

// def create_pull_request(source, target, title="", description="", reviewers=[])
