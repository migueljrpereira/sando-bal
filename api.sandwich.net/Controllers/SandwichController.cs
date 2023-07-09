
using api.sandwich.net.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Reflection.Metadata.Ecma335;
using System.Xml.Linq;

namespace api.sandwich.net.Controllers
{
    [ApiController]
    [Route("")]
    public class SandwichController : ControllerBase
    {
        private readonly SandwichContext data;

        public SandwichController(SandwichContext data)
        {
            this.data = data;
        }

        [HttpGet]
        public async Task<IActionResult> getAllSandwiches()
        {
            return Ok(await data.Sandwiches.Where(s => s.IsActive == true).ToListAsync());
        }

        [HttpGet("id/{id}")]
        public async Task<IActionResult> getById(int id)
        {
            return Ok(await data.Sandwiches.Where(s => s.SandwichId == id).SingleOrDefaultAsync());
        }

        [HttpGet("id/{sandwich_id}/price")]
        public async Task<IActionResult> getPriceById(int sandwich_id)
        {
            return Ok(await data.Sandwiches.Where(s => s.SandwichId == sandwich_id).Select(p => p.SellingPrice).SingleOrDefaultAsync());
        }

        [HttpGet("id/{sandwich_id}/ingredients")]
        public async Task<IActionResult> getIngredientsById(int sandwich_id)
        {
            return Ok(await data.Sandwiches.Where(s => s.SandwichId == sandwich_id).Select(p => p.Sandwichingredients).SingleOrDefaultAsync());
        }

        [HttpGet("name/{name}")]
        public async Task<IActionResult> getByName(string name)
        {
            return Ok(await data.Sandwiches.Where(s => s.Designation == name).SingleOrDefaultAsync());
        }

        [HttpGet("name/{sandwich_name}/price")]
        public async Task<IActionResult> getPriceByName(string sandwich_name)
        {
            return Ok(await data.Sandwiches.Where(s => s.Designation == sandwich_name).Select(p => p.SellingPrice).SingleOrDefaultAsync());
        }

        [HttpGet("name/{sandwich_name}/ingredients")]
        public async Task<IActionResult> getIngredientsByName(string sandwich_name)
        {
            return Ok(await data.Sandwiches.Where(s => s.Designation == sandwich_name).Select(p => p.Sandwichingredients).SingleOrDefaultAsync());
        }

        [HttpPost("create")]
        public async Task<IActionResult> createSandwich(CreateSandwichDTO dto)
        {
            Sandwich newsand = new()
            {
                Designation = dto.designation,
                IsActive = true,
                Sandwichdescriptions = dto.descriptions.Select(d => { return new Sandwichdescription { Content = d.content, Language = d.language }; }).ToList(),
                SellingPrice = dto.selling_price,
                Sandwichingredients = dto.ingredients.Select(i => { return new Sandwichingredient { IngredientId = i }; }).ToList()
            };

            await data.Sandwiches.AddAsync(newsand);

            if ((await data.SaveChangesAsync()) > 0)
            {
                return Created("", $"Sandwich {newsand.Designation} id: {newsand.SandwichId} was created.");
            }
            else
            {
                return BadRequest("Sandwich not Created");
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> updateSandwich(int id)
        {
            var sand = await data.Sandwiches.Where(s => s.SandwichId == id).SingleOrDefaultAsync();

            if (sand is not null)
            {
                sand.IsActive = true;
                data.Sandwiches.Update(sand);

                await data.SaveChangesAsync();

                return Ok(id);
            }
            else
            {
                return BadRequest("Sandwich does not exist");
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> deactivateSandwich(int id)
        {
            var sand = await data.Sandwiches.Where(s => s.SandwichId == id).SingleOrDefaultAsync();

            if (sand is not null)
            {
                sand.IsActive = false;
                data.Sandwiches.Update(sand);

                await data.SaveChangesAsync();

                return Ok(id);
            }
            else
            {
                return BadRequest("Sandwich does not exist");
            }

        }

        [HttpDelete("delete/test")]
        public async Task<IActionResult> deleteTestData()
        {
            var listSand = await data.Sandwiches.Where(s => s.Designation != null && s.Designation.Contains("Test")).ToListAsync();

            foreach (var sand in listSand)
            {
                foreach (var item in data.Sandwichingredients.Where(i => i.SandwichId == sand.SandwichId).ToList())
                {
                    sand.Sandwichingredients.Remove(item);
                }

                foreach (var item in data.Sandwichdescriptions.Where(i => i.SandwichId == sand.SandwichId).ToList())
                {
                    sand.Sandwichdescriptions.Remove(item);
                }

            }

            data.Sandwiches.RemoveRange(listSand);

            return Ok(await data.SaveChangesAsync());

        }
    }
}



