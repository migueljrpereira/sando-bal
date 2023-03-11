import migueljrpereira/sandobal.domain;

public final table<domain:Sandwich> key(designation) sandoCache = table [
    {designation: "mista",
    descriptions: [[domain:en, "CheeseHam Sandwich"], [domain:pt, "Sande mista"]],
    ingredients: [ingredientsCache.get("queijo"), ingredientsCache.get("fiambre")],
    sellPrice: 2.5},

    {designation: "fiambre-tomate",
    descriptions: [[domain:en, "TomaHam Sandwich"], [domain:pt, "Sande fiambre tomate"]],
    ingredients: [ingredientsCache.get("tomate"),
    ingredientsCache.get("fiambre")],
    sellPrice: 2.5}
];

public final table<domain:Ingredient> key(designation) ingredientsCache = table [
    {designation: "queijo"},
    {designation: "fiambre"},
    {designation: "tomate"}
];
