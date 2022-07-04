/*
 * BSD 3-Clause License
 *
 * Copyright © 2022, Jacob B. Sanders, IaC-Factory & Affiliates
 *
 * All Rights Reserved
 */

import "@jest/globals";

process.env = Object.assign( process.env, {
    MOCK: "true"
} );
