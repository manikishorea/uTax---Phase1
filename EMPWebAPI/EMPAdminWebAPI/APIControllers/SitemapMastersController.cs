﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.Description;

using EMPAdmin.Transactions.SiteMapMaster.DTO;
using EMPAdminWebAPI.Filters;
using EMPAdmin.Transactions.SiteMapMaster;

using EMP.Core.DTO;
using System.Web.Http.Cors;

namespace EMPAdminWebAPI.APIControllers
{
    // 
    // [EnableCors("*", "*", "*")]
    // [MyCorsPolicyAttribute]
    [TokenAuthorization]
    public class SitemapMastersController : ApiController
    {
        SiteMapMasterService _SiteMapMasterService = new SiteMapMasterService();

        // GET: api/SitemapMasters/5
        [ResponseType(typeof(SiteMapMasterDTO))]
        public async Task<IHttpActionResult> GetSitemapMaster(Guid id)
        {
            var sitemap = await _SiteMapMasterService.GetSitemapMaster(id);
            if (sitemap == null)
            {
                return NotFound();
            }

            return Ok(sitemap);
        }
    }
}