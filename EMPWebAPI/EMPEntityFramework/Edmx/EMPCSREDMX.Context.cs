﻿//------------------------------------------------------------------------------
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
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    
    public partial class EMPDB_CSREntities : DbContext
    {
        public EMPDB_CSREntities()
            : base("name=EMPDB_CSREntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<tblCase> tblCases { get; set; }
        public virtual DbSet<tblUser> tblUsers { get; set; }
        public virtual DbSet<Onboarding> Onboardings { get; set; }
    }
}