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
	"path/filepath"
	"regexp"
	"strings"
)

var validNameMatcher = regexp.MustCompile("^[0-9A-Za-z-_][0-9A-Za-z-_\\.\\/]*$")

func isValidName(s string) bool {
	return validNameMatcher.MatchString(s)
}

var sanitizeReplacer = regexp.MustCompile("[^0-9A-Za-z-_]")

func sanitizePlatformName(s string) string {
	return sanitizeReplacer.ReplaceAllLiteralString(s, "-")
}

// Joins basepath and path only if the result will be a descendent of
// basepath.
func JoinDescendentPath(basepath string, path string) (string, bool) {
	base := filepath.Clean(basepath)
	joined := filepath.Join(base, path)
	if joined != base && strings.HasPrefix(joined+"/", base+"/") {
		return joined, true
	}
	return "", false
}
