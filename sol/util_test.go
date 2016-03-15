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

import "testing"

func TestJoinDescendentPath(t *testing.T) {
	var tests = []struct {
		base     string
		path     string
		expected string
		ok       bool
	}{
		{"/tmp", "main.c", "/tmp/main.c", true},

		{"/tmp", ".", "", false},
		{"/tmp", "..", "", false},
		{"/tmp", "../tmp", "", false},
		{"/tmp", "../tmp2", "", false},
		{"/tmp", "a/../../tmp2", "", false},
	}

	for _, test := range tests {
		actual, ok := JoinDescendentPath(test.base, test.path)
		if actual != test.expected || ok != test.ok {
			t.Errorf("JoinDescendentPath(%q, %q) = %q (%v); want %q (%v)",
				test.base, test.path, actual, ok, test.expected, test.ok)
		}
	}
}
