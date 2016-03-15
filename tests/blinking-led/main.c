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

#include "sol-mainloop.h"
#include "sol-gpio.h"
#include "sol-log.h"

#include "led.h"

static struct sol_timeout *my_timeout;
static struct sol_gpio *gpio;
static bool write = true;

static bool
my_timeout_func(void *data)
{
    bool ret;

    ret = sol_gpio_write(gpio, write);
    write = !write;
    return ret;
}

static void
startup(void)
{
    SOL_WRN("startup\n");
    my_timeout = sol_timeout_add(2000, my_timeout_func, NULL);
    gpio = open_led();
}

static void
shutdown(void)
{
    SOL_WRN("shutdown\n");
    sol_gpio_close(gpio);
}
SOL_MAIN_DEFAULT(startup, shutdown);
