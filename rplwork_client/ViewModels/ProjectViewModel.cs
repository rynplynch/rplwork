using System.ComponentModel.DataAnnotations;

namespace rplwork_client.ViewModels;
public class ProjectViewModel
{
    public int PrimaryKey { get; set; }

    [StringLength(15)]
    [Required(AllowEmptyStrings = false)]
    public required string Title { get; set; }

    [Required(ErrorMessage = "This field can not be empty.")]
    public required string Description { get; set; }

    [Required(ErrorMessage = "This field can not be empty.")]
    public required List<Uri> Repositories { get; set; }

    public Uri? Domain { get; set; }
}

