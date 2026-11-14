using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace SampleRazorWebApp.IntegrationTests;

[TestClass]
public sealed class PageTests
{
    private static WebApplicationFactory<Program> s_factory = null!;

    [ClassInitialize]
    public static void Initialize(TestContext context)
    {
        s_factory = new WebApplicationFactory<Program>();
    }

    [ClassCleanup]
    public static void Cleanup()
    {
        s_factory.Dispose();
    }

    [TestMethod]
    [DataRow("/")]
    [DataRow("/Privacy")]
    public async Task Get_ReturnsThePage(string url)
    {
        using var client = s_factory.CreateClient();

        using var response = await client.GetAsync(url);

        Assert.AreEqual(HttpStatusCode.OK, response.StatusCode);
        Assert.AreEqual("text/html", response.Content.Headers.ContentType?.MediaType);
    }
}
