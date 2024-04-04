package common

import (
	"context"

	"strings"
	"testing"

	"knative.dev/func/pkg/k8s"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
)

type GitRemoteRepo struct {
	RepoName         string
	ExternalCloneURL string
	ClusterCloneURL  string
}

type GitProvider interface {
	Init(T *testing.T)
	CreateRepository(repoName string) *GitRemoteRepo
	DeleteRepository(repoName string)
}

// ------------------------------------------------------
// Git Server on Kubernetes as Knative Service (func-git)
// ------------------------------------------------------

type GitTestServerKnativeProvider struct {
	PodName            string
	ServiceUrl         string
	Kubectl            *TestExecCmd
	t                  *testing.T
	KnativeServiceName string
}

func (g *GitTestServerKnativeProvider) Init(T *testing.T) {

	g.t = T
	if g.KnativeServiceName == "" {
		g.KnativeServiceName = "func-git"
	}
	if g.PodName == "" {
		config, err := k8s.GetClientConfig().ClientConfig()
		if err != nil {
			T.Fatal(err.Error())
		}
		clientSet, err := kubernetes.NewForConfig(config)
		if err != nil {
			T.Fatal(err.Error())
		}
		ctx := context.Background()

		namespace, _, _ := k8s.GetClientConfig().Namespace()
		podList, err := clientSet.CoreV1().Pods(namespace).List(ctx, metav1.ListOptions{
			LabelSelector: "serving.knative.dev/service=" + g.KnativeServiceName,
		})
		if err != nil {
			T.Fatal(err.Error())
		}
		for _, pod := range podList.Items {
			g.PodName = pod.Name
		}
	}

	if g.ServiceUrl == "" {
		// Get Route Name
		_, g.ServiceUrl = GetKnativeServiceRevisionAndUrl(T, g.KnativeServiceName)
	}

	if g.Kubectl == nil {
		g.Kubectl = &TestExecCmd{
			Binary:              "kubectl",
			ShouldDumpCmdLine:   true,
			ShouldDumpOnSuccess: true,
			T:                   T,
		}
	}
	T.Logf("Initialized HTTP Func Git Server: Server URL = %v Pod Name = %v\n", g.ServiceUrl, g.PodName)
}

func (g *GitTestServerKnativeProvider) CreateRepository(repoName string) *GitRemoteRepo {
	// kubectl exec $podname -c user-container -- git-repo create $reponame
	cmdResult := g.Kubectl.Exec("exec", g.PodName, "-c", "user-container", "--", "git-repo", "create", repoName)
	if !strings.Contains(cmdResult.Out, "created") {
		g.t.Fatal("unable to create git bare repository " + repoName)
	}
	namespace, _, _ := k8s.GetClientConfig().Namespace()
	gitRepo := &GitRemoteRepo{
		RepoName:         repoName,
		ExternalCloneURL: g.ServiceUrl + "/" + repoName + ".git",
		ClusterCloneURL:  "http://" + g.KnativeServiceName + "." + namespace + ".svc.cluster.local/" + repoName + ".git",
	}
	gitRepo.ClusterCloneURL = gitRepo.ExternalCloneURL
	return gitRepo
}

func (g *GitTestServerKnativeProvider) DeleteRepository(repoName string) {
	cmdResult := g.Kubectl.Exec("exec", g.PodName, "-c", "user-container", "--", "git-repo", "delete", repoName)
	if !strings.Contains(cmdResult.Out, "deleted") {
		g.t.Fatal("unable to delete git bare repository " + repoName)
	}
}
