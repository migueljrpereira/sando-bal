public final table<Sandwich> key(designation) sandoCache = table [
    {designation: "mista", descriptions: [[en, "CheeseHam Sandwich"], [pt, "Sande mista"]], ingredients: [ingredientsCache.get("queijo"), ingredientsCache.get("fiambre")], sellPrice: 2.5},
    {designation: "fimabre-tomate", descriptions: [[en, "TomaHam Sandwich"], [pt, "Sande fiambre tomate"]], ingredients: [ingredientsCache.get("tomate"), ingredientsCache.get("fiambre")], sellPrice: 2.5}
    ];

public final table<Ingredient> key(designation) ingredientsCache = table [
    {designation: "queijo"},
    {designation: "fiambre"},
    {designation: "tomate"}
];

public type Sandwich record {|
    readonly string designation;
    decimal sellPrice;
    Ingredient[] ingredients;
    [Language, string][] descriptions;
|};

public type Ingredient record {|
    readonly string designation;
|};

public enum Language {
    en = "en-EN",
    pt = "pt-PT",
    es = "es-ES",
    fr = "fr-FR",
    jp = "jp-JP"
}
