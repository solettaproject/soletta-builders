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

#include <stdio.h>

#include "sol-log.h"
#include "sol-mainloop.h"

static bool
print_func(void *data)
{
    SOL_WRN("test");
    return true;
}

static bool
quit_func(void *data)
{
    sol_quit();
    return false;
}

static void
startup(void)
{
    SOL_WRN("hello soletta");
    sol_timeout_add(100, print_func, NULL);
    sol_timeout_add(1500, quit_func, NULL);
}

static void
shutdown(void)
{
    SOL_WRN("bye soletta");
}

SOL_MAIN_DEFAULT(startup, shutdown);
