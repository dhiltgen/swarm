#!/usr/bin/env bats

load ../helpers

function teardown() {
	swarm_manage_cleanup
	stop_docker
}

@test "docker rmi" {
	# Start one empty host and two with busybox to ensure swarm selects the
	# right ones and rmi doesn't fail if one host doesn't have the image.
	start_docker 1
	start_docker_with_busybox 2
	swarm_manage

	# make sure image exists
	run docker_swarm images
	[ "$status" -eq 0 ]
	[[ "${output}" == *"busybox"* ]]

	# verify the nodes: the first one shouldn't have the image while the other
	# two yes.
	run docker -H ${HOSTS[0]} images
	[ "$status" -eq 0 ]
	[[ "${output}" != *"busybox"* ]]
	run docker -H ${HOSTS[1]} images
	[ "$status" -eq 0 ]
	[[ "${output}" == *"busybox"* ]]
	run docker -H ${HOSTS[1]} images
	[ "$status" -eq 0 ]
	[[ "${output}" == *"busybox"* ]]


	# wipe busybox.
	docker_swarm rmi busybox

	# swarm verify
	run docker_swarm images -q
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 0 ]

	# verify the image was actually removed from every node.
	for host in ${HOSTS[@]}; do
		run docker -H $host images -q
		[ "$status" -eq 0 ]
		[ "${#lines[@]}" -eq 0 ]
	done
}

@test "docker rmi prefix" {
	start_docker_with_busybox 1
	swarm_manage

	run docker_swarm rmi bus
	[ "$status" -ne 0 ]
	[[ "${output}" == *"No such image"* ]]
}

@test "docker rmi without tag" {
	start_docker_with_busybox 1
	start_docker 1 
	
	docker -H ${HOSTS[0]} tag busybox:latest testimage:latest
	swarm_manage

	run docker_swarm images
	[ "$status" -eq 0 ]
	[[ "${output}" == *"busybox"* ]]
	[[ "${output}" == *"testimage"* ]]

	run docker_swarm rmi testimage
	[ "$status" -eq 0 ]
	[[ "${output}" == *"Untagged"* ]]

	run docker_swarm images
	[ "$status" -eq 0 ]
	[[ "${output}" == *"busybox"* ]]
	[[ "${output}" != *"testimage"* ]]
}

@test "docker rmi --force" {
	start_docker_with_busybox 1
	start_docker 1

	swarm_manage

	# make sure same image id have two repo-tags
	docker_swarm tag busybox:latest testimage:latest

	run docker_swarm images
	[[ "${output}" == *"busybox"* ]]
	[[ "${output}" == *"testimage"* ]]

	# get busybox image id
	busybox_id=`docker_swarm inspect --format='{{.Id}}' busybox:latest`

	# test rmi with force
	docker_swarm rmi -f ${busybox_id}

	run docker_swarm images
	[[ "${output}" != *"busybox"* ]]
	[[ "${output}" != *"testimage"* ]]
}
