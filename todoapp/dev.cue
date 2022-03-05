package todoapp

import (
	"dagger.io/dagger"
	"universe.dagger.io/yarn"
	"universe.dagger.io/docker"
)

dagger.#Plan & {
	inputs: {
		directories: app: path: "./"
		params: web: hostPort:  string | *"8080"
	}
	actions: {
		build: yarn.#Build & {
			source: inputs.directories.app.contents
		}
		// TODO: There are no tests here, we should add some.
		test: yarn.#Run & {
			script: "test"
			source: inputs.directories.app.contents
		}
		// TODO: How can we run this in the Docker Engine as a container?
		// The intent of this is to actually deploy to Docker, and not run it in Dagger / Buildkit.
		deploy: docker.#Build & {
			steps: [
				docker.#Pull & {
					source: "m3ng9i/ran"
				},
				docker.#Copy & {
					contents: build.output
					dest:     "/web"
				},
				docker.#Run & {
					command: {
						name: "/ran"
						args: ["-p", inputs.params.web.hostPort]
					}
				},
			]
		}
		// TODO: Run smoke tests that check everything is running OK
	}
}
