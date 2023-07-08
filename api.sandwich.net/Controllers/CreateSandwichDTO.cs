namespace api.sandwich.net.Controllers
{
    public class CreateSandwichDTO
    {
        public string designation { get; set; }
        public float selling_price { get; set; }
        public int[] ingredients { get; set; }
        public DescriptionDTO[] descriptions { get; set; }
    }

    public class DescriptionDTO
    {
       public string content { get; set; }
       public string language { get; set; }
    }
}