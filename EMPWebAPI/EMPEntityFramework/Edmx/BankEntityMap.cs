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
    
    public partial class BankEntityMap
    {
        public System.Guid Id { get; set; }
        public System.Guid BankId { get; set; }
        public Nullable<int> EntityId { get; set; }
    
        public virtual BankMaster BankMaster { get; set; }
        public virtual EntityMaster EntityMaster { get; set; }
    }
}
