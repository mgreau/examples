package todoapp

import (
	"dagger.io/dagger"

	"universe.dagger.io/yarn"
	"universe.dagger.io/docker"
)

dagger.#Plan & {
	inputs: {
		directories: app: path: "./"
		params: {
			web: hostPort: string | *"8080"
			run: bool | *false
			// TODO: This should not be necessary, but the current state of Europa prevents us from doing this nicely.
			// This is "make it work" plan B:
			// dagger up --with "inputs: params: run: true"
		}
	}
	actions: {
		build: yarn.#Build & {
			source: inputs.directories.app.contents
		}
		// TODO: There are no tests here, we should add some - or create a new app.
		// The goal would be to have a simple, self-contained and Dagger-specific Go app which is quick to build, test & deploy.
		// Andrea has a few great ideas, I am keen on exploring them as soon as we are able to.
		test: yarn.#Run & {
			script: "test"
			source: inputs.directories.app.contents
		}
		// TODO: How can we run this in the Docker Engine as a container?
		// The intent of this is to actually deploy to Docker, and not run it in Dagger / Buildkit.
		// By the way, this is only dev-specific.
		// In a different env, we will push this to an API which has a runtime behind it, e.g. K8s, Vercel, etc.
		if inputs.params.run {
			// TODO: Should this package be called buildkit instead of docker?
			// All these commands run in the Buildkit container which runs in Docker, not Docker.
			// If we think that Buildkit is too "niche", how about we call this Dagger instead?
			// This is more complicated since https://github.com/dagger/dagger/pull/1579
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
		}
	}
	// TODO: If this gets deployed to Docker, we want to run smoke tests that check that it's actually running
	// vim-cue plugin messes up formatting, because this is an action which should run after deploy succeeds.
}
