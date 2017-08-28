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
    
    public partial class SitemapMaster
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public SitemapMaster()
        {
            this.SitemapPermissionMaps = new HashSet<SitemapPermissionMap>();
            this.SiteMapRolePermissions = new HashSet<SiteMapRolePermission>();
            this.TooltipMasters = new HashSet<TooltipMaster>();
        }
    
        public System.Guid Id { get; set; }
        public Nullable<System.Guid> ParentId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string URL { get; set; }
        public Nullable<int> DisplayOrder { get; set; }
        public Nullable<int> SitemapTypeID { get; set; }
        public Nullable<bool> IsVisible { get; set; }
        public Nullable<System.Guid> CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedDate { get; set; }
        public Nullable<System.DateTime> LastUpdatedDate { get; set; }
        public Nullable<System.Guid> LastUpdatedBy { get; set; }
        public string StatusCode { get; set; }
        public Nullable<int> IsDisplayAfterActivation { get; set; }
        public Nullable<int> IsDisplayBeforeActvation { get; set; }
        public Nullable<int> DisplayOrderAfterAct { get; set; }
        public Nullable<int> DisplayOrderBeforeAct { get; set; }
        public Nullable<int> DisplayBeforeVerify { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SitemapPermissionMap> SitemapPermissionMaps { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<SiteMapRolePermission> SiteMapRolePermissions { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<TooltipMaster> TooltipMasters { get; set; }
    }
}
