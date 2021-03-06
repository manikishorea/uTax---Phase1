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
    
    public partial class OfficeManagementGridRecord_Result1
    {
        public long Id { get; set; }
        public Nullable<System.Guid> CustomerId { get; set; }
        public Nullable<System.Guid> ParentId { get; set; }
        public Nullable<int> EntityId { get; set; }
        public Nullable<int> BaseEntityId { get; set; }
        public string CompanyName { get; set; }
        public string BusinessOwnerFirstName { get; set; }
        public string BusinessOwnerLastName { get; set; }
        public string OfficePhone { get; set; }
        public string EMPUserId { get; set; }
        public string EMPPassword { get; set; }
        public Nullable<int> EFIN { get; set; }
        public string MasterIdentifier { get; set; }
        public Nullable<int> IsActivationCompleted { get; set; }
        public Nullable<bool> IsVerified { get; set; }
        public string AccountStatus { get; set; }
        public string StatusCode { get; set; }
        public Nullable<decimal> SVBFee { get; set; }
        public Nullable<decimal> uTaxSVBFee { get; set; }
        public Nullable<decimal> SVBAddonFee { get; set; }
        public Nullable<decimal> SVBEnrollAddonFee { get; set; }
        public Nullable<decimal> TransmissionFee { get; set; }
        public Nullable<decimal> CrosslinkTransFee { get; set; }
        public Nullable<decimal> TransAddonFee { get; set; }
        public Nullable<decimal> TransEnrollAddonFee { get; set; }
        public Nullable<System.Guid> SalesYearId { get; set; }
        public Nullable<bool> SVBCanAddon { get; set; }
        public Nullable<bool> SVBCanEnroll { get; set; }
        public Nullable<bool> TRANCanAddon { get; set; }
        public Nullable<bool> TRANCanEnroll { get; set; }
        public Nullable<bool> CanEnrollmentAllowed { get; set; }
        public Nullable<bool> IsEnrollmentCompleted { get; set; }
        public Nullable<System.Guid> ActiveBankId { get; set; }
        public string ActiveBankName { get; set; }
        public Nullable<System.DateTime> EnrollmentSubmittionDate { get; set; }
        public Nullable<System.Guid> EnrollmentPrimaryKey { get; set; }
        public string EnrollmentStatus { get; set; }
        public string ApprovedBank { get; set; }
        public string SubmittedBanks { get; set; }
        public string RejectedBanks { get; set; }
        public string UnlockedBanks { get; set; }
        public Nullable<System.Guid> OnBoardPrimaryKey { get; set; }
        public string OnboardingStatus { get; set; }
        public Nullable<bool> IsAdditionalEFINAllowed { get; set; }
        public Nullable<bool> IsTaxReturn { get; set; }
        public Nullable<int> EFINStatus { get; set; }
        public Nullable<System.DateTime> CreatedDate { get; set; }
        public Nullable<System.DateTime> UpdatedDate { get; set; }
        public Nullable<bool> CanEnrollmentAllowedForMain { get; set; }
    }
}
