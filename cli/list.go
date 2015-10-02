package cli

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/codegangsta/cli"
	"github.com/docker/swarm/discovery"
)

func list(c *cli.Context) {
	dflag := getDiscovery(c)
	if dflag == "" {
		log.Fatalf("discovery required to list a cluster. See '%s list --help'.", c.App.Name)
	}
	timeout, err := time.ParseDuration(c.String("timeout"))
	if err != nil {
		log.Fatalf("invalid --timeout: %v", err)
	}

	// Process the store options
	options := map[string]string{}
	for _, option := range c.StringSlice("cluster-store-opt") {
		if !strings.Contains(option, "=") {
			log.Fatal("--cluster-store-opt must container key=value strings")
		}
		kvpair := strings.SplitN(option, "=", 2)
		options[kvpair[0]] = kvpair[1]
	}

	d, err := discovery.New(dflag, timeout, 0, options)
	if err != nil {
		log.Fatal(err)
	}

	ch, errCh := d.Watch(nil)
	select {
	case entries := <-ch:
		for _, entry := range entries {
			fmt.Println(entry)
		}
	case err := <-errCh:
		log.Fatal(err)
	case <-time.After(timeout):
		log.Fatal("Timed out")
	}
}
