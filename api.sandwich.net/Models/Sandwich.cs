namespace api.sandwich.net.Models;

public partial class Sandwich
{
    public int SandwichId { get; set; }

    public string? Designation { get; set; }

    public double? SellingPrice { get; set; }

    public bool? IsActive { get; set; }

    public virtual ICollection<Sandwichdescription> Sandwichdescriptions { get; set; } = new List<Sandwichdescription>();

    public virtual ICollection<Sandwichingredient> Sandwichingredients { get; set; } = new List<Sandwichingredient>();
}
