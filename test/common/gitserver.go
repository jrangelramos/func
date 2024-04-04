package common

import (
	"testing"
)

var DefaultGitServer GitProvider

func GetGitServer(T *testing.T) GitProvider {
	gitTestServer := GitTestServerKnativeProvider{}
	if DefaultGitServer != nil {
		T.Log("Using DefaultGitServer")
		DefaultGitServer.Init(T)
		return DefaultGitServer
	}
	gitTestServer.Init(T)
	return &gitTestServer
}
