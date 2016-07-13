using System.IO;
using System.Net;
using System.Net.Http;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.PlatformAbstractions;

namespace GoStatsAggregation.IntegrationTests.Pages
{
    public static class HomePage
    {
        private static readonly HttpClient Client;
        private static HttpResponseMessage httpResponseMessage;
        private static HttpStatusCode StatusCode;

        public static string Content { get; private set; }

        public static string PageTitle
        {
            get
            {
                var pageTitleRegex = new Regex("<title>(?<title>[^<]+)</title>");
                var match = pageTitleRegex.Match(Content);
                match.Success.Should().BeTrue("Could not find the title in the response :-(");
                var pageTitle = match.Groups["title"].Value;
                return pageTitle;
            }
        }

        static HomePage()
        {         
            var path = PlatformServices.Default.Application.ApplicationBasePath;
            var contentRoot = Path.GetFullPath(Path.Combine(path, "../../../../../src/GoStatsAggregation"));
            var server = new TestServer(new WebHostBuilder().UseStartup<Startup>().UseContentRoot(contentRoot));
            Client = server.CreateClient();        
        }



        public static async Task Visit()
        {
            httpResponseMessage = await Client.GetAsync("/");
            //httpResponseMessage.EnsureSuccessStatusCode();
            StatusCode = httpResponseMessage.StatusCode;
            Content = await httpResponseMessage.Content.ReadAsStringAsync();

       
        }



        public static void EnsureSuccessStatusCode()
        {
            StatusCode.Should().Be(HttpStatusCode.OK);
        }
    }
}