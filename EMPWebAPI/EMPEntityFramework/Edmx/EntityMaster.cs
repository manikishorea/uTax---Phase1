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
    
    public partial class EntityMaster
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public EntityMaster()
        {
            this.AffiliationProgramEntityMaps = new HashSet<AffiliationProgramEntityMap>();
            this.BankEntityMaps = new HashSet<BankEntityMap>();
            this.emp_CustomerInformation = new HashSet<emp_CustomerInformation>();
            this.FeeEntityMaps = new HashSet<FeeEntityMap>();
            this.SalesYearEntityMaps = new HashSet<SalesYearEntityMap>();
            this.UserMasters = new HashSet<UserMaster>();
        }
    
        public int Id { get; set; }
        public Nullable<int> ParentId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public Nullable<System.Guid> AccessTypeId { get; set; }
        public Nullable<int> DisplayOrder { get; set; }
        public Nullable<int> FeeSourceEntityId { get; set; }
        public Nullable<int> BaseEntityId { get; set; }
        public Nullable<System.Guid> CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedDate { get; set; }
        public Nullable<System.DateTime> LastUpdatedDate { get; set; }
        public Nullable<System.Guid> LastUpdatedBy { get; set; }
        public string StatusCode { get; set; }
        public bool IsAdditionalEFINAllowed { get; set; }
    
        public virtual AccessTypeMaster AccessTypeMaster { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<AffiliationProgramEntityMap> AffiliationProgramEntityMaps { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<BankEntityMap> BankEntityMaps { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<emp_CustomerInformation> emp_CustomerInformation { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<FeeEntityMap> FeeEntityMaps { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SalesYearEntityMap> SalesYearEntityMaps { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<UserMaster> UserMasters { get; set; }
    }
}
