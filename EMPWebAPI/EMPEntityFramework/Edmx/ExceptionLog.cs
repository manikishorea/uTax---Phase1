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
    
    public partial class ExceptionLog
    {
        public long Id { get; set; }
        public string ExceptionMessage { get; set; }
        public Nullable<System.Guid> UserId { get; set; }
        public string MethodName { get; set; }
        public System.DateTime CreatedDateTime { get; set; }
    }
}
