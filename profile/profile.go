package profile

import (
	"log"

	"github.com/tcnksm/go-gitconfig"
)

type Profile struct {
	Name     string
	User     string
	Password string
	URL      string
}

func NewProfile(name string) *Profile {
	if name == "" {
		name = "default"
	}
	profile := Profile{Name: name}

	user, err := gitconfig.Entire("sah.profile." + name + ".user")
	if err != nil {
		log.Fatal(err)
	}
	profile.User = user

	password, err := gitconfig.Entire("sah.profile." + name + ".password")
	if err != nil {
		log.Fatal(err)
	}
	profile.Password = password

	url, err := gitconfig.Entire("sah.profile." + name + ".url")
	if err != nil {
		log.Fatal(err)
	}
	profile.URL = url

	return &profile
}
