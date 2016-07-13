using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.PlatformAbstractions;
using Xunit;

namespace GoStatsAggregation.IntegrationTests
{
    public class WebRootTest
    {
        private readonly HttpClient _client;

        public WebRootTest()
        {
            var path = PlatformServices.Default.Application.ApplicationBasePath;
            var contentRoot = Path.GetFullPath(Path.Combine(path, "../../../../../src/GoStatsAggregation" ));            
            var server = new TestServer(new WebHostBuilder().UseStartup<Startup>().UseContentRoot(contentRoot));
            _client = server.CreateClient();
        }

        [Fact]
        public async Task ReturnsIndex()
        {
            var httpResponseMessage = await _client.GetAsync("/");
            httpResponseMessage.EnsureSuccessStatusCode();

            var content = await httpResponseMessage.Content.ReadAsStringAsync();

            content.Should().Contain("FooApi");
        }
    }
}