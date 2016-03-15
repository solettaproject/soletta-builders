/*
 * This file is part of the Soletta Project
 *
 * Copyright (C) 2015 Intel Corporation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package main

import (
	"archive/tar"
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strconv"
	"strings"
)

// TODO: Once the behavior is settled, improve the errors messages.

var cleanEnvImportedKeys = []string{
	"PATH",
	"HOME",
}

var cleanEnv []string = []string{
	"LANG=C",
}

func runServer() {
	if len(listPlatforms()) == 0 {
		log.Fatal("Couldn't find any prepared directory. " +
			"Verify if you are running from inside the right directory (usually out/) or " +
			"That you have called prepare scripts.")
	}

	for _, k := range cleanEnvImportedKeys {
		cleanEnv = append(cleanEnv, k+"="+os.Getenv(k))
	}

	fmt.Println("Environment used for builds")
	for _, v := range cleanEnv {
		fmt.Println("    " + v)
	}
	fmt.Println()

	fmt.Println("Listening at", *addr)
	http.HandleFunc("/build/", handleBuild)
	http.HandleFunc("/list", handleList)
	log.Fatal(http.ListenAndServe(*addr, nil))
}

func listPlatforms() []string {
	dir, _ := os.Open(initialDir)
	fis, _ := dir.Readdir(0)

	var platforms []string
	for _, fi := range fis {
		name := fi.Name()
		if fi.IsDir() && strings.HasPrefix(name, "platform-") {
			cinfo, err := os.Stat(name + "/compile")
			if err != nil {
				fmt.Println("Ignoring " + name + " because 'compile' file couldn't be found")
				continue
			}
			if (cinfo.Mode() & 0111) == 0 {
				fmt.Println("Ignoring " + name + " because 'compile' file is not executable")
				continue
			}
			platforms = append(platforms, name)
		}
	}

	dir.Close()
	return platforms
}

func handleList(w http.ResponseWriter, r *http.Request) {
	for _, p := range listPlatforms() {
		fmt.Fprintln(w, p)
	}
}

func platformExists(platform string) bool {
	for _, p := range listPlatforms() {
		if p == platform {
			return true
		}
	}
	return false
}

func clientError(w http.ResponseWriter, format string, a ...interface{}) {
	formatted := fmt.Sprintf(format, a...)
	fmt.Println("Request failed: " + formatted)
	fmt.Fprintln(w, "Request failed: "+formatted)
}

func internalError(w http.ResponseWriter, format string, a ...interface{}) {
	formatted := fmt.Sprintf(format, a...)
	fmt.Println("Internal error: " + formatted)
	fmt.Fprintln(w, "Internal error: "+formatted)
}

func compile(dir string, platform string) (*bytes.Buffer, error) {
	var out bytes.Buffer
	mw := io.MultiWriter(&out, os.Stdout)

	// TODO: Check permission denied error.

	cmd := exec.Command(initialDir + "/" + platform + "/compile")
	cmd.Env = cleanEnv
	cmd.Dir = dir
	cmd.Stdout = mw
	cmd.Stderr = mw

	return &out, cmd.Run()
}

func handleBuild(w http.ResponseWriter, r *http.Request) {
	plat := r.URL.Path[7:]

	if !platformExists(plat) {
		clientError(w, "%s is not available", plat)
		return
	}

	dir, err := ioutil.TempDir("", "sb-")
	if err != nil {
		internalError(w, "couldn't create tempdir: %s", err)
		return
	}

	defer os.RemoveAll(dir)

	tr := tar.NewReader(r.Body)

	header, _ := tr.Next()
	for ; header != nil; header, _ = tr.Next() {
		if !isValidName(header.Name) {
			clientError(w, "invalid filename '"+header.Name+"' provided as input")
			return
		}

		filename, ok := JoinDescendentPath(dir, header.Name)
		if !ok {
			clientError(w, "invalid filename '"+header.Name+"' provided as input")
			return
		}

		switch header.Typeflag {
		case tar.TypeDir:
			os.MkdirAll(filename, 0755)

		case tar.TypeReg:
			f, err := os.Create(filename)
			if err != nil {
				log.Fatal(err)
			}
			io.Copy(f, tr)
			f.Close()

		default:
			clientError(w, "invalid file type for '"+header.Name+"' provided as input")
			return
		}
	}

	out, err := compile(dir, plat)

	if err != nil {
		if out.Bytes() != nil {
			clientError(w, "Compilation error\n")
			io.Copy(w, out)
		} else {
			internalError(w, "couldn't call compile: %s", err)
		}
	} else {
		bin, err := os.Open(dir + "/output.zip")
		if err != nil {
			internalError(w, err.Error())
			return
		}
		w.Header().Set("Content-Type", "application/octet-stream")
		stat, _ := bin.Stat()
		fmt.Println(strconv.FormatInt(stat.Size(), 10))
		io.Copy(os.Stdout, out)
		w.Header().Set("Content-Length", strconv.FormatInt(stat.Size(), 10))
		io.Copy(w, bin)
	}
}
