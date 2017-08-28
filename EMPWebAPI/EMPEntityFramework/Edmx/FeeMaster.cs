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
    
    public partial class FeeMaster
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public FeeMaster()
        {
            this.FeeEntityMaps = new HashSet<FeeEntityMap>();
        }
    
        public System.Guid Id { get; set; }
        public string Name { get; set; }
        public string FeeType { get; set; }
        public Nullable<short> FeeTypeId { get; set; }
        public Nullable<decimal> Amount { get; set; }
        public string FeeNature { get; set; }
        public Nullable<short> FeeNatureId { get; set; }
        public Nullable<System.DateTime> ActivatedDate { get; set; }
        public Nullable<System.DateTime> DeActivatedDate { get; set; }
        public string NoteForUser { get; set; }
        public string Note { get; set; }
        public int FeeCategoryID { get; set; }
        public bool IsIncludedMaxAmtCalculation { get; set; }
        public string SalesforceFeesFieldID { get; set; }
        public Nullable<int> FeesFor { get; set; }
        public Nullable<System.Guid> CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedDate { get; set; }
        public Nullable<System.DateTime> LastUpdatedDate { get; set; }
        public Nullable<System.Guid> LastUpdatedBy { get; set; }
        public string StatusCode { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<FeeEntityMap> FeeEntityMaps { get; set; }
    }
}