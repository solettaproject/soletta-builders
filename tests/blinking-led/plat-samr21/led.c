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

#include "stdint.h"
#include "sol-gpio.h"

#include "led.h"

/* Using platform-specific headers is fine for platform-specific code. */
#include <periph_cpu.h>

struct sol_gpio *
open_led(void)
{
    struct sol_gpio_config cfg = {
        .api_version = SOL_GPIO_CONFIG_API_VERSION,
        .dir = SOL_GPIO_DIR_OUT,
    };

    return sol_gpio_open(GPIO(PA, 19), &cfg);
}
