using FluentAssertions;
using GoStatsAggregation.IntegrationTests.Pages;
using Xunit;

namespace GoStatsAggregation.IntegrationTests
{
    public class HomeFixture
    {
        [Fact]
        public async void ReturnsIndex()
        {
            await HomePage.Visit();

            HomePage.EnsureSuccessStatusCode();
            HomePage.PageTitle.Should().Be("Home - GoStatsAggregation");            
            HomePage.Content.Should().Contain("FooApi");
        }
    }
}