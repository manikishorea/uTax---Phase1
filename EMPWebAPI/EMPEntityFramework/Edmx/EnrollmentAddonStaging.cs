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
    
    public partial class EnrollmentAddonStaging
    {
        public System.Guid Id { get; set; }
        public bool IsSvbFee { get; set; }
        public decimal SvbAddonAmount { get; set; }
        public bool IsTransmissionFee { get; set; }
        public decimal TransmissionAddonAmount { get; set; }
        public System.Guid BankSelectionId { get; set; }
        public System.Guid BankId { get; set; }
        public System.Guid CustomerId { get; set; }
        public bool IsActive { get; set; }
        public Nullable<System.Guid> CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedDate { get; set; }
        public Nullable<System.Guid> UpdatedBy { get; set; }
        public Nullable<System.DateTime> UpdatedDate { get; set; }
    }
}