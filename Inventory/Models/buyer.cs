﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace Inventory.Models;

public partial class buyer
{
    public Guid PK_buyer { get; set; }

    public string name { get; set; }

    public string buy_code { get; set; }

    public string street { get; set; }

    public string city { get; set; }

    public string state { get; set; }

    public string zip { get; set; }

    public string zip4 { get; set; }

    public string internat { get; set; }

    public string street2 { get; set; }

    public string country { get; set; }

    public string int_zip { get; set; }

    public string note { get; set; }

    public string area_code { get; set; }

    public string phone { get; set; }

    public string fax { get; set; }

    public string bbuycode { get; set; }

    public decimal? cus_bal { get; set; }

    public decimal? ships_180 { get; set; }

    public decimal? ships_60 { get; set; }

    public decimal? ships_ex { get; set; }

    public decimal? days_180 { get; set; }

    public decimal? days_60 { get; set; }

    public decimal? days_ex { get; set; }

    public string used { get; set; }
}