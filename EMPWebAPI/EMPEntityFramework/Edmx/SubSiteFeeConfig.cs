//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace EMPEntityFramework.Edmx
{
    using System;
    using System.Collections.Generic;
    
    public partial class SubSiteFeeConfig
    {
        public System.Guid ID { get; set; }
        public System.Guid emp_CustomerInformation_ID { get; set; }
        public bool IsAddOnFeeCharge { get; set; }
        public bool IsSameforAll { get; set; }
        public bool IsSubSiteAddonFee { get; set; }
        public int ServiceorTransmission { get; set; }
        public System.Guid CreatedBy { get; set; }
        public System.DateTime CreatedDate { get; set; }
        public System.DateTime LastUpdatedDate { get; set; }
        public System.Guid LastUpdatedBy { get; set; }
        public string StatusCode { get; set; }
    }
}