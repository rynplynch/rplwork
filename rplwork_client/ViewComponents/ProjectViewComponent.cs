using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using rplwork_client.ViewModels;
using Microsoft.AspNetCore.Http.HttpResults;
namespace rplwork_client.ViewComponents
{
    public class ProjectViewComponent : ViewComponent
    {
        private readonly ILogger<ProjectViewComponent> _logger;
        public ProjectViewComponent(
                ILogger<ProjectViewComponent> logger
                )
        {
            _logger = logger;
        }

        public async Task<IViewComponentResult> InvokeAsync()
        {
            // wait for a response, which hopefully has our projects list
            var resp = await GetProjectsAsync();

            // extract the result from the response
            var result = resp.Result;

            // Test to see which result we got in the response
            if (result is Ok<List<ProjectViewModel>>)
            {
                // actualize the real result by casting it
                Ok<List<ProjectViewModel>> ok = (Ok<List<ProjectViewModel>>)result;

                // extract the project list from the result and return it to the view
                return View((List<ProjectViewModel>?)ok.Value);
            }
            // we don't care to test for any other results here
            else
                return View();
        }

        public async Task<Results<Ok<List<ProjectViewModel>>, NotFound, ProblemHttpResult>> GetProjectsAsync()
        {/*{{{*/
            try
            {
                // read in json from file existing on web server
                string json = await File.ReadAllTextAsync("./SiteData/projects.json");

                // parse that json using the ProjectViewModel as a guide
                List<ProjectViewModel>? projectList = JsonSerializer.Deserialize<List<ProjectViewModel>>(json);

                // depending on the value of the project list return a strongly typed http response
                return projectList == null ? TypedResults.NotFound() : TypedResults.Ok(projectList);
            }
            catch (Exception e)
            {
                _logger.LogError("Error while getting list of projects from projects.json: {Error}", e);
                return TypedResults.Problem(statusCode: 500);
            }
        }/*}}}*/
    }
}
