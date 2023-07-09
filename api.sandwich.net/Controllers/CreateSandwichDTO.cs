namespace api.sandwich.net.Controllers
{
    public class CreateSandwichDTO
    {
        public string designation { get; set; } = null!;
        public float selling_price { get; set; }
        public int[] ingredients { get; set; } = null!;
        public DescriptionDTO[] descriptions { get; set; } = null!;
    }

    public class DescriptionDTO
    {
        public string content { get; set; } = null!;
        public string language { get; set; } = null!;
    }
}