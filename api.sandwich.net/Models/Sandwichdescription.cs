namespace api.sandwich.net.Models;

public partial class Sandwichdescription
{
    public int Id { get; set; }

    public int SandwichId { get; set; }

    public string? Content { get; set; }
    
    public string? Language { get; set; }

    public virtual Sandwich Sandwich { get; set; } = null!;
}
