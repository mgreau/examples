package todoapp

import (
	"universe.dagger.io/docker"
	"universe.dagger.io/nginx"
)

inputs: params: web: hostPort: string | *"8080"
actions: {
	deploy: docker.#Build & {
		steps: [
			nginx.#Build & {
				flavor: "alpine"
			},
			docker.#Copy & {
				contents: test.output
				dest:     "/usr/share/nginx/html"
			},
			// TODO: Confirm that the input is the output of the previous step
			docker.#Run & {
				// TODO: How do we connect to the nginx instance?
				ports: web: {
					frontend: inputs.params.web.hostPort
					// TODO: What is this backend config?
					backend: address: "localhost:5000"
				}
			},
		]
	}
	// TODO: smoke test
}
