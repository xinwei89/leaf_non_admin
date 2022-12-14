// Copyright (c) 2020, UW Medicine Research IT, University of Washington
// Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
using System;
using System.Collections.Generic;

namespace Model.Compiler
{
    public class CteCohortQuery : ISqlStatement
    {
        public const string CtePrefix = "WITH wrapper (personId) AS (";
        public const string CteSuffix = ") SELECT personId FROM wrapper";

        public string GrabSql { get; private set; }

        public string Parameters { get; private set; }

        public CteCohortQuery(string parameters, string grab)
        {
            Parameters = parameters;
            GrabSql = grab;
        }

        public string SqlStatement
        {
            get
            {
                return $"{Parameters} {CtePrefix} {GrabSql} {CteSuffix}";
            }
        }
    }

    public class CteCohortCount : CteCohortQuery
    {
        public new const string CteSuffix = ") SELECT COUNT(DISTINCT personId) AS cnt FROM wrapper";

        public CteCohortCount(string parameters, string grab) : base(parameters, grab) { }
    }
}
