package cli

import "github.com/codegangsta/cli"

var (
	commands = []cli.Command{
		{
			Name:      "create",
			ShortName: "c",
			Usage:     "Create a cluster",
			Action:    create,
		},
		{
			Name:      "list",
			ShortName: "l",
			Usage:     "List nodes in a cluster",
			Flags:     []cli.Flag{flTimeout, flClusterStoreOpt},
			Action:    list,
		},
		{
			Name:      "manage",
			ShortName: "m",
			Usage:     "Manage a docker cluster",
			Flags: []cli.Flag{
				flStrategy, flFilter,
				flHosts,
				flLeaderElection, flLeaderTTL, flManageAdvertise,
				flTLS, flTLSCaCert, flTLSCert, flTLSKey, flTLSVerify,
				flHeartBeat,
				flEnableCors,
				flCluster, flClusterStoreOpt, flClusterOpt},
			Action: manage,
		},
		{
			Name:      "join",
			ShortName: "j",
			Usage:     "join a docker cluster",
			Flags:     []cli.Flag{flJoinAdvertise, flHeartBeat, flTTL, flClusterStoreOpt},
			Action:    join,
		},
	}
)
