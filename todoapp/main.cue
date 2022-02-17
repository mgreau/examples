package todoapp

import (
	"dagger.io/dagger"

	"universe.dagger.io/yarn"
)

dagger.#Plan & {
	inputs: directories: app: path: "./"
	actions: {
		build: yarn.#Build & {
			source: inputs.directories.app.contents
		}
		// TODO: This is expected to fail, but it currently doesn't run.
		test: #AssertFile & {
			input:    build.output
			path:     "test"
			contents: "output\n"
		}
		// Each environment will have a specific deploy implementation
		deploy: _
	}
}

// Make an assertion on the contents of a file
#AssertFile: {
	input:    dagger.#FS
	path:     string
	contents: string

	_read: dagger.#ReadFile & {
		"input": input
		"path":  path
	}

	actual: _read.contents

	// Assertion
	contents: actual
}
