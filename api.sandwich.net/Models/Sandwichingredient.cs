namespace api.sandwich.net.Models;

public partial class Sandwichingredient
{
    public int Id { get; set; }

    public int IngredientId { get; set; }

    public int SandwichId { get; set; }

    public virtual Sandwich Sandwich { get; set; } = null!;
}
